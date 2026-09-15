import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlAnimateBlink,
  PlAnimateFade,
  PlAnimateGrow,
  PlAnimateReveal,
  PlAnimateRotate,
  PlAnimateSlide,
  PlAnimateSplit,
  PlAnimateZoom
} from 'plass-ui';
import standaloneCss from '../../../src/standalone.css?inline';

const LINE = 'Ship it on Friday';

/** The slots an entrance starts from, which are where the effects differ. */
const START_SLOTS = [
  '--p-anim-opacity',
  '--p-anim-scale',
  '--p-anim-x',
  '--p-anim-y',
  '--p-anim-angle',
  '--p-anim-angle-to',
  '--p-anim-clip'
];

function startOf(element: HTMLElement): Record<string, string> {
  return Object.fromEntries(
    START_SLOTS.map((slot) => [slot, element.style.getPropertyValue(slot)])
  );
}

function root(): HTMLElement {
  return document.querySelector<HTMLElement>('.split-under-test')!;
}

/** The animated parts, which are the spans in the hidden half carrying the effect. */
function parts(): HTMLElement[] {
  return Array.from(root().querySelectorAll<HTMLElement>('[aria-hidden="true"] .plass-anim'));
}

/** What a screen reader is told, which is the line and not the parts. */
function announced(): string {
  return (root().firstElementChild as HTMLElement).textContent ?? '';
}

