/**
 * Where a browser's own padding on an `<input>` or a `<textarea>` still
 * reaches a component, which only the stylesheet can answer.
 *
 * Tailwind's Preflight takes the padding off every element, so a project that
 * runs Tailwind never sees it. The reset in `plass-ui/styles.css` leaves
 * padding alone, because it reaches a page's own fields too, so there the
 * browser's padding stayed on every field a component draws: the text of a
 * `PlTextField` started further in than the value of a `PlDatePicker` beside
 * it, and a one-row `multiline` field stood taller than a single-line one.
 * `src/standalone.css` is loaded the way `button-padding.test.tsx` loads it.
 *
 * A field's text cannot be measured with a range, so where it starts is read
 * off the field as the browser lays it out: at the inside of its border and its
 * padding. Each is measured against what it should line up with: a picker's
 * value, a single-line field, or the row the field sits in. No length is
 * asserted, only that the two agree.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlCombobox,
  PlCommandPalette,
  PlDatePicker,
  PlNumberField,
  PlTextField,
  type PlCommandItem
} from 'plass-ui';
import type { PlassSize } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

const SIZES: PlassSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/**
 * Where a field's first character is drawn: inside its border and its padding,
 * which is where a browser lays out the text of an `<input>` or a `<textarea>`.
 */
function textStart(field: HTMLElement): number {
  const style = getComputedStyle(field);

  // The border as the stylesheet resolves it rather than `clientLeft`, which
  // Firefox reports wider than the border of an input with padding.
  return (
    field.getBoundingClientRect().left +
    parseFloat(style.borderLeftWidth) +
    parseFloat(style.paddingLeft)
  );
}

/** The box round the words inside `element`. */
function glyphs(element: Element): DOMRect {
  const range = document.createRange();

  range.selectNodeContents(element);

  return range.getBoundingClientRect();
}

/** How far into its shell the text of a field starts. */
function fieldInset(field: HTMLElement): number {
  return textStart(field) - field.parentElement!.getBoundingClientRect().left;
}

/**
 * How far into its shell the value of a picker starts. The shell holds the
 * trigger, and the trigger holds the value.
 */
function valueInset(value: Element): number {
  const shell = value.closest('button')!.parentElement!;

  return glyphs(value).left - shell.getBoundingClientRect().left;
}

describe('the text of a field', () => {
  it.each(SIZES)(
    'starts as far into its shell as the value of a PlDatePicker at %s',
    async (size) => {
      const screen = await render(
        <>
          <PlDatePicker size={size} label="Date" placeholder="Pick a day" startIcon={false} />
          <PlTextField size={size} label="Text" defaultValue="Seoul" />
          <PlNumberField size={size} label="Number" defaultValue={12} />
          <PlCombobox
            size={size}
            label="Combo"
            items={[{ value: 'seoul', label: 'Seoul' }]}
            defaultValue="seoul"
          />
        </>
      );
      const picker = valueInset(screen.getByText('Pick a day').element());

      for (const name of ['Text', 'Number', 'Combo']) {
        const input = screen.getByLabelText(name, { exact: true }).element() as HTMLElement;

        expect(input.tagName, name).toBe('INPUT');
        expect(fieldInset(input), name).toBeCloseTo(picker, 1);
      }
    }
  );
});

describe('a PlTextField `multiline`', () => {
  it.each(SIZES)(
    'stands one row as tall as a single-line field, and starts its text as far in, at %s',
    async (size) => {
      const screen = await render(
        <>
          <PlDatePicker size={size} label="Date" placeholder="Pick a day" startIcon={false} />
          <PlTextField size={size} label="Line" />
          <PlTextField size={size} label="Note" multiline rows={1} />
        </>
      );
      const picker = valueInset(screen.getByText('Pick a day').element());
      const line = screen.getByRole('textbox', { name: 'Line' }).element() as HTMLElement;
      const note = screen.getByRole('textbox', { name: 'Note' }).element() as HTMLElement;

      expect(note.tagName).toBe('TEXTAREA');
      expect(note.parentElement!.getBoundingClientRect().height).toBe(
        line.parentElement!.getBoundingClientRect().height
      );
      expect(fieldInset(note)).toBeCloseTo(picker, 1);
    }
  );
});

describe('a PlCommandPalette', () => {
  const items: PlCommandItem[] = [{ value: 'new', label: 'New document' }];

  it.each(SIZES)('starts its query where the row it sits in puts it at %s', async (size) => {
    const screen = await render(
      <PlCommandPalette items={items} size={size} shortcut={false} defaultOpen />
    );

    await expect.element(screen.getByRole('combobox')).toBeVisible();

    const input = screen.getByRole('combobox').element() as HTMLElement;
    const row = input.parentElement!;
    const inside = row.getBoundingClientRect().left + parseFloat(getComputedStyle(row).paddingLeft);

    expect(textStart(input)).toBeCloseTo(inside, 1);
  });
});
