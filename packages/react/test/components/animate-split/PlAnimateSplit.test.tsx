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

/** The animated parts, which are the spans inside the hidden half. */
function parts(): HTMLElement[] {
  return Array.from(root().querySelectorAll<HTMLElement>('[aria-hidden="true"] > span'));
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
