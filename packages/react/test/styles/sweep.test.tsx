/**
 * How the two indeterminate sweeps travel, which only the stylesheet can say.
 *
 * A `PlSkeleton`'s highlight and an indeterminate `PlProgressLinear`'s segment
 * cross their box for as long as something is loading. Moved on an inset, each
 * frame laid the box out again and the browser recorded it as a layout shift,
 * so a page waiting behind a placeholder collected CLS for as long as it
 * waited. Moved on `translate`, nothing is laid out. The keyframes live in
 * `src/styles.css`, so this loads `src/standalone.css` the way
 * `marquee.test.tsx` does and reads the animations that actually run.
 *
 * No duration or shade is asserted: what property moves, that nothing shifts,
 * and which way the travel runs in each direction.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlProgressLinear, PlSkeleton } from 'plass-ui';
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

function Loading({ dir }: { dir?: 'ltr' | 'rtl' }) {
  return (
    <div className="sweeps-under-test" dir={dir} style={{ width: 320 }}>
      <PlSkeleton shape="rect" height={200} />
      <PlProgressLinear label="Uploading" />
    </div>
  );
}

function box(): HTMLElement {
  return document.querySelector('.sweeps-under-test') as HTMLElement;
}

/** The running animation with this name, anywhere inside the box. */
function sweep(name: 'plass-skeleton-sweep' | 'plass-progress-sweep'): CSSAnimation {
  const run = box()
    .getAnimations({ subtree: true })
    .find((one): one is CSSAnimation => one instanceof CSSAnimation && one.animationName === name);

  if (!run) {
    throw new Error(`No ${name} animation is running.`);
  }

  return run;
}

/** Every property the animation's keyframes move, in CSSOM's camelCase. */
function moved(run: CSSAnimation): string[] {
  const frames = (run.effect as KeyframeEffect).getKeyframes();
  const bookkeeping = new Set(['offset', 'computedOffset', 'easing', 'composite']);

  return [...new Set(frames.flatMap((frame) => Object.keys(frame)))].filter(
    (property) => !bookkeeping.has(property)
  );
}

/** Holds the animation still at this many milliseconds into an iteration. */
function holdAt(run: CSSAnimation, time: number): void {
  run.pause();
  run.currentTime = time;
}

/** How long one pass takes, as the stylesheet wrote it. */
function duration(run: CSSAnimation): number {
  return Number(run.effect?.getComputedTiming().duration);
}

/**
 * Where the highlight's left edge is, in pixels from the placeholder's, and how
 * wide the two are. A pseudo-element has no box to measure, so this adds the
 * `translate` it is held at to the `left` it rests at.
 */
function highlight(): { left: number; width: number; placeholder: number } {
  const skeleton = box().querySelector<HTMLElement>('.plass-skeleton')!;
  const style = getComputedStyle(skeleton, '::after');
  const width = parseFloat(style.width);
  const [shift] = style.translate.split(' ');
  const along = shift.endsWith('%') ? (parseFloat(shift) / 100) * width : parseFloat(shift);

  return { left: parseFloat(style.left) + along, width, placeholder: skeleton.clientWidth };
}

const layoutShiftObservable =
  typeof PerformanceObserver !== 'undefined' &&
  PerformanceObserver.supportedEntryTypes.includes('layout-shift');

describe('the indeterminate sweeps', () => {
  it('move on translate and not on an inset', async () => {
    await render(<Loading />);

    for (const name of ['plass-skeleton-sweep', 'plass-progress-sweep'] as const) {
      const properties = moved(sweep(name));

      expect(properties, name).toEqual(['translate']);
    }

    // The skeleton's runs on its `::after`, so the stylesheet is what put it
    // there and not a child the component renders.
    expect((sweep('plass-skeleton-sweep').effect as KeyframeEffect).pseudoElement).toBe('::after');
  });

  // Layout Instability is a Chromium API. Firefox and WebKit have no entry type
  // to observe, and the keyframe assertion above covers them.
  it.skipIf(!layoutShiftObservable)('record no layout shift while they run', async () => {
    await render(<Loading />);

    // Two frames, so the first layout is behind us and only the sweeps move.
    for (let step = 0; step < 2; step += 1) {
      await new Promise((resolve) => requestAnimationFrame(resolve));
    }

    const shifts: PerformanceEntry[] = [];
    const observer = new PerformanceObserver((list) => {
      shifts.push(...list.getEntries());
    });

    observer.observe({ type: 'layout-shift' });
    await new Promise((resolve) => setTimeout(resolve, 1000));
    observer.disconnect();

    expect(shifts).toHaveLength(0);
  });

  describe('the direction they travel', () => {
    /** The segment's box and its groove's, held at a point in the pass. */
    function segmentAt(fraction: number): { segment: DOMRect; groove: DOMRect } {
      const run = sweep('plass-progress-sweep');
      const element = (run.effect as KeyframeEffect).target as HTMLElement;

      // The very end of a pass is the start of the next, so stop just short.
      holdAt(run, Math.min(fraction * duration(run), duration(run) - 1));

      return {
        segment: element.getBoundingClientRect(),
        groove: element.parentElement!.getBoundingClientRect()
      };
    }

    it('crosses the groove from the left edge to the right one in left-to-right', async () => {
      await render(<Loading dir="ltr" />);

      const start = segmentAt(0);

      expect(start.segment.right).toBeCloseTo(start.groove.left, 0);

      const end = segmentAt(1);

      expect(end.segment.left).toBeGreaterThan(end.groove.right - 1);
    });

    it('crosses it from the right edge to the left one in right-to-left', async () => {
      await render(<Loading dir="rtl" />);

      const start = segmentAt(0);

      expect(start.segment.left).toBeCloseTo(start.groove.right, 0);

      const end = segmentAt(1);

      expect(end.segment.right).toBeLessThan(end.groove.left + 1);
    });

    /** The highlight held at a point in the pass. */
    function highlightAt(fraction: number): ReturnType<typeof highlight> {
      const run = sweep('plass-skeleton-sweep');

      holdAt(run, Math.min(fraction * duration(run), duration(run) - 1));

      return highlight();
    }

    /** That the highlight enters past the left edge and leaves past the right. */
    function expectLeftToRight(): void {
      const start = highlightAt(0);

      expect(start.left).toBeCloseTo(-start.width, 0);

      const end = highlightAt(1);

      expect(end.left).toBeGreaterThan(end.placeholder - 1);
    }

    it('sends the skeleton highlight from the left edge to the right one', async () => {
      await render(<Loading dir="ltr" />);

      expectLeftToRight();
    });

    it('and the same way in right-to-left, where the segment turns round', async () => {
      await render(<Loading dir="rtl" />);

      expectLeftToRight();
    });
  });
});
