'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { useAnimationRun } from '../../internal/animate.js';
import { usePrefersReducedMotion } from '../../internal/media.js';
import { poolOf, scrambleAt } from '../../internal/scramble.js';
import { cx, srOnlyClasses } from '../../internal/styles.js';
import type { PlassAnimateTrigger } from '../../types.js';

export interface PlAnimateScrambleProps extends Omit<
  React.ComponentPropsWithoutRef<'span'>,
  'children'
> {
  /**
   * The line that resolves. A string, and it has to be: the effect works on
   * characters, and there is no character in a `<strong>`.
   */
  children: string;
  /**
   * The glyphs the unsettled characters are drawn from.
   *
   * Left out, it is **the line's own characters**. Every scrambler that ships a
   * default alphabet ships an English one, and English noise over a Korean or a
   * Greek headline is a different script flickering rather than a word
   * arriving. Set it for the caller who genuinely wants a terminal look.
   */
  characters?: string;
  /**
   * How long the line takes to settle, in milliseconds.
   * @default 1200
   */
  duration?: number;
  /** How long it waits before starting, in milliseconds. @default 0 */
  delay?: number;
  /**
   * How often the unsettled characters are redrawn, in milliseconds.
   *
   * Not every frame, on purpose. At sixty a second a line of changing glyphs
   * strobes, which is unpleasant to look at and is the kind of flicker a
   * reader with a sensitivity to it should never be handed.
   * @default 45
   */
  tick?: number;
  /**
   * What starts it. `visible` for `PlAnimateCounter`'s reason: a line that
   * resolved off screen delivered text that was simply already there.
   * @default 'visible'
   */
  trigger?: PlassAnimateTrigger;
  /** Runs it, when `trigger` is `manual`. */
  play?: boolean;
  /** With `visible`, whether it runs only the first time. @default true */
  once?: boolean;
  /** With `visible`, how much has to be on screen to count. @default 0.2 */
  threshold?: number;
  /** Holds it where it is. */
  paused?: boolean;
  /** Renders something other than a `<span>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
}

/**
 * A line of text resolving out of noise.
 *
 * The second of the two effects that animate **content** rather than a box, and
 * it takes a `string` rather than a node for the same reason a
 * [PlAnimateCounter](./animate-counter) takes a number: there is no character
 * to scramble inside a `<strong>`.
 *
 * **The noise is made of the line's own characters.** Every scrambler that
 * ships a default alphabet ships an English one, and English noise over a
 * Korean, Greek or Arabic headline is not a word arriving — it is a different
 * script flickering where a word is about to be. Shuffling the string's own
 * glyphs costs nothing and is right in every script; it also keeps the line's
 * colour and width steady, because every frame is drawn out of exactly the
 * characters the finished line is made of.
 *
 * It settles **left to right**, which is what makes it read as a word arriving
 * rather than as a slot machine, and whitespace is never scrambled — the gaps
 * between words are what keeps a line of noise looking like a sentence.
 *
 * **A screen reader is told the line, once**, and never the noise. Everything a
 * `PlAnimateCounter` says about that applies here word for word.
 */
export const PlAnimateScramble = /* @__PURE__ */ React.forwardRef<
  HTMLSpanElement,
  PlAnimateScrambleProps
>(function PlAnimateScramble(
  {
    children,
    characters,
    duration = 1200,
    delay = 0,
    tick = 45,
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
  const still = usePrefersReducedMotion();

  const run = useAnimationRun({
    trigger,
    play,
    once,
    threshold,
    paused,
    infinite: false,
    // A new line is a new run, however far the old one had settled.
    nonce: children
  });

  const pool = React.useMemo(() => characters ?? poolOf(children), [characters, children]);
  const [shown, setShown] = React.useState(() => children);

  React.useEffect(() => {
    if (still) {
      setShown(children);

      return undefined;
    }

    // Not started is the first frame: a line waiting to be scrolled to is
    // already noise, not already settled.
    if (!run.started) {
      setShown(scrambleAt(children, pool, 0, 0));

      return undefined;
    }

    if (paused) {
      return undefined;
    }

    const started = performance.now();
    let frame = 0;
    let seed = 0;
    let painted = -1;

    const step = (now: number) => {
      const elapsed = now - started - delay;
      const progress = Math.min(1, elapsed / Math.max(1, duration));
      const slot = Math.floor(Math.max(0, elapsed) / Math.max(1, tick));

      if (slot !== painted) {
        painted = slot;
        seed += 1;
        setShown(scrambleAt(children, pool, Math.max(0, progress), seed));
      }

      if (progress < 1) {
        frame = requestAnimationFrame(step);
      } else {
        setShown(children);
      }
    };

    frame = requestAnimationFrame(step);

    return () => cancelAnimationFrame(frame);
  }, [run.started, still, paused, children, pool, duration, delay, tick]);

  return useRender({
    render: render ?? <span />,
    ref: [ref, run.ref],
    props: {
      className: cx(className),
      ...run.handlers,
      'data-plass-animation': 'scramble',
      'data-state': run.state,
      children: (
        <>
          {/* The line, once, for a reader who is not watching it settle. */}
          <span className={srOnlyClasses}>{children}</span>
          <span aria-hidden="true">{shown}</span>
        </>
      ),
      ...props
    }
  });
});
