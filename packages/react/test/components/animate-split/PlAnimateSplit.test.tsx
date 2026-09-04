import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateSplit } from 'plass-ui';

const LINE = 'Ship it on Friday';

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
