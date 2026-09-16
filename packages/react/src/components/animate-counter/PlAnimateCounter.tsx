'use client';

import * as React from 'react';
import { mergeProps } from '@base-ui/react/merge-props';
import { useRender } from '@base-ui/react/use-render';
import { useAnimationRun } from '../../internal/animate.js';
import { useDefaults } from '../../internal/defaults.js';
import { usePrefersReducedMotion } from '../../internal/media.js';
import { cx, srOnlyCopyClasses } from '../../internal/styles.js';
import type { PlassAnimateTrigger } from '../../types.js';

export interface PlAnimateCounterProps extends Omit<
  React.ComponentPropsWithoutRef<'span'>,
  'children'
> {
  /** The number it arrives at, and the one a screen reader is told. */
  value: number;
  /**
   * The number it starts from.
   * @default 0
   */
  from?: number;
  /**
   * How long the count takes, in milliseconds.
   * @default 1200
   */
  duration?: number;
  /** How long it waits before starting, in milliseconds. @default 0 */
  delay?: number;
  /**
   * How the number is written — `Intl.NumberFormat` options, so a currency, a
   * percentage or a compact `1.2M` all work.
   *
   * This is the reason the count is JavaScript rather than a `@property` and a
   * CSS counter, which is otherwise the neater way to animate a number: CSS can
   * tick a value, and it cannot put a thousands separator in one.
   */
  format?: Intl.NumberFormatOptions;
  /**
   * The shape of the count, as a function from `0`…`1` to `0`…`1`.
   *
   * A function rather than a CSS easing string, and not for want of trying: no
   * CSS animation is running here, so there is nothing to hand a string to. It
   * eases out by default, which is what a number arriving should do — quick
   * enough to read as counting, slow enough at the end to land on the figure
   * rather than snap to it.
   */
  easing?: (t: number) => number;
  /**
   * What starts the count.
   *
   * **`visible` by default**, and it is the one component in the library that
   * does not start on mount. That is deliberate rather than an oversight: an
   * entrance played off screen has still delivered its content, and a count
   * that ran off screen delivered a number that was simply already there. A
   * counter is the one effect whose whole point is being watched.
   * @default 'visible'
   */
  trigger?: PlassAnimateTrigger;
  /** Runs it, when `trigger` is `manual`. */
  play?: boolean;
  /** With `visible`, whether it counts only the first time. @default true */
  once?: boolean;
  /** With `visible`, how much has to be on screen to count. @default 0.2 */
  threshold?: number;
  /** Holds the count where it is. */
  paused?: boolean;
  /** Renders something other than a `<span>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
}

/** Quick to read as counting, slow enough at the end to land on the figure. */
function easeOut(t: number): number {
  return 1 - (1 - t) ** 3;
}

/**
 * A number counting up to what it is.
 *
 * The one effect in the group that animates **content** rather than a box: what
 * moves is the figure itself, one frame at a time, from `from` to `value`.
 *
 * It is JavaScript and not a keyframe, and the reason is formatting. A
 * registered custom property and a CSS counter can tick a number perfectly
 * well — and cannot put a thousands separator in one, or a currency symbol, or
 * fold 1,200,000 into `1.2M`. A counter that cannot be formatted is a counter
 * nobody can use on a dashboard, so `Intl.NumberFormat` decides what is drawn
 * and the frame loop only decides which number it is drawing.
 *
 * **It starts when it is seen, not when it mounts**, which is the one place a
 * `PlAnimate*` here departs from the rest. An entrance played off screen has
 * still delivered its content; a count that ran off screen delivered a number
 * that was already sitting there when the reader arrived.
 *
 * **What a screen reader hears is the final number, once.** The ticking figure
 * is `aria-hidden` and the answer is beside it in a clipped span, because a
 * number changing sixty times a second in the accessibility tree is either
 * silence or sixty announcements, and neither is the figure.
 */
export const PlAnimateCounter = /* @__PURE__ */ React.forwardRef<
  HTMLSpanElement,
  PlAnimateCounterProps
>(function PlAnimateCounter(
  {
    value,
    from = 0,
    duration = 1200,
    delay = 0,
    format,
    easing = easeOut,
    trigger = 'visible',
    play,
    once = true,
    threshold = 0.2,
    paused,
    render,
    className,
    ...props
  },
  ref
) {
  const defaults = useDefaults();
  const still = usePrefersReducedMotion();

  const run = useAnimationRun({
    trigger,
    play,
    once,
    threshold,
    paused,
    infinite: false,
    // A new target is a new count, wherever the old one had got to.
    nonce: value
  });

  /**
   * One `Intl.NumberFormat`, built again only when the options really differ.
   *
   * `format` is an options object, and one written inline — which is how the
   * prop reads best — is a new reference on every render. While the count is
   * running that is every frame, so memoising on the object itself built sixty
   * formatters a second. The key is what the options say rather than which
   * object said it.
   */
  const formatKey = `${defaults.locale ?? ''}\u0000${JSON.stringify(format ?? null)}`;
  const held = React.useRef<{ key: string; formatter: Intl.NumberFormat } | null>(null);

  if (held.current === null || held.current.key !== formatKey) {
    held.current = { key: formatKey, formatter: new Intl.NumberFormat(defaults.locale, format) };
  }

  const formatter = held.current.formatter;

  const [shown, setShown] = React.useState(() => (still ? value : from));

  /**
   * How far into the run the count has got, in milliseconds and counting the
   * `delay`, outside React's state.
   *
   * Pausing tears the frame loop down and resuming builds a new one, and the
   * new one works its start time back from this. Without it, a count held at
   * 40% would drop back to `from` the moment it was let go, and one held while
   * it was still waiting would wait out the whole `delay` a second time.
   */
  const elapsed = React.useRef(0);

  /**
   * The `easing` of the latest render, read by the loop rather than listed in
   * its dependencies. An inline `easing={(t) => t}` is a new function every
   * time the parent renders, and restarting the loop for each one would stall
   * the count inside a parent that renders often.
   */
  const ease = React.useRef(easing);

  React.useEffect(() => {
    ease.current = easing;
  });

  // A new count starts from `from` instead of going on from where the last one
  // got: a second hover, a new `play`, a new `value` or a new `from`. The two
  // props are listed beside `run.runs` because a new `value` starts its run only
  // on the render after it arrives, and a frame drawn in between would put the
  // new figure at the old count's progress.
  React.useEffect(() => {
    elapsed.current = 0;
  }, [run.runs, value, from]);

  React.useEffect(() => {
    // A reader who asked for less movement gets the figure and nothing else,
    // which is the only thing the count was carrying.
    if (still) {
      setShown(value);

      return undefined;
    }

    // Not started is the *first frame*, exactly as it is for every keyframe
    // here: a counter waiting to be scrolled to shows the number it is about to
    // count from, not the one it is about to reach.
    if (!run.started) {
      elapsed.current = 0;
      setShown(from);

      return undefined;
    }

    if (paused) {
      return undefined;
    }

    const span = Math.max(1, duration);
    let frame = 0;
    let start: number | undefined;

    const step = (now: number) => {
      // A count that was held goes on from where it stopped, whether it was
      // counting or still waiting: what is left of `delay` is what is left of
      // it, not the whole wait again.
      start ??= now - elapsed.current;
      elapsed.current = now - start;

      const t = Math.min(1, (elapsed.current - delay) / span);

      if (t < 0) {
        frame = requestAnimationFrame(step);

        return;
      }

      setShown(from + (value - from) * ease.current(t));

      if (t < 1) {
        frame = requestAnimationFrame(step);
      }
    };

    frame = requestAnimationFrame(step);

    return () => cancelAnimationFrame(frame);
    // `run.runs` is listed although nothing above reads it. A second hover starts
    // a new run without changing `started`, and a new run is a new count.
  }, [run.started, run.runs, still, paused, value, from, duration, delay]);

  const answer = formatter.format(value);

  return useRender({
    render: render ?? <span />,
    ref: [ref, run.ref],
    props: {
      className: cx('tabular-nums', className),
      'data-plass-animation': 'counter',
      'data-state': run.state,
      children: (
        <>
          {/* The answer, once, for a reader who is not watching it arrive. */}
          <span className={srOnlyCopyClasses}>{answer}</span>
          <span aria-hidden="true">{formatter.format(shown)}</span>
        </>
      ),
      ...mergeProps(props, run.handlers)
    }
  });
});
