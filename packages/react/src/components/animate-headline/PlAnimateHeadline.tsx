'use client';

import * as React from 'react';
import { mergeProps } from '@base-ui/react/merge-props';
import { isInfinite, lengthValue, useAnimationRun } from '../../internal/animate.js';
import { usePrefersReducedMotion } from '../../internal/media.js';
import { cx } from '../../internal/styles.js';
import type { PlassAnimateProps, PlassAnimateRepeat } from '../../types.js';

export interface PlAnimateHeadlineProps
  extends Omit<PlassAnimateProps, 'alternate'>, React.ComponentPropsWithoutRef<'div'> {
  /**
   * How long each line is held before the next one comes up, in milliseconds.
   * Counted from the moment a line arrives, so it is reading time rather than a
   * cycle length.
   * @default 2600
   */
  interval?: number;
  /**
   * Which line is showing. Pass it to drive the reel yourself — from a step in
   * a form, a tab, or a timer of your own.
   */
  index?: number;
  /** Where an uncontrolled reel starts. @default 0 */
  defaultIndex?: number;
  /** Called with the line that has just come up. */
  onIndexChange?: (index: number) => void;
  /**
   * Starts again after the last line. Off, the reel stops on the last one and
   * stays there.
   * @default true
   */
  loop?: boolean;
  /**
   * How the headline stops, and nothing else. It counts neither lines nor
   * cycles: `loop` decides whether the lines start again after the last one.
   * With `trigger="hover"`, `'infinite'` stops the reel where it is when the
   * pointer and the focus leave, and a count leaves it turning after they have
   * gone. Under any other `trigger` it changes nothing.
   * @default 'infinite'
   */
  repeat?: PlassAnimateRepeat;
  /**
   * How far a line travels as it comes up or leaves — a CSS length, or a number
   * in pixels. `'100%'` is one line's own height.
   * @default '100%'
   */
  rise?: number | string;
  /** The lines, in the order they should be read. */
  children?: React.ReactNode;
}

/**
 * One line replacing the one above it, on a timer.
 *
 * Every line sits in the same grid cell, so the box is as tall as the longest of
 * them from the first frame and never resizes as the reel turns — which is the
 * whole difficulty with this effect, and the reason the lines that are not
 * showing keep their space with `visibility` rather than being taken out of the
 * layout.
 *
 * It is deliberately not a ticker. A line comes up, it stops, and it is held
 * long enough to read; `interval` is counted from the moment it arrives rather
 * than from the start of the cycle, so raising `duration` does not quietly eat
 * the reading time.
 *
 * Use it for a set of phrases where any one of them would have done — three
 * ways of saying what a product is, a rotating set of customer names. What it is
 * not for is content a reader has to see, because there is no guarantee they are
 * looking during the two seconds it is up, and a screen reader is given the line
 * that happens to be showing rather than the set.
 */
export const PlAnimateHeadline = /* @__PURE__ */ React.forwardRef<
  HTMLDivElement,
  PlAnimateHeadlineProps
