/**
 * How large a `PlFilePicker`'s glyph is drawn, which only the stylesheet can
 * answer.
 *
 * The glyph is sized against the title under it, as the Flutter build sizes it,
 * so it follows `size` and not whatever font size the page around the picker
 * happens to set. It is read with `src/standalone.css` loaded the way
 * `card.test.tsx` loads it. No size is asserted, only how the glyph's size
 * relates to the title's and to the page's.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlFilePicker } from 'plass-ui';
import type { PlassSize } from 'plass-ui';
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

const sizes: PlassSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

/** The glyph's width and the title's font size of every picker in a page set at 13px and at 20px, by size. */
async function measure() {
  await render(
    <>
      {[13, 20].map((fontSize) => (
        <div key={fontSize} data-font={fontSize} style={{ fontSize }}>
          {sizes.map((size) => (
            <PlFilePicker key={size} size={size} title="Drop files here" />
          ))}
        </div>
      ))}
    </>
  );

  const read = (fontSize: number) =>
    Array.from(document.querySelectorAll(`[data-font="${fontSize}"] button`)).map((button) => {
      const glyph = button.querySelector('svg') as SVGElement;
      const title = Array.from(button.querySelectorAll('span')).find(
        (span) => span.textContent === 'Drop files here'
      ) as HTMLElement;

      return {
        glyph: glyph.getBoundingClientRect().width,
        title: parseFloat(getComputedStyle(title).fontSize)
      };
    });

  return { small: read(13), large: read(20) };
}

describe('the file picker stylesheet', () => {
  it('draws the glyph at the same size whatever font size the page sets', async () => {
    const { small, large } = await measure();

    sizes.forEach((_, step) => {
      expect(large[step].glyph).toBeCloseTo(small[step].glyph, 1);
    });
  });

  it('draws the glyph larger at every step up the size ladder', async () => {
    const { small } = await measure();

    for (let step = 1; step < sizes.length; step += 1) {
      expect(small[step].glyph).toBeGreaterThan(small[step - 1].glyph);
    }
  });

  it('keeps the glyph in one proportion to the title at every size', async () => {
    const { small } = await measure();
    const ratios = small.map(({ glyph, title }) => glyph / title);

    for (const ratio of ratios) {
      expect(ratio).toBeCloseTo(ratios[0], 2);
    }
  });
});
