/**
 * Where the × on a chip, on a picker trigger and on everything that can be
 * dismissed can be pressed from, which the stylesheet decides.
 *
 * The glyph is drawn smaller than the 24px target WCAG 2.5.8 asks for, and what
 * widens the press is a pseudo-element the markup does not show. So
 * `src/standalone.css` is loaded the way `marquee.test.tsx` loads it, and the
 * page is asked which button is under a point. Each component is drawn at its
 * smallest step, where the glyph is furthest from 24px.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlAlert,
  PlChip,
  PlCombobox,
  PlDatePicker,
  PlDrawer,
  PlFilePicker,
  PlModal,
  PlPopover,
  PlToastProvider,
  PlTour,
  usePlToast
} from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

/** Just inside the edge of a 24px square centred on the ×. */
const REACH = 11.5;

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/** The button under a point on the page, if there is one. */
function buttonAt([x, y]: [number, number]): Element | null {
  return document.elementFromPoint(x, y)?.closest('button') ?? null;
}

/** A point `dx` and `dy` away from the middle of `element`. */
function fromMiddle(element: Element, dx: number, dy: number): [number, number] {
  const box = element.getBoundingClientRect();

  return [box.left + box.width / 2 + dx, box.top + box.height / 2 + dy];
}

/** The corners, the sides and the middle of the 24px square around `element`. */
function square(element: Element): [number, number][] {
  return [-REACH, 0, REACH].flatMap((dx) =>
    [-REACH, 0, REACH].map((dy) => fromMiddle(element, dx, dy))
  );
}

describe('the × target', () => {
  it('takes a press anywhere in the 24px square around a chip’s ×', async () => {
    const screen = await render(
      <div style={{ padding: 32 }}>
        <PlChip size="xs" onClick={() => {}} onDelete={() => {}}>
          Design
        </PlChip>
      </div>
    );
    const remove = screen.getByRole('button', { name: 'Remove Design' }).element();

    // Placed out of the flow, so the chip is laid out as it was without it.
    expect(getComputedStyle(remove, '::before').position).toBe('absolute');

    for (const point of square(remove)) {
      expect(buttonAt(point), `at ${point}`).toBe(remove);
    }
  });

  it('leaves the rest of the chip to its label', async () => {
    const screen = await render(
      <div style={{ padding: 32 }}>
        <PlChip size="xs" onClick={() => {}} onDelete={() => {}}>
          Design
        </PlChip>
      </div>
    );
    const remove = screen.getByRole('button', { name: 'Remove Design' }).element();
    const label = screen.getByRole('button', { name: 'Design', exact: true }).element();

    expect(buttonAt(fromMiddle(remove, -14, 0))).toBe(label);
  });

  it('takes a press anywhere in the 24px square around a PlCombobox chip’s ×', async () => {
    const screen = await render(
      <div style={{ padding: 32 }}>
        <PlCombobox
          size="sm"
          items={[{ value: 'seoul', label: 'Seoul' }]}
          multiple
          defaultValue={['seoul']}
        />
      </div>
    );
    const remove = screen.getByRole('button', { name: 'Remove Seoul' }).element();

    for (const point of square(remove)) {
      expect(buttonAt(point), `at ${point}`).toBe(remove);
    }
  });

  it('takes a press anywhere in the 24px square around a PlCombobox’s clear ×, and leaves the chevron its middle', async () => {
    const screen = await render(
      <div style={{ padding: 32 }}>
        <PlCombobox
          size="xs"
          items={[{ value: 'seoul', label: 'Seoul' }]}
          defaultValue="seoul"
          clearable
        />
      </div>
    );
    const clear = screen.getByRole('button', { name: 'Clear' }).element();
    const chevron = screen.getByRole('button', { name: 'Open' }).element();

    // Placed out of the flow, so the field is laid out as it was without it.
    expect(getComputedStyle(clear, '::before').position).toBe('absolute');

    for (const point of square(clear)) {
      expect(buttonAt(point), `at ${point}`).toBe(clear);
    }

    // The chevron keeps the size it is drawn at, and where the square reaches
    // over its edge the × has the press — but never over its middle.
    expect(buttonAt(fromMiddle(chevron, 0, 0))).toBe(chevron);
  });

  it('takes a press anywhere in the 24px square around a picker’s ×, and leaves the rest to the trigger', async () => {
    const screen = await render(
      <div style={{ padding: 32 }}>
        <PlDatePicker size="xs" label="Departure" defaultValue={new Date(2026, 6, 27)} clearable />
      </div>
    );
    const clear = screen.getByRole('button', { name: 'Clear' }).element();
    const trigger = screen.getByRole('button', { name: /^Departure/ }).element();

    for (const point of square(clear)) {
      expect(buttonAt(point), `at ${point}`).toBe(clear);
    }

    expect(buttonAt(fromMiddle(clear, -14, 0))).toBe(trigger);
  });
});