>(function PlAnimateHeadline(
  {
    duration = 460,
    delay = 0,
    easing,
    repeat = 'infinite',
    paused,
    trigger = 'mount',
    play,
    once = true,
    threshold = 0.2,
    interval = 2600,
    index,
    defaultIndex = 0,
    onIndexChange,
    loop = true,
    rise = '100%',
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const run = useAnimationRun({
    trigger,
    play,
    once,
    threshold,
    paused,
    infinite: isInfinite(repeat),
    // A reel that loops on its own timer turns for ever, whatever `repeat` says,
    // so it rests off screen and its timer with it: the timer below only runs
    // while the state is `running`. Back on screen, the line it stopped on is
    // held for what was left of its wait before the next comes up.
    endless: loop && index === undefined
  });
  const reduced = usePrefersReducedMotion();

  const items = React.Children.toArray(children);
  const count = items.length;

  const [uncontrolled, setUncontrolled] = React.useState(defaultIndex);
  const active = Math.min(index ?? uncontrolled, Math.max(count - 1, 0));

  /** The line on its way out. Cleared once its animation has had its time. */
  const [leaving, setLeaving] = React.useState<number | null>(null);
  const previous = React.useRef(active);

  React.useEffect(() => {
    if (previous.current !== active) {
      setLeaving(previous.current);
      previous.current = active;
    }
  }, [active]);

  React.useEffect(() => {
    if (leaving === null) {
      return;
    }

    const timer = setTimeout(() => setLeaving(null), duration);

    return () => clearTimeout(timer);
  }, [leaving, duration]);

  const advance = React.useCallback(() => {
    const next = active + 1;

    if (next >= count) {
      if (!loop) {
        return;
      }

      if (index === undefined) {
        setUncontrolled(0);
      }

      onIndexChange?.(0);

      return;
    }

    if (index === undefined) {
      setUncontrolled(next);
    }

    onIndexChange?.(next);
  }, [active, count, loop, index, onIndexChange]);

  // The timer reads `advance` through a ref. `advance` is a new function
  // whenever an inline `onIndexChange` is, so with it among the effect's
  // dependencies a parent that renders every second restarted the timer before
  // it ever fired, and the line never changed.
  const advanceRef = React.useRef(advance);

  React.useEffect(() => {
    advanceRef.current = advance;
  });

  /**
   * The reel only turns on its own when it was not handed an `index`. A
   * controlled Headline is somebody else's timer, and a second one running
   * underneath it would fight for the same state.
   */
  const turned = React.useRef(false);

  /**
   * How much of the wait for the next line has gone by, in milliseconds, and
   * which line it is held on. The wait is measured from when it began, so the
   * timer built again after a pause or a rest off screen waits only what was
   * left of it, and a new `interval` or `delay` is waited out from when the
   * wait began, turning at once when the wait is already past it. Built again
   * with the whole wait, the reel held a line for a whole `interval` once more
   * every time it was let go, and a reel paused more often than that never
   * turned.
   */
  const waited = React.useRef({ line: active, gone: 0 });

  React.useEffect(() => {
    // Stopped rather than held: a reel started again waits the whole wait, as
    // every effect plays its run again from the start.
    if (!run.started) {
      waited.current = { line: active, gone: 0 };

      return;
    }

    if (index !== undefined || count < 2 || run.state !== 'running') {
      return;
    }

    if (!loop && active === count - 1) {
      return;
    }

    if (waited.current.line !== active) {
      waited.current = { line: active, gone: 0 };
    }

    const wait = waited.current;
    const from = performance.now();

    // `delay` is what happens before the reel starts turning at all, so it is
    // added once rather than to every line — which is what an `interval` is.
    const timer = setTimeout(
      () => {
        turned.current = true;
        advanceRef.current();
      },
      Math.max(0, interval + (turned.current ? 0 : delay) - wait.gone)
    );

    return () => {
      clearTimeout(timer);
      wait.gone += performance.now() - from;
    };
  }, [index, count, run.started, run.state, interval, delay, loop, active]);

  return (
    <div
      ref={(node) => {
        run.ref(node);

        if (typeof ref === 'function') {
          ref(node);
        } else if (ref) {
          (ref as React.RefObject<HTMLDivElement | null>).current = node;
        }
      }}
      className={cx('plass-headline', className)}
      style={
        {
          '--p-anim-duration': `${duration}ms`,
          '--p-anim-rise': lengthValue(rise),
          ...(easing ? { '--p-anim-ease': easing } : {}),
          '--p-anim-state': run.state,
          ...style
        } as React.CSSProperties
      }
      data-plass-animation="headline"
      data-state={run.state}
      {...mergeProps(props, run.handlers)}
    >
      {items.map((child, position) => {
        const state =
          position === active ? 'active' : position === leaving && !reduced ? 'leaving' : undefined;

        const childProps = React.isValidElement(child)
          ? (child.props as { className?: string })
          : null;

        const line = childProps ? (
          React.cloneElement(child as React.ReactElement<Record<string, unknown>>, {
            className: cx('plass-headline-item', childProps.className),
            'data-state': state
          })
        ) : (
          <span className="plass-headline-item" data-state={state}>
            {child}
          </span>
        );

        // A space before every line but the first. The lines are grid items,
        // so nothing between them is drawn, and a grid lays out no text that is
        // only white space; but without it the page's text ran the lines into
        // one another, and "ships on Friday" and "reads like prose" were
        // indexed as "Fridayreads".
        return (
          <React.Fragment key={position}>
            {position > 0 ? ' ' : null}
            {line}
          </React.Fragment>
        );
      })}
    </div>
  );
});
