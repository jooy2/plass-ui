/**
 * Where a `labelPlacement="float"` label sits, and when it moves, which only the
 * stylesheet can answer.
 *
 * The label rests inside the control while the control is empty, nothing in the
 * field has the focus and no popup of its is open, and rises into the notch the
 * moment one of the three stops being true. All of that is a rule in
 * `styles.css` rather than a state a component holds, so each assertion is on
 * the geometry the browser lays out with `src/standalone.css` loaded the way
 * `card.test.tsx` loads it: the label's box against the control's, the width
 * of the legend that cuts the gap, and the colour a placeholder is drawn in.
 */
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { commands, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import {
  PlCombobox,
  PlFilePicker,
  PlNumberField,
  PlSelect,
  PlTextField,
  PlTreeSelect,
  type PlComboboxOption
} from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

const cities: PlComboboxOption[] = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'lisbon', label: 'Lisbon' }
];

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
  await commands.parkPointer();
});

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

/** Waits out whatever the last change set easing, so a value is read settled. */
async function settle(element: Element): Promise<void> {
  await Promise.all(element.getAnimations({ subtree: true }).map((one) => one.finished));
}

/** The frame a notch is drawn in, the legend in its edge and the label in that. */
function notchOf(index = 0) {
  const legend = document.querySelectorAll('legend')[index] as HTMLElement;
  const label = legend.firstElementChild as HTMLElement;
  const frame = legend.parentElement?.parentElement as HTMLElement;

  return { frame, legend, label };
}

/**
 * The box the words inside `element` are drawn in.
 *
 * A notched label is an inline `<label>` and a floating one a block, so the
 * two element boxes are different shapes around the same words: the first is
 * the font's content area, the second the line box it is centred in. The words
 * themselves are what a reader sees move, so they are what is measured.
 */
function glyphsOf(element: Element): DOMRect {
  const range = document.createRange();

  range.selectNodeContents(element);

  return range.getBoundingClientRect();
}

/** The middle of the words inside `element`, top to bottom. */
function middle(element: Element): number {
  const box = glyphsOf(element);

  return (box.top + box.bottom) / 2;
}

/**
 * Whether the label is resting inside `control` rather than on the edge.
 *
 * Within a pixel, because a range's box is snapped to whole pixels; the two
 * places a label can be are half the control's height apart.
 */
function restsIn(label: HTMLElement, control: HTMLElement): boolean {
  const box = control.getBoundingClientRect();

  return Math.abs(middle(label) - (box.top + box.bottom) / 2) < 1;
}

