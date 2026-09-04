'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  animBaseClass,
  animationClasses,
  animationSlots,
  isInfinite,
  staggerSlots,
  useAnimationRun
} from '../../internal/animate.js';
import { cx, srOnlyClasses } from '../../internal/styles.js';
import type {
  PlassAnimateMode,
  PlassAnimateProps,
  PlassAnimateStaggerProps,
  PlassAnimateTimelineProps,
  PlassAnimation
} from '../../types.js';

/** What the line is cut into before the effect is told off across it. */
export type PlAnimateSplitBy = 'word' | 'character';

export interface PlAnimateSplitProps
  extends
    PlassAnimateProps,
    PlassAnimateStaggerProps,
    PlassAnimateTimelineProps,
    Omit<React.ComponentPropsWithoutRef<'span'>, 'children'> {
  /**
   * The line. A string, and it has to be: the component cuts it up, and there
   * is nothing to cut inside a `<strong>`.
   */
  children: string;
  /**
   * What it is cut into.
   *
   * `word` by default, and it is the safe one. See the note on the page about
   * `character` and the scripts it must not be used on.
   * @default 'word'
   */
  by?: PlAnimateSplitBy;
  /**
   * Which of the entrances each part plays.
   * @default 'fade'
   */
  effect?: PlassAnimation;
  /**
   * `in` plays the entrance; `out` is the same run backwards, held at the end.
   * @default 'in'
   */
  mode?: PlassAnimateMode;
  /** Renders something other than a `<span>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
}

/** The parts, with the gaps left between them as gaps. */
function partsOf(text: string, by: PlAnimateSplitBy): string[] {
  if (by === 'character') {
    return Array.from(text);
  }

  // The separators are kept, so a run of spaces or a newline survives being cut
  // up and the line reflows exactly as it did before.
  return text.split(/(\s+)/).filter((part) => part !== '');
}

/**
 * A line of text arriving one part at a time.
 *
 * The other five effects tell themselves off across their **children**, which a
 * line of text does not have. This one makes them: it cuts the string into
 * words or characters, wraps each in a span, and hands the set to exactly the
 * same `stagger` machinery a `PlAnimateFade` around a list of `<li>`s uses. So
 * `effect`, `stagger`, `durationStep` and `reverse` all mean what they mean
 * everywhere else — this component is the splitting and nothing more.
 *
 * **`by="character"` is not safe in every script**, and that is the one thing
 * to know before reaching for it. A character span breaks the shaping between
 * letters, so Arabic stops joining, Devanagari conjuncts come apart, and an
 * emoji built out of several code points is cut into its pieces. `word` has
 * none of those problems, is the default, and is what a headline wants anyway.
 *
 * **A screen reader is told the line, once.** The parts are hidden from the
 * accessibility tree and the whole line sits beside them in a clipped span,
 * which is what stops a split headline being read out one letter at a time —
 * the defect this pattern is known for.
 */
export const PlAnimateSplit = /* @__PURE__ */ React.forwardRef<
  HTMLSpanElement,
  PlAnimateSplitProps
>(function PlAnimateSplit(
  {
    children,
    by = 'word',
    effect = 'fade',
    mode = 'in',
    duration = 400,
    delay = 0,
    easing,
    repeat = 1,
    alternate,
    paused,
    trigger = 'mount',
    play,
    once = true,
    threshold = 0.2,
    timeline,
    range,
    stagger = 40,
    durationStep = 0,
    reverse = false,
    render,
    className,
    style,
    ...props
  },
  ref
) {
  const parts = React.useMemo(() => partsOf(children, by), [children, by]);

  // `useAnimationRun` directly rather than `useAnimateElement`, which is the
  // arrangement `internal/animate.ts` describes for the components that have to
  // understand their own children. Here the reason is the counting: a separator
  // is a child and must not take a step of the stagger with it, or the second
  // word would arrive two steps late.
  const run = useAnimationRun({
    trigger: timeline === 'view' ? 'mount' : trigger,
    play,
    once,
    threshold,
    paused,
    infinite: isInfinite(repeat)
  });

  const slots = { duration, delay, easing, repeat, alternate, mode, timeline, range };
  const count = parts.filter((part) => part.trim() !== '').length;
  const partClass = `${animBaseClass} ${animationClasses[effect]}`;

  let step = -1;

  return useRender({
    render: render ?? <span />,
    ref: [ref, run.ref],
    props: {
      ...props,
      className: cx(className),
      style,
      ...run.handlers,
      'data-plass-animation': effect,
      'data-state': run.state,
      children: (
        <>
          {/* The line, once, rather than one announcement per part. */}
          <span className={srOnlyClasses}>{children}</span>
          <span aria-hidden="true">
            {parts.map((part, index) => {
              // A separator is a gap and is left as one: giving whitespace an
              // entrance would animate the space between two words, which is
              // nothing arriving — and it must not take a step of the stagger
              // with it either.
              if (part.trim() === '') {
                return <React.Fragment key={index}>{part}</React.Fragment>;
              }

              step += 1;

              return (
                // `inline-block`, because a transform does not apply to a
                // non-replaced inline element — the part would fade and never
                // move.
                <span
                  key={index}
                  className={`${partClass} inline-block whitespace-pre`}
                  style={
                    {
                      ...animationSlots(
                        staggerSlots(slots, {
                          index: step,
                          count,
                          stagger,
                          durationStep,
                          reverse
                        })
                      ),
                      '--p-anim-state': run.state
                    } as React.CSSProperties
                  }
                >
                  {part}
                </span>
              );
            })}
          </span>
        </>
      )
    }
  });
});