/** Raises one toast when it is pressed. */
function Raise() {
  const toast = usePlToast();

  return (
    <button type="button" onClick={() => toast.add({ title: 'Saved', timeout: 0 })}>
      Raise
    </button>
  );
}

/** Every point of the square around `element` lands on it. */
function expectSquare(element: Element) {
  for (const point of square(element)) {
    expect(buttonAt(point), `at ${point}`).toBe(element);
  }
}

describe('the dismiss × target', () => {
  it('takes a press anywhere in the 24px square around an alert’s ×', async () => {
    const screen = await render(
      <div style={{ padding: 32 }}>
        <PlAlert size="xs" onClose={() => {}}>
          Saved.
        </PlAlert>
      </div>
    );

    expectSquare(screen.getByRole('button', { name: 'Dismiss' }).element());
  });

  it('takes a press anywhere in the 24px square around a toast’s ×', async () => {
    const screen = await render(
      <PlToastProvider size="xs">
        <Raise />
      </PlToastProvider>
    );
    await screen.getByRole('button', { name: 'Raise' }).click();
    await expect.poll(() => document.querySelector('[role="dialog"] [aria-label]')).not.toBeNull();

    expectSquare(document.querySelector('[role="dialog"] [aria-label]')!);
  });

  it('takes a press anywhere in the 24px square around a modal’s ×', async () => {
    const screen = await render(<PlModal size="xs" defaultOpen title="Rename" />);

    expectSquare(await screen.getByRole('button', { name: 'Close' }).element());
  });

  it('takes a press anywhere in the 24px square around a drawer’s ×', async () => {
    const screen = await render(<PlDrawer size="xs" defaultOpen title="Filters" />);

    expectSquare(screen.getByRole('button', { name: 'Close' }).element());
  });

  it('takes a press anywhere in the 24px square around a popover’s ×', async () => {
    const screen = await render(
      <PlPopover size="xs" defaultOpen showClose title="Rates">
        How the number is worked out.
      </PlPopover>
    );

    expectSquare(screen.getByRole('button', { name: 'Close' }).element());
  });

  it('takes a press anywhere in the 24px square around a tour’s ×', async () => {
    const screen = await render(
      <PlTour size="xs" defaultOpen scrollIntoView={false} steps={[{ title: 'Welcome' }]} />
    );

    expectSquare(screen.getByRole('button', { name: 'Close' }).element());
  });

  it('takes a press anywhere in the 24px square around a file’s ×', async () => {
    const screen = await render(
      <div style={{ padding: 32 }}>
        <PlFilePicker
          size="xs"
          label="Attachments"
          defaultValue={[new File(['a'], 'notes.txt', { type: 'text/plain' })]}
          onFilesChange={() => {}}
        />
      </div>
    );

    expectSquare(screen.getByRole('button', { name: /notes\.txt/ }).element());
  });
});