describe('a floating label', () => {
  it('rests where the value is written while the field is empty and idle', async () => {
    const screen = await render(
      <PlTextField label="Email" labelPlacement="float" placeholder="you@example.com" />
    );
    const input = screen.getByRole('textbox', { name: 'Email' }).element() as HTMLElement;
    const { legend, label } = notchOf();

    // In the middle of the control, starting where the text starts, and set in
    // the text's own size.
    expect(restsIn(label, input.parentElement as HTMLElement)).toBe(true);
    expect(glyphsOf(label).left).toBeCloseTo(input.getBoundingClientRect().left, 0);
    expect(getComputedStyle(label).fontSize).toBe(getComputedStyle(input).fontSize);
    // The legend has folded, so the edge is whole over it, and the placeholder
    // it stands in for is out of the way.
    expect(legend.getBoundingClientRect().width).toBeLessThan(1);
    expect(getComputedStyle(input, '::placeholder').color).toBe('rgba(0, 0, 0, 0)');
  });

  it('rises into exactly the notch a `notch` label sits in once the field has the focus', async () => {
    const screen = await render(
      <div>
        <PlTextField label="Email" labelPlacement="notch" />
        <PlTextField label="Email" labelPlacement="float" placeholder="you@example.com" />
      </div>
    );
    const [, input] = screen.getByRole('textbox', { name: 'Email' }).elements() as HTMLElement[];
    const notched = notchOf(0);
    const floating = notchOf(1);

    await userEvent.click(input);
    await expect.poll(() => document.activeElement).toBe(input);
    await settle(floating.frame);

    const offset = (box: DOMRect, frame: HTMLElement) => {
      const origin = frame.getBoundingClientRect();

      return { x: box.left - origin.left, y: box.top - origin.top, width: box.width };
    };

    // The same words in the same place, and the same gap cut for them.
    expect(offset(glyphsOf(floating.label), floating.frame)).toEqual(
      offset(glyphsOf(notched.label), notched.frame)
    );
    expect(offset(floating.legend.getBoundingClientRect(), floating.frame)).toEqual(
      offset(notched.legend.getBoundingClientRect(), notched.frame)
    );
    expect(getComputedStyle(input, '::placeholder').color).not.toBe('rgba(0, 0, 0, 0)');
  });

  it('opens the gap as it starts to rise and closes it only once it is back down', async () => {
    const screen = await render(<PlTextField label="Email" labelPlacement="float" />);
    const input = screen.getByRole('textbox', { name: 'Email' }).element() as HTMLElement;
    const { frame, legend, label } = notchOf();

    input.focus();

    // Open before the word has moved at all, so it never crosses a line.
    expect(legend.getBoundingClientRect().width).toBeGreaterThan(label.scrollWidth);

    await settle(frame);
    input.blur();

    // Still open while the word is on its way down, so the line never runs
    // through it.
    expect(frame.getAnimations({ subtree: true }).length).toBeGreaterThan(0);
    expect(legend.getBoundingClientRect().width).toBeGreaterThan(1);

    await settle(frame);

    expect(legend.getBoundingClientRect().width).toBeLessThan(1);
    expect(restsIn(label, input.parentElement as HTMLElement)).toBe(true);
  });

  it('stays in the notch once the field holds a value', async () => {
    const screen = await render(<PlTextField label="Email" labelPlacement="float" />);
    const input = screen.getByRole('textbox', { name: 'Email' }).element() as HTMLElement;
    const { frame, label } = notchOf();

    await userEvent.type(input, 'a@b.c');
    input.blur();
    await settle(frame);

    expect(restsIn(label, input.parentElement as HTMLElement)).toBe(false);
    expect(Math.abs(middle(label) - input.parentElement!.getBoundingClientRect().top)).toBeLessThan(
      1
    );
  });

  it('rests on the first line of a multiline field', async () => {
    const screen = await render(
      <PlTextField label="Note" labelPlacement="float" multiline rows={3} />
    );
    const textarea = screen.getByRole('textbox', { name: 'Note' }).element() as HTMLElement;
    const single = await render(<PlTextField label="Email" labelPlacement="float" />);
    const input = single.getByRole('textbox', { name: 'Email' }).element() as HTMLElement;

    // A one-row textarea is as tall as a single-line field, so the first row of
    // any textarea is where a single-line field's text sits.
    const fromTop = (index: number, control: HTMLElement) =>
      middle(notchOf(index).label) -
      (control.parentElement as HTMLElement).getBoundingClientRect().top;

    expect(fromTop(0, textarea)).toBeCloseTo(fromTop(1, input), 1);
    expect(restsIn(notchOf(1).label, input.parentElement as HTMLElement)).toBe(true);
  });

  it('stays in the notch where the control draws something at its start', async () => {
    await render(
      <div>
        <PlTextField label="Price" labelPlacement="float" startIcon={<span>$</span>} />
        <PlNumberField label="Quantity" labelPlacement="float" steppers="split" />
        <PlFilePicker label="Attachments" labelPlacement="float" />
      </div>
    );

    for (const index of [0, 1, 2]) {
      const { frame, label, legend } = notchOf(index);
      const shell = frame.firstElementChild as HTMLElement;

      expect(frame).not.toHaveClass('plass-notch-float');
      expect(Math.abs(middle(label) - shell.getBoundingClientRect().top)).toBeLessThan(1);
      expect(legend.getBoundingClientRect().width).toBeGreaterThan(1);
    }
  });

  it('rests in an empty select, and rises while it is open and once it holds a value', async () => {
    const screen = await render(
      <PlSelect items={cities} label="City" labelPlacement="float" placeholder="Pick one" />
    );
    const trigger = screen.getByRole('combobox', { name: /City/ }).element() as HTMLElement;
    const { frame, label } = notchOf();

    expect(restsIn(label, trigger)).toBe(true);

    await userEvent.click(trigger);
    await expect.element(screen.getByRole('option', { name: 'Seoul' })).toBeVisible();
    await settle(frame);

    // The focus has gone into the popup, and the label is still up.
    expect(restsIn(label, trigger)).toBe(false);

    await userEvent.click(screen.getByRole('option', { name: 'Seoul' }));
    (document.activeElement as HTMLElement | null)?.blur();
    await settle(frame);

    expect(restsIn(label, trigger)).toBe(false);
  });

  it('rests in a multiple combobox only while it holds no chip', async () => {
    await render(
      <div>
        <PlCombobox items={cities} multiple label="Cities" labelPlacement="float" />
        <PlCombobox
          items={cities}
          multiple
          defaultValue={['seoul']}
          label="Cities"
          labelPlacement="float"
        />
      </div>
    );

    const shellOf = (index: number) => notchOf(index).frame.firstElementChild as HTMLElement;

    expect(restsIn(notchOf(0).label, shellOf(0))).toBe(true);
    expect(restsIn(notchOf(1).label, shellOf(1))).toBe(false);
  });

  it('rests in an empty picker, and rises while its popup is open', async () => {
    await render(
      <PlTreeSelect
        items={[{ id: 'seoul', label: 'Seoul' }]}
        label="Region"
        labelPlacement="float"
        placeholder="Pick a region"
      />
    );
    const trigger = document.querySelector<HTMLElement>('button[aria-haspopup]')!;
    const { frame, label } = notchOf();
    const display = trigger.querySelector('span > span') as HTMLElement;

    expect(frame).toHaveAttribute('data-empty');
    expect(restsIn(label, trigger)).toBe(true);
    expect(getComputedStyle(display).color).toBe('rgba(0, 0, 0, 0)');

    await userEvent.click(trigger);
    await expect.poll(() => trigger.getAttribute('aria-expanded')).toBe('true');
    await settle(frame);

    expect(restsIn(label, trigger)).toBe(false);
  });

  it('arrives at once under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    const screen = await render(<PlTextField label="Email" labelPlacement="float" />);
    const input = screen.getByRole('textbox', { name: 'Email' }).element() as HTMLElement;
    const { frame, legend, label } = notchOf();

    input.focus();
    expect(frame.getAnimations({ subtree: true })).toHaveLength(0);
    expect(restsIn(label, input.parentElement as HTMLElement)).toBe(false);

    input.blur();
    expect(frame.getAnimations({ subtree: true })).toHaveLength(0);
    expect(legend.getBoundingClientRect().width).toBeLessThan(1);
  });
});
