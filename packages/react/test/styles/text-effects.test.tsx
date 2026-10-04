/**
 * The clipped copy the four text effects put beside the line they draw, and the
 * text a page that uses one of them is left holding.
 *
 * The copy is there so a screen reader hears the line once rather than one
 * word, one character or one frame at a time. A selection across the pair used
 * to hand the line back twice, and the server's HTML held it twice, which is
 * what a crawler indexes. Only the real stylesheet can say what is drawn and
 * what is selected: `select-none` and `before:content-[…]` are class names and
 * nothing else without it. Loaded the way `code-block.test.tsx` loads it.
 */
import { act } from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlAnimateCounter,
  PlAnimateHeadline,
  PlAnimateScramble,
  PlAnimateSplit,
  PlAnimateTyping
} from 'plass-ui';
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

/** What a pseudo-element draws, as the string it was handed. */
function drawnBefore(element: Element): string {
  return JSON.parse(getComputedStyle(element, '::before').content) as string;
}

describe('the clipped copy of a text effect', () => {
  it('is left out of a selection on PlAnimateTyping, whose typed copy is text', async () => {
    const screen = await render(<PlAnimateTyping>Ship it</PlAnimateTyping>);
    const copies = screen.container.querySelectorAll('[data-plass-animation] > span');

    // The clipped copy first, the drawn one after it.
    expect(copies).toHaveLength(2);
    expect(getComputedStyle(copies[0]!).userSelect).toBe('none');
    expect(getComputedStyle(copies[1]!).userSelect).not.toBe('none');
  });

  const drawnFromAttribute = [
    ['PlAnimateScramble', <PlAnimateScramble key="scramble">Deploying</PlAnimateScramble>],
    ['PlAnimateCounter', <PlAnimateCounter key="counter" value={42} />]
  ] as const;

  for (const [name, element] of drawnFromAttribute) {
    it(`is the one that is selected on ${name}, whose drawn copy is not text`, async () => {
      const screen = await render(element);
      const copies = screen.container.querySelectorAll<HTMLElement>(
        '[data-plass-animation] > span'
      );

      expect(copies).toHaveLength(2);
      expect(getComputedStyle(copies[0]!).userSelect).not.toBe('none');
      expect(copies[1]!.textContent).toBe('');
      expect(drawnBefore(copies[1]!)).toBe(copies[1]!.dataset.text);
    });
  }

  it('is the one that is selected on PlAnimateSplit, whose parts are not text', async () => {
    const screen = await render(<PlAnimateSplit>Internationalization is long</PlAnimateSplit>);
    const copies = screen.container.querySelectorAll<HTMLElement>('[data-plass-animation] > span');
    const parts = Array.from(copies[1]!.querySelectorAll<HTMLElement>('.plass-anim'));

    expect(copies).toHaveLength(2);
    expect(getComputedStyle(copies[0]!).userSelect).not.toBe('none');
    // The gaps between the parts are the only text left in the drawn line,
    // and selected on their own they would light up between unlit words.
    expect(getComputedStyle(copies[1]!).userSelect).toBe('none');
    expect(parts.map((part) => drawnBefore(part))).toEqual(['Internationalization', 'is', 'long']);
    expect(parts.map((part) => part.textContent)).toEqual(['', '', '']);
  });
});

describe('the text a page holds', () => {
  /** The page's text the way an index reads it, with runs of white space as one. */
  function words(element: Element): string {
    return (element.textContent ?? '').replace(/\s+/g, ' ').trim();
  }

  const effects = [
    [
      'PlAnimateCounter',
      () => <PlAnimateCounter value={12345} />,
      new Intl.NumberFormat().format(12345)
    ],
    [
      'PlAnimateScramble',
      () => <PlAnimateScramble>Ship it on Friday</PlAnimateScramble>,
      'Ship it on Friday'
    ],
    [
      'PlAnimateSplit',
      () => <PlAnimateSplit>Ship it on Friday</PlAnimateSplit>,
      'Ship it on Friday'
    ],
    [
      'PlAnimateHeadline',
      () => (
        <PlAnimateHeadline>
          <span>ships on Friday</span>
          <span>reads like prose</span>
          weighs almost nothing
        </PlAnimateHeadline>
      ),
      'ships on Friday reads like prose weighs almost nothing'
    ]
  ] as const;

  for (const [name, element, text] of effects) {
    it(`holds the line once, in order, on ${name}, from the server and once hydrated`, async () => {
      const container = document.createElement('div');

      container.innerHTML = renderToString(element());
      document.body.append(container);

      try {
        expect(words(container)).toBe(text);

        const failed = vi.fn();
        const root = await act(async () =>
          hydrateRoot(container, element(), { onRecoverableError: failed })
        );

        expect(failed).not.toHaveBeenCalled();
        expect(words(container)).toBe(text);

        act(() => root.unmount());
      } finally {
        container.remove();
      }
    });
  }
});
