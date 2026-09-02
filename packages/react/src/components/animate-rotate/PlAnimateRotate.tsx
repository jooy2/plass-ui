'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, useAnimateElement } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import type { PlassAnimateMode, PlassAnimateProps, PlassAnimateStaggerProps } from '../../types.js';

export interface PlAnimateRotateProps
  extends PlassAnimateProps, PlassAnimateStaggerProps, React.ComponentPropsWithoutRef<'div'> {
  /**
   * Whether the content turns into place or out of it.
   * @default 'in'
   */
  mode?: PlassAnimateMode;
  /**
   * The angle it starts at, in degrees. Negative is anticlockwise.
   * @default -180
   */
  from?: number;
  /**
   * The angle it ends at, in degrees. Together with `from` this is what makes
   * one component cover both a quarter turn into place and an endless spin:
   * `from={0} to={360} repeat="infinite"`.
   * @default 0
   */
  to?: number;
  /**
   * Which point it turns about — any CSS `transform-origin`.
   * @default 'center'
   */
  origin?: string;
  /**
   * Fades in as it turns. Turn it off for a continuous spin, where a repeating
   * fade would read as flickering.
   * @default true
   */
  fade?: boolean;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Content turning about a point.
 *
 * Two angles rather than one, which is what lets this be both effects a
 * rotation is ever used for. `from` alone is an arrival — something swinging
 * into place and stopping. `from` and `to` together with `repeat="infinite"`
 * and `easing="linear"` is a spin that never lands, which is what a badge, a
 * loading mark or a decorative glyph wants.
 *
 * Rotation is the one movement the design language allows on a glyph without
 * argument — a chevron is turned rather than redrawn all over the library. What
 * it is not for is text: a rotated word is resampled along its whole length,
 * which is precisely what the rule against transforming a control exists to
 * prevent.
 */
export const PlAnimateRotate = /* @__PURE__ */ React.forwardRef<
  HTMLDivElement,
  PlAnimateRotateProps
>(function PlAnimateRotate(
  {
    duration = 440,
    delay = 0,
    easing,
    repeat = 1,
    alternate,
    paused,
    trigger = 'mount',
    play,
    once = true,
    threshold = 0.2,
    stagger = 0,
    durationStep = 0,
    reverse = false,
    mode = 'in',
    from = -180,
    to = 0,
    origin = 'center',
    fade = true,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const animate = useAnimateElement({
    effect: 'rotate',
    duration,
    delay,
    easing,
    repeat,
    alternate,
    mode,
    angle: `${from}deg`,
    angleTo: `${to}deg`,
    opacity: fade ? 0 : 1,
    trigger,
    play,
    once,
    threshold,
    paused,
    infinite: isInfinite(repeat),
    // The origin travels with the effect: staggered, it is each child that
    // turns, and `transform-origin` is not an inherited property.
    origin,
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
