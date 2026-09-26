/**
 * How a `PlCommandPalette` row takes the highlight, which only the stylesheet
 * can answer.
 *
 * The wash and the ink are `data-[highlighted]:` colours on the row's own
 * transition list, so this file loads `src/standalone.css` the way
 * `card.test.tsx` does, records the transitions that actually run as the arrow
 * keys light a row, and then reads the wash it settles on. No colour is
 * asserted, only that the row eases both and settles on the family's
 * `--p-soft-hover`, the wash a `PlSelect` and a `PlMenu` row take.
 */
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { commands, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlCommandPalette } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

beforeEach(async () => {
  // A row lights for a pointer over it as well as for the keys, so the pointer
  // is put where no row can be.
  await commands.parkPointer();
});

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

/**
 * Every transition that starts on a row, by the row it started on. Read on
 * `transitionrun`, which bubbles to the list, so nothing has to sample a frame.
 */
function recordRuns(list: Element): Map<Element, string[]> {
  const runs = new Map<Element, string[]>();

  list.addEventListener('transitionrun', (raw) => {
    const event = raw as TransitionEvent;
    const target = event.target as Element;

    if (target.getAttribute('role') === 'option' && event.pseudoElement === '') {
      runs.set(target, [...(runs.get(target) ?? []), event.propertyName]);
    }
  });

  return runs;
}

/** Opens the palette, puts the focus in its field and lights a row with ↓. */
async function lightRow(): Promise<{ row: HTMLElement; runs: Map<Element, string[]> }> {
  const screen = await render(
    <PlCommandPalette
      shortcut={false}
      defaultOpen
      items={[
        { value: 'copy', label: 'Copy' },
        { value: 'paste', label: 'Paste' }
      ]}
    />
  );
  const field = screen.getByRole('combobox').element() as HTMLElement;

  await expect.element(screen.getByRole('option', { name: 'Paste' })).toBeVisible();

  const list = screen.getByRole('listbox').element();
  const runs = recordRuns(list);

  // Read before the change, which is also what gives the change a style to ease
  // from.
  for (const option of screen.getByRole('option').elements()) {
    expect(getComputedStyle(option).color).not.toBe('');
  }

  field.focus();
  await expect.poll(() => document.activeElement).toBe(field);
  await userEvent.keyboard('{ArrowDown}');
  await expect
    .poll(() => document.querySelector('[role="option"][data-highlighted]'))
    .not.toBeNull();

  return {
    row: document.querySelector('[role="option"][data-highlighted]') as HTMLElement,
    runs
  };
}

/** The colour `var(name)` resolves to where `element` is. */
function resolved(element: Element, name: string): string {
  const probe = document.createElement('div');

  probe.style.backgroundColor = `var(${name})`;
  element.append(probe);

  try {
    return getComputedStyle(probe).backgroundColor;
  } finally {
    probe.remove();
  }
}

describe('a command palette row', () => {
  it('eases its wash and its ink as the highlight reaches it', async () => {
    const { row, runs } = await lightRow();

    await expect.poll(() => runs.get(row) ?? []).toContain('background-color');
    await expect.poll(() => runs.get(row) ?? []).toContain('color');
  });

  it('washes the highlighted row in the family’s soft-hover', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    const { row } = await lightRow();

    expect(getComputedStyle(row).backgroundColor).toBe(resolved(row, '--p-soft-hover'));
  });
});
