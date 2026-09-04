'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { useAnimationRun } from '../../internal/animate.js';
import { useDefaults } from '../../internal/defaults.js';
import { usePrefersReducedMotion } from '../../internal/media.js';
import { cx, srOnlyClasses } from '../../internal/styles.js';
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

  const formatter = React.useMemo(
    () => new Intl.NumberFormat(defaults.locale, format),
    [defaults.locale, format]
  );

  const [shown, setShown] = React.useState(() => (still ? value : from));

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
      setShown(from);

      return undefined;
    }

    if (paused) {
      return undefined;
    }

    let frame = 0;
    let start = 0;

    const step = (now: number) => {
      start ||= now;

      const t = Math.min(1, (now - start - delay) / Math.max(1, duration));

      if (t < 0) {
        frame = requestAnimationFrame(step);

        return;
      }

      setShown(from + (value - from) * easing(t));

      if (t < 1) {
        frame = requestAnimationFrame(step);
      }
    };

    frame = requestAnimationFrame(step);

    return () => cancelAnimationFrame(frame);
  }, [run.started, still, paused, value, from, duration, delay, easing]);

  const answer = formatter.format(value);

  return useRender({
    render: render ?? <span />,
    ref: [ref, run.ref],
    props: {
      className: cx('tabular-nums', className),
      ...run.handlers,
      'data-plass-animation': 'counter',
      'data-state': run.state,
      children: (
        <>
          {/* The answer, once, for a reader who is not watching it arrive. */}
          <span className={srOnlyClasses}>{answer}</span>
          <span aria-hidden="true">{formatter.format(shown)}</span>
        </>
      ),
      ...props
    }
  });
});
