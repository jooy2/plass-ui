/**
 * The edge of an invalid field, which only a stylesheet can show.
 *
 * The rule is carried by `data-invalid` on the field's root, in a class every
 * field shell shares, so what can break is whether the two meet: a shell that
 * stops being inside the root, or a variant that clears the outline. The
 * assertions are about whether an edge is there and not about its colour.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { page } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlCombobox, PlNumberField, PlSelect, PlTextField } from 'plass-ui';
import type { PlassVariant } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/** The nearest box round [control] that carries the field's own surface. */
function shellOf(control: Element): Element {
  let box: Element | null = control;

  while (box && !box.className.toString().includes('in-data-invalid')) {
    box = box.parentElement;
  }

  if (!box) {
    throw new Error('No shell round the control');
  }

  return box;
}

describe('an invalid field', () => {
  for (const variant of ['solid', 'glass', 'ghost'] as PlassVariant[]) {
    it(`draws an edge at rest on a ${variant} field`, async () => {
      const screen = await render(<PlTextField label="Email" variant={variant} error="Required" />);
      const shell = shellOf(screen.getByRole('textbox').element());

      expect(getComputedStyle(shell).outlineStyle).toBe('solid');
    });

    it(`draws none on a ${variant} field that is valid`, async () => {
      const screen = await render(<PlTextField label="Email" variant={variant} />);
      const shell = shellOf(screen.getByRole('textbox').element());

      expect(getComputedStyle(shell).outlineStyle).toBe('none');
    });
  }

  it('reaches a number field, a select and a combobox through the same class', async () => {
    const screen = await render(
      <>
        <PlNumberField label="Age" error="Required" />
        <PlSelect label="City" error="Required" items={[{ value: 'a', label: 'A' }]} />
        <PlCombobox label="Town" error="Required" items={[{ value: 'b', label: 'B' }]} />
      </>
    );

    for (const control of [
      screen.getByRole('textbox', { name: 'Age' }),
      screen.getByRole('combobox', { name: 'City' }),
      screen.getByRole('combobox', { name: 'Town' })
    ]) {
      expect(getComputedStyle(shellOf(control.element())).outlineStyle).toBe('solid');
    }
  });

  it('hands the outline to the focus ring', async () => {
    const screen = await render(<PlTextField label="Email" error="Required" />);
    const field = screen.getByRole('textbox');
    const shell = shellOf(field.element());
    const rest = getComputedStyle(shell).outlineWidth;

    await page.getByRole('textbox').click();

    await expect.poll(() => getComputedStyle(shell).outlineWidth).not.toBe(rest);
  });

  it('leaves the line on the edge of a notched field, where it goes round the label', async () => {
    const screen = await render(
      <PlTextField label="Email" labelPlacement="notch" variant="solid" error="Required" />
    );
    const shell = shellOf(screen.getByRole('textbox').element());
    const edge = shell.parentElement?.querySelector('fieldset');

    expect(getComputedStyle(shell).outlineStyle).toBe('none');
    expect(edge).not.toBeNull();
    expect(getComputedStyle(edge as Element).borderTopColor).not.toBe('rgba(0, 0, 0, 0)');
  });
});
