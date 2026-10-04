/**
 * How wide a control is that holds itself open at the widest value it could
 * show, which only the stylesheet can answer.
 *
 * `WidthSizer` writes every value into one element, a line each. It replaced
 * an element per value, and the width it gives has to be the width those gave,
 * to the pixel, including for a label with stray white space in it. So the old
 * arrangement is kept here as the reference: each test measures the control,
 * puts the old elements where the new one is, measures again and puts the new
 * one back. The controls are drawn at their widest content inside a box that
 * is as wide as they are, so nothing narrower than a sample can clip them.
 */
import type { ReactElement } from 'react';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlColorPicker,
  PlDatePicker,
  PlDateRangePicker,
  PlDateTimePicker,
  PlSelect,
  PlTimePicker,
  type PlSelectOption
} from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  // The reference's one rule, which no class in the library writes any more.
  sheet.textContent = `${standaloneCss}\n[data-reference]::before { content: attr(data-reference); }`;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/**
 * The sizer as it was before it was one element: a box clipped to no height,
 * holding a block per sample, each kept on one line by `nowrap`.
 */
function reference(samples: readonly string[]): HTMLElement {
  const box = document.createElement('span');

  box.setAttribute('aria-hidden', 'true');
  box.style.cssText = 'visibility: hidden; height: 0; min-height: 0; overflow: hidden';

  for (const sample of samples) {
    const line = document.createElement('span');

    line.dataset.reference = sample;
    line.style.cssText = 'display: block; white-space: nowrap';
    box.append(line);
  }

  return box;
}

/**
 * The host's width as drawn, with the old sizers in place of the new ones, and
 * with no sizer at all, which is what says the sizers are what decide it.
 */
function widths(host: HTMLElement, samplesOf: (sizer: HTMLElement) => readonly string[]) {
  const sizers = [...host.querySelectorAll<HTMLElement>('[data-sample]')];
  const width = () => host.getBoundingClientRect().width;
  const swap = (make: (sizer: HTMLElement) => HTMLElement) => {
    const stand = sizers.map((sizer) => {
      const element = make(sizer);

      sizer.replaceWith(element);
      return element;
    });
    const measured = width();

    stand.forEach((element, index) => element.replaceWith(sizers[index]));
    return measured;
  };

  return {
    drawn: width(),
    old: swap((sizer) => reference(samplesOf(sizer))),
    bare: swap(() => document.createElement('span'))
  };
}

async function draw(control: ReactElement) {
  const screen = await render(
    <div data-testid="host" style={{ width: 'max-content' }}>
      {control}
    </div>
  );

  return screen.getByTestId('host').element() as HTMLElement;
}

/** Every region a browser has an English name for: a long list of real words. */
const countries = (() => {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const names = new Intl.DisplayNames(['en'], { type: 'region', fallback: 'none' });

  return [...letters]
    .flatMap((first) => [...letters].map((second) => names.of(first + second)))
    .filter((name): name is string => name !== undefined);
})();

const PLACEHOLDER = 'Pick a country';

describe('WidthSizer', () => {
  it('has a long list to measure', () => {
    expect(countries.length).toBeGreaterThan(200);
  });

  it.each([
    { name: 'a long list of countries', labels: countries },
    {
      // The widest once its white space collapses, and wider still if it did not.
      name: 'a list whose widest label has leading, trailing, doubled and line-breaking white space',
      labels: [
        ...countries,
        '   The  United Kingdom of Great\tBritain  and\nNorthern  Ireland, and its Islands   '
      ]
    },
    {
      // Narrow once its white space collapses, and the widest by far if it did not.
      name: 'a list with a short label padded wide with spaces',
      labels: [...countries, `Andorra${' '.repeat(400)}la Vella`]
    }
  ])('gives a select over $name the width an element per option gave', async ({ labels }) => {
    const items: PlSelectOption[] = labels.map((label, index) => ({ value: `${index}`, label }));
    const host = await draw(<PlSelect items={items} placeholder={PLACEHOLDER} />);

    // One element for every option and the placeholder, rather than one each.
    const sizers = host.querySelectorAll('[data-sample]');

    expect(sizers).toHaveLength(1);
    expect(sizers[0].childElementCount).toBe(0);

    // The old sizer is given what `PlSelect` gave it, white space and all.
    const { drawn, old, bare } = widths(host, () => [...labels, PLACEHOLDER]);

    expect(drawn).toBeGreaterThan(bare);
    expect(drawn).toBe(old);
  });

  it.each<{ name: string; control: ReactElement; count: number }>([
    { name: 'PlDatePicker', control: <PlDatePicker placeholder="Departure" />, count: 1 },
    { name: 'PlTimePicker', control: <PlTimePicker placeholder="Start" />, count: 1 },
    { name: 'PlDateTimePicker', control: <PlDateTimePicker placeholder="Meeting" />, count: 1 },
    { name: 'PlColorPicker', control: <PlColorPicker format="rgb" alpha />, count: 1 },
    {
      name: 'PlDateRangePicker',
      control: <PlDateRangePicker startPlaceholder="Check in" endPlaceholder="Check out" />,
      count: 2
    }
  ])('gives a $name the width an element per value gave', async ({ control, count }) => {
    const host = await draw(control);

    expect(host.querySelectorAll('[data-sample]')).toHaveLength(count);

    // The lines it wrote, each as an element of its own.
    const { drawn, old, bare } = widths(host, (sizer) => sizer.dataset.sample!.split('\n'));

    expect(drawn).toBeGreaterThan(bare);
    expect(drawn).toBe(old);
  });
});
