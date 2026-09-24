/**
 * Which slide a `PlCarousel` strip shows, which only the stylesheet can answer.
 *
 * Without the real CSS the slides stack down the page and there is nothing to
 * scroll, so a carousel that opened on slide 3 while still showing slide 1 was
 * invisible to every component test: the dots were right and the strip was
 * never looked at. Loaded the way `back-top.test.tsx` loads it.
 */
import * as React from 'react';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCarousel } from 'plass-ui';
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

function Strip({
  value,
  defaultValue,
  onValueChange,
  dir
}: {
  value?: number;
  defaultValue?: number;
  onValueChange?: (index: number) => void;
  dir?: 'rtl';
}) {
  return (
    <div dir={dir} style={{ width: 320 }}>
      <PlCarousel value={value} defaultValue={defaultValue} onValueChange={onValueChange}>
        <div style={{ height: 120 }}>Alpha</div>
        <div style={{ height: 120 }}>Bravo</div>
        <div style={{ height: 120 }}>Charlie</div>
      </PlCarousel>
    </div>
  );
}

/** How far the named slide stands from where the track's box starts. */
function offsetOf(name: string) {
  const track = document.querySelector('[role="group"][aria-label="Carousel"]')!;
  const slide = document.querySelector(`[role="group"][aria-label="${name}"]`)!;

  return Math.abs(slide.getBoundingClientRect().left - track.getBoundingClientRect().left);
}

/**
 * Follows the track through being hidden and shown again, with a
 * `ResizeObserver` made after the carousel's. Observers report in the order
 * they were made, so this one hears of each width once the carousel's has, and
 * in the same frame. `hidden` resolves once the track has no width. `shown`
 * resolves once it has one again, with how far the named slide stands from
 * the track's start in that frame, before it is painted: a strip that
 * travelled there, or that is placed a frame later, is not there yet.
 *
 * Made while the track still has a width, so every report it waits for is a
 * change rather than a first one.
 */
function followTrack(slide: string) {
  const track = document.querySelector('[role="group"][aria-label="Carousel"]')!;
  let reportHidden!: () => void;
  let reportShown!: (offset: number) => void;
  const hidden = new Promise<void>((resolve) => (reportHidden = resolve));
  const shown = new Promise<number>((resolve) => (reportShown = resolve));
  let wasHidden = false;

  const observer = new ResizeObserver((entries) => {
    if (entries[entries.length - 1].contentRect.width === 0) {
      wasHidden = true;
      reportHidden();
    } else if (wasHidden) {
      observer.disconnect();
      reportShown(offsetOf(slide));
    }
  });

  observer.observe(track);

  return { hidden, shown };
}

describe('a PlCarousel that opens on a slide other than the first', () => {
  // Every reading is taken straight after the render and not polled for: a
  // strip that travelled there would still be on its way.
  it('shows the slide `defaultValue` names, without travelling to it', async () => {
    const screen = await render(<Strip defaultValue={2} />);

    expect(offsetOf('Slide 3 of 3')).toBeLessThan(1);
    await expect
      .element(screen.getByRole('button', { name: 'Slide 3 of 3' }))
      .toHaveAttribute('aria-current', 'true');
  });

  it('shows the slide a controlled `value` names', async () => {
    const screen = await render(<Strip value={1} />);

    expect(offsetOf('Slide 2 of 3')).toBeLessThan(1);
    await expect
      .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
      .toHaveAttribute('aria-current', 'true');
  });

  it('shows the slide `defaultValue` names once the box it was mounted hidden in is shown, without travelling to it', async () => {
    function Tab({ shown }: { shown: boolean }) {
      return (
        <div style={{ display: shown ? 'block' : 'none' }}>
          <Strip defaultValue={2} />
        </div>
      );
    }

    const screen = await render(<Tab shown={false} />);
    const track = document.querySelector('[role="group"][aria-label="Carousel"]')!;
    const positions: number[] = [];

    track.addEventListener('scroll', () => positions.push(track.scrollLeft));
    await screen.rerender(<Tab shown />);

    // Polled, unlike the readings above: the strip can only be placed once the
    // browser has laid the track out with a width, which is a frame after it
    // is shown.
    await expect.poll(() => offsetOf('Slide 3 of 3')).toBeLessThan(1);
    await expect.poll(() => positions.length).toBeGreaterThan(0);
    // In one step: a strip that travelled there would have passed through the
    // second slide on the way.
    expect(positions.every((position) => position === positions.at(-1))).toBe(true);
  });

  it('does the same the other way round under RTL', async () => {
    const screen = await render(<Strip defaultValue={2} dir="rtl" />);

    expect(offsetOf('Slide 3 of 3')).toBeLessThan(1);
    await expect
      .element(screen.getByRole('button', { name: 'Slide 3 of 3' }))
      .toHaveAttribute('aria-current', 'true');
  });
});