describe('PlAnimateSplit', () => {
  describe('the cut', () => {
    it('is by word by default', async () => {
      await render(<PlAnimateSplit className="split-under-test">{LINE}</PlAnimateSplit>);

      expect(parts().map((part) => part.textContent)).toEqual(['Ship', 'it', 'on', 'Friday']);
    });

    it('is by character when it was asked for', async () => {
      await render(
        <PlAnimateSplit className="split-under-test" by="character">
          Ship
        </PlAnimateSplit>
      );

      expect(parts().map((part) => part.textContent)).toEqual(['S', 'h', 'i', 'p']);
    });

    it('keeps a character built out of several code points in one part', async () => {
      await render(
        <PlAnimateSplit className="split-under-test" by="character">
          {'é\u{1F1F0}\u{1F1F7}\u{1F680}'}
        </PlAnimateSplit>
      );

      // A letter with a combining accent, a flag made of two regional
      // indicators and an emoji outside the basic plane. Cut by code point,
      // each would come apart into pieces that draw as broken glyphs.
      expect(parts().map((part) => part.textContent)).toEqual([
        'é',
        '\u{1F1F0}\u{1F1F7}',
        '\u{1F680}'
      ]);
    });

    it('leaves the gaps as gaps rather than animating them', async () => {
      await render(<PlAnimateSplit className="split-under-test">{LINE}</PlAnimateSplit>);

      // Giving whitespace an entrance would animate the space between two
      // words, which is nothing arriving.
      expect(parts().length).toBe(4);
      expect(root().querySelector('[aria-hidden="true"]')!.textContent).toBe(LINE);
    });

    it('makes each part inline-block, or nothing would move', async () => {
      await render(<PlAnimateSplit className="split-under-test">{LINE}</PlAnimateSplit>);

      // A transform does not apply to a non-replaced inline element: the part
      // would fade and never move.
      expect(parts()[0].classList.contains('inline-block')).toBe(true);
    });
  });

  describe('the effect', () => {
    it('is written onto the parts rather than onto the box', async () => {
      await render(<PlAnimateSplit className="split-under-test">{LINE}</PlAnimateSplit>);

      // Exactly what a staggered `PlAnimateFade` does to a list of `<li>`s.
      expect(parts()[0].classList.contains('plass-anim-fade')).toBe(true);
      expect(root().classList.contains('plass-anim-fade')).toBe(false);
    });

    it('takes any of the entrances', async () => {
      await render(
        <PlAnimateSplit className="split-under-test" effect="slide">
          {LINE}
        </PlAnimateSplit>
      );

      expect(parts()[0].classList.contains('plass-anim-slide')).toBe(true);
    });

    it('starts each entrance where the component of that name starts', async () => {
      // The keyframe fallbacks are not those defaults: a slide would fall back
      // to no travel at all, and a zoom to a grow's scale.
      const components = {
        fade: PlAnimateFade,
        grow: PlAnimateGrow,
        slide: PlAnimateSlide,
        zoom: PlAnimateZoom,
        rotate: PlAnimateRotate,
        blink: PlAnimateBlink,
        reveal: PlAnimateReveal
      } as const;

      const screen = await render(<span />);

      for (const [effect, Component] of Object.entries(components)) {
        await screen.rerender(
          <>
            <PlAnimateSplit className="split-under-test" effect={effect as keyof typeof components}>
              {LINE}
            </PlAnimateSplit>
            <Component className="effect-under-test">{LINE}</Component>
          </>
        );

        const component = document.querySelector<HTMLElement>('.effect-under-test')!;

        expect(startOf(parts()[0]), effect).toEqual(startOf(component));
      }
    });

    it('tells it off across the parts', async () => {
      await render(
        <PlAnimateSplit className="split-under-test" stagger={50} delay={100}>
          {LINE}
        </PlAnimateSplit>
      );

      expect(parts().map((part) => part.style.getPropertyValue('--p-anim-delay'))).toEqual([
        '100ms',
        '150ms',
        '200ms',
        '250ms'
      ]);
    });

    it('starts from the end when it was told to', async () => {
      await render(
        <PlAnimateSplit className="split-under-test" stagger={50} reverse>
          {LINE}
        </PlAnimateSplit>
      );

      expect(parts().map((part) => part.style.getPropertyValue('--p-anim-delay'))).toEqual([
        '150ms',
        '100ms',
        '50ms',
        '0ms'
      ]);
    });

    it('counts the steps across the whole line when cut by character', async () => {
      await render(
        <PlAnimateSplit className="split-under-test" by="character" stagger={10}>
          Hi yo
        </PlAnimateSplit>
      );

      // The characters of each word are held together, and that must not start
      // the count again at every word.
      expect(parts().map((part) => part.style.getPropertyValue('--p-anim-delay'))).toEqual([
        '0ms',
        '10ms',
        '20ms',
        '30ms'
      ]);
    });
  });

  describe('laid out', () => {
    // The stylesheet is loaded here and nowhere else in this file. Whether a
    // part moves is a question about laid-out pixels, and with no CSS a part is
    // an inline span with no keyframe: it would sit still whatever its slots
    // said.
    let sheet: HTMLStyleElement;

    beforeAll(() => {
      sheet = document.createElement('style');
      sheet.textContent = standaloneCss;
      document.head.append(sheet);
    });

    afterAll(() => {
      sheet.remove();
    });

    it('moves a sliding part rather than only fading it', async () => {
      await render(
        <PlAnimateSplit className="split-under-test" effect="slide" paused>
          {LINE}
        </PlAnimateSplit>
      );

      // Held, a part sits on its first frame, which is a line below its place.
      const line = root()
        .querySelector<HTMLElement>('[aria-hidden="true"]')!
        .getBoundingClientRect();
      const part = parts()[0].getBoundingClientRect();

      expect(part.top - line.top).toBeGreaterThan(part.height / 2);
    });

    it('wraps a line cut by character between words, not partway through one', async () => {
      // Sixteen characters wide in a monospace face. The line is nineteen and
      // its second word fifteen, so the gap is the one place it can wrap.
      await render(
        <div style={{ font: '16px monospace', width: '16ch' }}>
          <PlAnimateSplit className="split-under-test" by="character">
            Say internationally
          </PlAnimateSplit>
        </div>
      );

      const tops = parts().map((part) => part.getBoundingClientRect().top);

      expect(tops[3]).toBeGreaterThan(tops[0]);
      expect(new Set(tops.slice(3)).size).toBe(1);
    });

    it('wraps a word wider than the whole line inside itself rather than overflowing', async () => {
      // Ten characters wide, and the word is fifteen.
      await render(
        <div className="box-under-test" style={{ font: '16px monospace', width: '10ch' }}>
          <PlAnimateSplit className="split-under-test" by="character">
            internationally
          </PlAnimateSplit>
        </div>
      );

      const box = document.querySelector<HTMLElement>('.box-under-test')!.getBoundingClientRect();

      for (const part of parts()) {
        expect(part.getBoundingClientRect().right).toBeLessThanOrEqual(box.right + 0.5);
      }
    });

    it('wraps a word part that has nothing to wrap between it and the next', async () => {
      // A Japanese sentence has no space to cut at, so cut by word it is one
      // part — and one part far wider than the box it is in.
      await render(
        <div className="box-under-test" style={{ font: '16px monospace', width: '120px' }}>
          <PlAnimateSplit className="split-under-test">日本語の文章はとても長いです</PlAnimateSplit>
        </div>
      );

      const box = document.querySelector<HTMLElement>('.box-under-test')!.getBoundingClientRect();
      const part = parts()[0].getBoundingClientRect();

      expect(parts()).toHaveLength(1);
      expect(part.right).toBeLessThanOrEqual(box.right + 0.5);
    });

    it('wraps a line in a script without spaces between its characters', async () => {
      // A Japanese sentence has no gaps to wrap in. It starts on the line of the
      // word before it and wraps between its characters, rather than dropping
      // below that word as one block or running out of the box.
      await render(
        <div className="box-under-test" style={{ font: '16px monospace', width: '120px' }}>
          <PlAnimateSplit className="split-under-test" by="character">
            Hi 日本語の文章はとても長いです
          </PlAnimateSplit>
        </div>
      );

      const box = document.querySelector<HTMLElement>('.box-under-test')!.getBoundingClientRect();
      const rects = parts().map((part) => part.getBoundingClientRect());

      expect(rects[2].top).toBeLessThan(rects[0].bottom);
      expect(rects[rects.length - 1].top).toBeGreaterThanOrEqual(rects[0].bottom);

      for (const rect of rects) {
        expect(rect.right).toBeLessThanOrEqual(box.right + 0.5);
      }
    });
  });

  describe('accessibility', () => {
    it('tells a screen reader the line rather than the parts', async () => {
      await render(<PlAnimateSplit className="split-under-test">{LINE}</PlAnimateSplit>);

      // The defect this pattern is known for is a headline read out one letter
      // at a time.
      expect(announced()).toBe(LINE);
      expect(root().querySelector('[aria-hidden="true"]')!.getAttribute('aria-hidden')).toBe(
        'true'
      );
    });
  });

  it('renders something other than a span when it is handed one', async () => {
    await render(
      <PlAnimateSplit className="split-under-test" render={<h2 />}>
        {LINE}
      </PlAnimateSplit>
    );

    expect(root().tagName).toBe('H2');
  });
});
