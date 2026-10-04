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
  const drawnFromAttribute = [
    ['PlAnimateScramble', <PlAnimateScramble key="scramble">Deploying</PlAnimateScramble>],
    ['PlAnimateCounter', <PlAnimateCounter key="counter" value={42} />],
    ['PlAnimateTyping', <PlAnimateTyping key="typing">Ship it</PlAnimateTyping>]
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
    ],
    ['PlAnimateTyping', () => <PlAnimateTyping text="Ship it on Friday" />, 'Ship it on Friday']
  ] as const;

  it('holds the line once on PlAnimateTyping at every moment of its typing', async () => {
    const screen = await render(<PlAnimateTyping text="Ship it on Friday" speed={120} />);
    const drawn = screen.container.querySelector<HTMLElement>('[aria-hidden="true"]')!;
    const seen = new Set<string>([words(screen.container)]);
    const observer = new MutationObserver(() => seen.add(words(screen.container)));

    observer.observe(drawn, { attributes: true, attributeFilter: ['data-text'] });

    try {
      await expect.poll(() => drawn.dataset.text).toBe('Ship it on Friday');
    } finally {
      observer.disconnect();
    }

    // Typed out, the drawn line used to be text too: the line twice, and the
    // caret and the room kept for it as "||" after it.
    expect([...seen]).toEqual(['Ship it on Friday']);
  });

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

describe('the room a changing line takes', () => {
  /**
   * Plays a held effect and hands back the width of `selector` on every frame
   * it drew on the way, starting with the frame it was held on.
   */
  async function widthsWhilePlaying(
    selector: string,
    play: () => Promise<unknown>,
    finished: () => boolean
  ): Promise<number[]> {
    const element = document.querySelector<HTMLElement>(selector)!;
    const drawn = element.querySelector<HTMLElement>('[aria-hidden="true"]')!;
    const widths = [element.getBoundingClientRect().width];
    const observer = new MutationObserver(() => {
      widths.push(element.getBoundingClientRect().width);
    });

    observer.observe(drawn, { attributes: true, attributeFilter: ['data-text'] });

    try {
      await play();
      await expect.poll(finished).toBe(true);
    } finally {
      observer.disconnect();
    }

    widths.push(element.getBoundingClientRect().width);

    return widths;
  }

  it('is the width of the answer from the first frame of PlAnimateCounter to the last', async () => {
    // In the default format, which writes up to three decimals. Drawn on the
    // way, they made every frame but the first and the last wider than the
    // answer, and the box widened and narrowed again around them.
    const counter = (play: boolean) => (
      <p style={{ textAlign: 'center' }}>
        Shipped{' '}
        <PlAnimateCounter
          className="counter-under-test"
          trigger="manual"
          play={play}
          value={12345}
          duration={120}
        />{' '}
        times
      </p>
    );
    const screen = await render(counter(false));
    const drawn = document.querySelector<HTMLElement>('.counter-under-test [aria-hidden="true"]')!;

    // Held on the figure it counts from, which is far narrower than the answer.
    expect(drawn.dataset.text).toBe('0');

    const widths = await widthsWhilePlaying(
      '.counter-under-test',
      () => screen.rerender(counter(true)),
      () => drawn.dataset.text === new Intl.NumberFormat().format(12345)
    );

    expect(widths.length).toBeGreaterThan(2);
    expect(new Set(widths)).toEqual(new Set([widths.at(-1)]));
    expect(getComputedStyle(drawn, '::after').visibility).toBe('hidden');
  });

  it('is the width of the line from the first frame of PlAnimateScramble', async () => {
    // Noise drawn from a full stop alone, which is narrower than every letter
    // of the line, so every frame on the way is narrower than the line too.
    const scramble = (play: boolean) => (
      <p style={{ textAlign: 'center' }}>
        <PlAnimateScramble
          className="scramble-under-test"
          trigger="manual"
          play={play}
          characters="."
          duration={120}
        >
          Ship it on Friday
        </PlAnimateScramble>{' '}
        is the plan
      </p>
    );
    const screen = await render(scramble(false));
    const drawn = document.querySelector<HTMLElement>('.scramble-under-test [aria-hidden="true"]')!;

    expect(drawn.dataset.text).toBe('.... .. .. ......');

    const widths = await widthsWhilePlaying(
      '.scramble-under-test',
      () => screen.rerender(scramble(true)),
      () => drawn.dataset.text === 'Ship it on Friday'
    );

    expect(widths.length).toBeGreaterThan(2);
    expect(new Set(widths)).toEqual(new Set([widths.at(-1)]));
  });
});
