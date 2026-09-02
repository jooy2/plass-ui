'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  animBaseClass,
  animateChildren,
  animationClasses,
  animationSlots,
  isInfinite,
  slideOffsets,
  staggerSlots,
  useAnimationRun
} from '../../internal/animate.js';
import type { PlassAnimateProps, PlassSide } from '../../types.js';

export interface PlAnimateAppearProps
  extends PlassAnimateProps, React.ComponentPropsWithoutRef<'div'> {
  /**
   * How long after one child the next one starts, in milliseconds. This is the
   * whole effect — everything else is what a single child does.
   *
   * The same prop the six single-keyframe effects take, and the same machinery
   * under it; what differs is the default, because a stagger of `0` on a set is
   * a set that is not a set.
   * @default 70
   */
  stagger?: number;
  /**
   * Milliseconds added to each child's duration, so later children take longer
   * — or, negative, less long. Floored at `0`.
   * @default 0
   */
  durationStep?: number;
  /**
   * Which edge each child drifts in from.
   * @default 'bottom'
   */
  from?: PlassSide;
  /**
   * How far each child travels. Short on purpose: this is a settling, not an
   * entrance from off screen, and a long travel over a list of eight turns the
   * whole block into something moving.
   * @default '0.75rem'
   */
  distance?: number | string;
  /**
   * Fades each child in as it settles.
   * @default true
   */
  fade?: boolean;
  /**
   * Runs the list from the last child to the first.
   * @default false
   */
  reverse?: boolean;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  /** The things that appear, one after another. */
  children?: React.ReactNode;
}

/**
 * A list of things settling into place one after another.
 *
 * Each child takes the same short drift and fade, held back by its position — so
 * the effect belongs to the *set* rather than to any one item, and a reader's
 * eye is walked down the list in the order it should be read.
 *
 * The animation is written onto the children themselves rather than onto
 * wrappers around them. A row of `<li>`s stays a row of `<li>`s, a grid's cells
 * stay its direct children, and nothing about the layout changes because the
 * list is being animated. Only a bare string has no element to write onto, so
 * that one is wrapped in a `<span>`.
 *
 * The stagger is per *child*, which means what you pass matters: eight children
 * are eight steps, and one child holding eight things is one step. That is also
 * how to opt part of a list out — group it.
 */
export const PlAnimateAppear = /* @__PURE__ */ React.forwardRef<
  HTMLDivElement,
  PlAnimateAppearProps
>(function PlAnimateAppear(
  {
    duration = 380,
    delay = 0,
    easing,
    repeat = 1,
    alternate,
    paused,
    trigger = 'mount',
    play,
    once = true,
    threshold = 0.2,
    stagger = 70,
    durationStep = 0,
    from = 'bottom',
    distance = '0.75rem',
    fade = true,
    reverse = false,
    render,
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
    infinite: isInfinite(repeat)
  });

  const { x, y } = slideOffsets(from, distance);

  // The same helper the six single-keyframe effects reach for when they are
  // given a `stagger`. It used to live here and only here, which meant the
  // library was one prop away from having two staggers in it.
  const animated = animateChildren(
    children,
    `${animBaseClass} ${animationClasses.slide}`,
    (index, count) =>
      animationSlots(
        staggerSlots(
          { duration, delay, easing, repeat, alternate, x, y, opacity: fade ? 0 : 1 },
          { index, count, stagger, durationStep, reverse }
        )
      )
  );

  return useRender({
    render,
    ref: [ref, run.ref],
    props: {
      ...props,
      className,
      // Only the play state lives on the root. Every other slot is per child,
      // because the delay is what the whole effect is made of.
      style: { '--p-anim-state': run.state, ...style } as React.CSSProperties,
      ...run.handlers,
      'data-plass-animation': 'appear',
      'data-state': run.state,
      children: animated
    }
  });
});