describe('a PlCarousel whose slide changes while it is hidden', () => {
  /** The box a tab panel or a disclosure hides the carousel in. */
  function Tab({
    shown,
    value,
    onValueChange,
    measured = false
  }: {
    shown: boolean;
    value: number;
    onValueChange?: (index: number) => void;
    measured?: boolean;
  }) {
    const box = React.useRef<HTMLDivElement>(null);

    // What a tab bar does when it measures the tab it has just shown: the page
    // is laid out there and then, before the frame the box is shown in.
    React.useLayoutEffect(() => {
      if (measured) {
        box.current?.getBoundingClientRect();
      }
    }, [measured, shown]);

    return (
      <div ref={box} style={{ display: shown ? 'block' : 'none' }}>
        <Strip value={value} onValueChange={onValueChange} />
      </div>
    );
  }

  // Read in the frame the track has its width back rather than off its scroll
  // events: in Firefox a scroll event thrown before the box was hidden can
  // arrive after it is shown, and reading `scrollLeft` in it lays the page out
  // early, which puts the old offset back before the carousel has heard of the
  // width.
  it('shows the slide it was moved to in the frame it is shown again in, without travelling to it', async () => {
    const screen = await render(<Tab shown value={1} />);

    // Hidden, handed another slide while it is, and shown again. The browser
    // puts back the offset the strip had when it was hidden, which is the old
    // slide.
    async function moveWhileHidden(from: number, to: number, slide: string) {
      const track = followTrack(slide);

      await screen.rerender(<Tab shown={false} value={from} />);
      await track.hidden;
      await screen.rerender(<Tab shown={false} value={to} />);
      await screen.rerender(<Tab shown value={to} />);

      return track.shown;
    }

    expect(await moveWhileHidden(1, 2, 'Slide 3 of 3')).toBeLessThan(1);
    // Back to the first slide, which is where a strip the browser has only
    // just laid out already is, and not where one it shows again is.
    expect(await moveWhileHidden(2, 0, 'Slide 1 of 3')).toBeLessThan(1);
  });

  it('keeps the slide it was moved to when the page is laid out before the frame it is shown in', async () => {
    const onValueChange = vi.fn();
    const screen = await render(<Tab shown value={1} onValueChange={onValueChange} measured />);
    const track = followTrack('Slide 3 of 3');

    await screen.rerender(<Tab shown={false} value={1} onValueChange={onValueChange} measured />);
    await track.hidden;
    await screen.rerender(<Tab shown={false} value={2} onValueChange={onValueChange} measured />);
    // Past the 700ms the carousel gives a scroll of its own to arrive, after
    // which a scroll event is taken to be the reader's. A tab is usually hidden
    // for longer than that.
    await new Promise((resolve) => setTimeout(resolve, 800));
    await screen.rerender(<Tab shown value={2} onValueChange={onValueChange} measured />);

    expect(await track.shown).toBeLessThan(1);
    // Firefox throws a scroll event at the offset it put back, in the frame the
    // strip is placed in but before it is, and that is not the reader going
    // back a slide.
    expect(onValueChange).not.toHaveBeenCalled();
    await expect
      .element(screen.getByRole('button', { name: 'Slide 3 of 3' }))
      .toHaveAttribute('aria-current', 'true');
  });
});
