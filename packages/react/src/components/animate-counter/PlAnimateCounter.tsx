'use client';

import * as React from 'react';
import { mergeProps } from '@base-ui/react/merge-props';
import { useRender } from '@base-ui/react/use-render';
import { useAnimationRun } from '../../internal/animate.js';
import { useLocale } from '../../internal/defaults.js';
import { usePrefersReducedMotion } from '../../internal/media.js';
import { cx, drawnCopyClasses, srOnlyClasses } from '../../internal/styles.js';
import type { PlassAnimateTrigger } from '../../types.js';

export interface PlAnimateCounterProps extends Omit<
  React.ComponentPropsWithoutRef<'span'>,
  'children'
> {
  /** The number it arrives at, and the one a screen reader is told. */
  value: number;
  /**
   * The number the first count starts from, and a replay of it: a second
   * hover, a new `play`, a `visible` trigger seen again. A new `value` counts
   * on from the figure on screen instead.
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
   * percentage or a compact `1.2M` all work. The figures on the way are written
   * with them too, and never with more decimals than the answer has.
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

/** How many fraction digits `formatter` writes `value` with. */
function fractionDigitsOf(formatter: Intl.NumberFormat, value: number): number {
  return formatter
    .formatToParts(value)
    .reduce(
      (count, part) => (part.type === 'fraction' ? count + [...part.value].length : count),
      0
    );
}

/**
 * `formatter`, or a copy of it that writes no more fraction digits than it
 * writes `value` with. What `PlAnimateCounter` draws its frames with.
 */
function frameFormatter(
  formatter: Intl.NumberFormat,
  value: number,
  locale: string | undefined,
  format: Intl.NumberFormatOptions | undefined
): Intl.NumberFormat {
  const digits = fractionDigitsOf(formatter, value);
  const resolved = formatter.resolvedOptions();
  const most = resolved.maximumFractionDigits ?? digits;

  if (most <= digits) {
    return formatter;
  }

  try {
    return new Intl.NumberFormat(locale, {
      ...format,
      minimumFractionDigits: Math.min(resolved.minimumFractionDigits ?? 0, digits),
      maximumFractionDigits: digits
    });
  } catch {
    // Options that cannot take a different number of digits, such as a
    // `roundingIncrement`, keep the caller's formatter rather than throw.
    return formatter;
  }
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
  const locale = useLocale();
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
  const formatKey = `${locale ?? ''}\u0000${JSON.stringify(format ?? null)}`;
  const held = React.useRef<{ key: string; formatter: Intl.NumberFormat } | null>(null);

  if (held.current === null || held.current.key !== formatKey) {
    held.current = { key: formatKey, formatter: new Intl.NumberFormat(locale, format) };
  }

  const formatter = held.current.formatter;
  const answer = formatter.format(value);

  /**
   * The formatter a frame on the way is written with: the caller's, holding no
   * more fraction digits than the answer shows.
   *
   * The count runs through every number in between, and the default
   * `Intl.NumberFormat` writes up to three decimals of each, so a count to
   * 4,812 showed "1,105.535" on the way: wider than the answer, which widened
   * the box it had reserved, and flickering digits a whole number never has.
   * Rounded to the answer's own digits, a count to a whole number shows whole
   * numbers and a count to 12.5 shows one decimal. Everything else the caller
   * asked for still decides how a frame is written, an explicit
   * `maximumFractionDigits` included, which stays the most a frame can show;
   * `minimumFractionDigits` is kept up to the answer's digits, so the two
   * decimals of a currency are in every frame. A formatter that already writes
   * no more than the answer, such as a compact or a percentage one, is used as
   * it is.
   *
   * `write` draws a frame with it, and draws zero where it writes `-0`.
   * `Intl.NumberFormat` keeps the sign of a negative number it rounds to zero,
   * so a count from -3 to a whole number drew "-0" for every frame between
   * -0.5 and 0, a figure no count passes through. A frame written exactly as
   * `-0` is written is one of those, whatever the style, and is drawn as zero
   * instead, as the Flutter build draws it; a frame that is really negative is
   * drawn as it is.
   */
  const frameKey = `${formatKey}\u0000${value}`;
  const framed = React.useRef<{ key: string; write: (figure: number) => string } | null>(null);

  if (framed.current === null || framed.current.key !== frameKey) {
    const frameFormat = frameFormatter(formatter, value, locale, format);
    const negativeZero = frameFormat.format(-0);
    const zero = frameFormat.format(0);

    framed.current = {
      key: frameKey,
      write: (figure) => {
        const written = frameFormat.format(figure);

        return written === negativeZero ? zero : written;
      }
    };
  }

  const frame = framed.current;

  const [shown, setShown] = React.useState(() => (still ? value : from));

  /**
   * Where the count runs from, and the props it was decided for.
   *
   * The first count starts at `from`, and so does a replay of it: a second
   * hover, a new `play`, a `visible` trigger seen again. A new `value` is a
   * figure that moved, and it counts on from the figure on screen at that
   * moment, the one the last count landed on or the frame a count still running
   * had got to, so a dashboard figure that changes counts from the old figure to
   * the new one rather than from `from` every time. A new `from` starts there.
   *
   * Decided while rendering rather than in an effect, so the frame drawn before
   * the new count's first one already counts from it. A new `value` starts its
   * run only on the render after it arrives; `pending` is what tells that run
   * apart from a replay, and `count` is what moves when a new count begins,
   * which that run is not.
   */
  const [course, setCourse] = React.useState({
    value,
    from,
    runs: run.runs,
    origin: from,
    pending: false,
    count: 0
  });

  if (course.value !== value || course.from !== from) {
    setCourse({
      value,
      from,
      runs: run.runs,
      origin: course.from !== from ? from : shown,
      pending: course.pending || course.value !== value,
      count: course.count + 1
    });
  } else if (course.runs !== run.runs) {
    setCourse(
      course.pending
        ? { ...course, runs: run.runs, pending: false }
        : { ...course, runs: run.runs, origin: from, count: course.count + 1 }
    );
  }

  const origin = course.origin;

  /**
   * How far into the run the count has got, in milliseconds and counting the
   * `delay`, outside React's state.
   *
   * Pausing tears the frame loop down and resuming builds a new one, and the
   * new one works its start time back from this. Without it, a count held at
   * 40% would drop back to its start the moment it was let go, and one held
   * while it was still waiting would wait out the whole `delay` a second time.
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

  // A new count starts at its beginning instead of going on from where the last
  // one got: a second hover, a new `play`, a new `value` or a new `from`. Keyed
  // on `course.count` rather than on `run.runs`, so the run a new `value` starts
  // on the render after it arrives goes on with the count already under way.
  React.useEffect(() => {
    elapsed.current = 0;
  }, [course.count]);

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

      setShown(origin + (value - origin) * ease.current(t));

      if (t < 1) {
        frame = requestAnimationFrame(step);
      }
    };

    frame = requestAnimationFrame(step);

    return () => cancelAnimationFrame(frame);
    // `course.count` is listed although nothing above reads it. A second hover
    // starts a new run without changing `started`, and a new run is a new count.
  }, [run.started, course.count, still, paused, value, from, origin, duration, delay]);

  // The answer is the caller's own figure and is drawn as it is written.
  const drawn = shown === value ? answer : frame.write(shown);
  // The figure the count started from, laid out under it until it lands. A
  // count down from 12,345 to 5 is as wide as its start rather than its answer,
  // and without it the box narrowed under the text around it at every digit
  // the count lost.
  const reserve = shown === value ? null : frame.write(origin);

  return useRender({
    render: render ?? <span />,
    ref: [ref, run.ref],
    props: {
      className: cx('tabular-nums', className),
      'data-plass-animation': 'counter',
      'data-state': run.state,
      children: (
        <>
          {/* The answer, once, for a reader who is not watching it arrive. It
              is the only copy that is text, so it is also the one a selection
              copies. */}
          <span className={srOnlyClasses}>{answer}</span>
          {/* The ticking figure is generated content drawn from an attribute
              rather than text, so the page's text holds the number once: in
              the server's HTML, in what a crawler indexes and in what a
              selection copies. Written out as text, the count it starts from
              was glued onto the answer, and 12,345 read as "12,3450".

              The answer is laid out under it and not drawn, so the box is as
              wide as the answer from the first paint: a count from 0 to 12,345
              used to widen it five times over, moving the text around it on
              every new digit. */}
          <span
            aria-hidden="true"
            data-text={drawn}
            data-sample={answer}
            className={drawnCopyClasses}
          >
            {reserve === null ? null : (
              <span
                data-text={reserve}
                className="invisible [grid-area:1/1] before:content-[attr(data-text)]"
              />
            )}
          </span>
        </>
      ),
      ...mergeProps(props, run.handlers)
    }
  });
});
