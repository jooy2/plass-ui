'use client';

import * as React from 'react';
import { mergeProps } from '@base-ui/react/merge-props';
import { useRender } from '@base-ui/react/use-render';
import {
  animBaseClass,
  animationClasses,
  animationSlots,
  isInfinite,
  revealClip,
  slideOffsets,
  staggerSlots,
  useAnimationRun,
  type AnimationSlotOptions
} from '../../internal/animate.js';
import { cx, srOnlyClasses } from '../../internal/styles.js';
import { graphemesOf } from '../../internal/text.js';
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
   * Which of the entrances each part plays. A part starts where the component
   * of that name starts when it is given nothing, so a `slide` part rises from
   * its own height below and a `zoom` part grows from 0.4.
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

/**
 * A character of a script written without spaces between its words, such as
 * Chinese, Japanese or Thai. Running text in one of these may wrap between any
 * two characters, and so may a split line.
 */
const unspacedScript =
  /[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Bopomofo}\p{Script=Thai}\p{Script=Lao}\p{Script=Khmer}\p{Script=Myanmar}]/u;

/**
 * The line as the pieces it may wrap between, with the gaps left between them
 * as gaps, and each piece as the parts it arrives in.
 *
 * Cut by word, a piece is one word. Cut by character, it is a run of a word's
 * characters that stays on one line together: a character of a script written
 * without spaces starts a piece of its own, so such a line still wraps between
 * its characters, and anything else stays with the character before it, which
 * keeps a Latin or Hangul word whole and a full stop beside the ideograph it
 * closes.
 *
 * A character is a **grapheme**, what a reader counts as one, so an emoji, a
 * flag or a letter with its accent is one part rather than the pieces it is
 * built out of.
 */
function piecesOf(text: string, by: PlAnimateSplitBy): string[][] {
  const pieces: string[][] = [];

  // The separators are kept, so a run of spaces or a newline survives being cut
  // up and the line reflows exactly as it did before.
  for (const word of text.split(/(\s+)/)) {
    if (word === '') {
      continue;
    }

    if (by === 'word' || word.trim() === '') {
      pieces.push([word]);

      continue;
    }

    let piece: string[] = [];

    for (const character of graphemesOf(word)) {
      if (piece.length === 0 || unspacedScript.test(character)) {
        piece = [character];
        pieces.push(piece);
      } else {
        piece.push(character);
      }
    }
  }

  return pieces;
}

/**
 * Where a part starts, which is where the component of the same name starts
 * when it is given nothing.
 *
 * Written out rather than left to the keyframes, whose fallbacks are not all
 * those defaults: the slide keyframe falls back to no travel at all, and the
 * scale keyframe serves both Grow and Zoom, so its fallback can only be one of
 * them. `100%` of a part is its own height, so a sliding word rises by a line.
 */
function effectStart(effect: PlassAnimation): Partial<AnimationSlotOptions> {
  switch (effect) {
    case 'slide':
      return { opacity: 0, ...slideOffsets('bottom', '100%') };
    case 'grow':
      return { opacity: 0, scale: 0.8 };
    case 'zoom':
      return { opacity: 0, scale: 0.4 };
    case 'rotate':
      return { opacity: 0, angle: '-180deg', angleTo: '0deg' };
    case 'reveal':
      return { opacity: 1, clip: revealClip('left') };
    default:
      return { opacity: 0 };
  }
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
 * letters, so Arabic stops joining. A character is a grapheme, what a reader
 * counts as one, so an emoji, a flag or a Devanagari conjunct stays in one
 * part. `word` keeps the shaping, is the default, and is what a headline wants
 * anyway.
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
  const pieces = React.useMemo(() => piecesOf(children, by), [children, by]);

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

  const slots: AnimationSlotOptions = {
    ...effectStart(effect),
    duration,
    delay,
    easing,
    repeat,
    alternate,
    mode,
    timeline,
    range
  };
  const count = pieces.reduce(
    (total, piece) => (piece[0].trim() === '' ? total : total + piece.length),
    0
  );
  const partClass = `${animBaseClass} ${animationClasses[effect]}`;

  // The step counts across the whole line rather than within a word, so the
  // first character of a word follows the last character of the word before.
  let step = -1;

  const renderPart = (part: string, key: number) => {
    step += 1;

    return (
      // `inline-block`, because a transform does not apply to a non-replaced
      // inline element — the part would fade and never move.
      <span
        key={key}
        className={`${partClass} inline-block whitespace-pre`}
        style={
          {
            ...animationSlots(
              staggerSlots(slots, { index: step, count, stagger, durationStep, reverse })
            ),
            '--p-anim-state': run.state
          } as React.CSSProperties
        }
      >
        {part}
      </span>
    );
  };

  return useRender({
    render: render ?? <span />,
    ref: [ref, run.ref],
    props: {
      ...mergeProps(props, run.handlers),
      className: cx(className),
      style,
      'data-plass-animation': effect,
      'data-state': run.state,
      children: (
        <>
          {/* The line, once, rather than one announcement per part. */}
          <span className={srOnlyClasses}>{children}</span>
          <span aria-hidden="true">
            {pieces.map((piece, index) => {
              // A separator is a gap and is left as one: giving whitespace an
              // entrance would animate the space between two words, which is
              // nothing arriving — and it must not take a step of the stagger
              // with it either.
              if (piece[0].trim() === '') {
                return <React.Fragment key={index}>{piece[0]}</React.Fragment>;
              }

              if (piece.length === 1) {
                return renderPart(piece[0], index);
              }

              // Several characters that stay on one line together sit in one
              // more inline-block. A line may wrap before and after every
              // inline-block, so left loose they would wrap partway through a
              // word. The box is as wide as the word, or as the line when the
              // word is wider, so the word moves down whole and wraps inside
              // itself only when it could not fit on any line.
              return (
                <span key={index} className="inline-block">
                  {piece.map((part, place) => renderPart(part, place))}
                </span>
              );
            })}
          </span>
        </>
      )
    }
  });
});
