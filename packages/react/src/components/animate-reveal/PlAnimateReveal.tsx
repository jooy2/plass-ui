'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, revealClip, useAnimateElement } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import type {
  PlassAnimateMode,
  PlassAnimateProps,
  PlassAnimateStaggerProps,
  PlassAnimateTimelineProps,
  PlassSide
} from '../../types.js';

export interface PlAnimateRevealProps
  extends
    PlassAnimateProps,
    PlassAnimateStaggerProps,
    PlassAnimateTimelineProps,
    React.ComponentPropsWithoutRef<'div'> {
  /**
   * Whether the content is uncovered or covered again. `out` is the same wipe
   * run backwards, so it closes from the edge it opened towards.
   * @default 'in'
   */
  mode?: PlassAnimateMode;
  /**
   * Which edge the wipe starts at. Physical, as `PlassSide` is everywhere — a
   * heading uncovered from the top is uncovered from the top in every writing
   * direction.
   * @default 'left'
   */
  from?: PlassSide;
  /**
   * Fades in behind the wipe.
   *
   * **Off by default**, which is the opposite of every other effect here and is
   * the whole point of this one: a reveal is not a fade. Turn it on only if you
   * want both.
   * @default false
   */
  fade?: boolean;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Content uncovered behind a moving edge.
 *
 * The only entrance in the set where **nothing moves and no colour changes**.
 * A fade changes the ink, a slide changes the position, a grow changes the
 * size; this changes how much of the element is drawn and leaves every pixel it
 * has drawn exactly where it will finally be. That makes it the effect for
 * anything whose position is itself the information — a heading over the
 * paragraph it belongs to, a rule between two sections, the plot area of a
 * chart, a row of figures that must not be read from the wrong place.
 *
 * It is also the cheapest entrance in the set to lay out, because there is
 * nothing to lay out: no wrapper, no `overflow` box, no second element in the
 * flow. `clip-path` paints less of the element and the page around it never
 * learns that anything happened.
 *
 * `fade` is off by default, alone among the effects that offer it. Fading a
 * reveal is asking for two entrances at once, and the reason to have reached
 * for this one is usually that the first was the problem.
 */
export const PlAnimateReveal = /* @__PURE__ */ React.forwardRef<
  HTMLDivElement,
  PlAnimateRevealProps
>(function PlAnimateReveal(
  {
    duration = 520,
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
    stagger = 0,
    durationStep = 0,
    reverse = false,
    mode = 'in',
    from = 'left',
    fade = false,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const animate = useAnimateElement({
    effect: 'reveal',
    duration,
    delay,
    easing,
    repeat,
    alternate,
    mode,
    clip: revealClip(from),
    opacity: fade ? 0 : 1,
    trigger,
    play,
    once,
    threshold,
    paused,
    infinite: isInfinite(repeat),
    timeline,
    range,
    stagger,
    durationStep,
    reverse,
    children
  });

  return useRender({
    render,
    ref: [ref, animate.ref],
    props: {
      ...props,
      className: cx(animate.className, className),
      style: { ...animate.style, ...style },
      ...animate.props,
      children: animate.children
    }
  });
});
