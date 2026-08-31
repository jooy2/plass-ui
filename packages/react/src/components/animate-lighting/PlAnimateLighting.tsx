'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, useAnimateElement } from '../../internal/animate.js';
import { cx, radiusClasses } from '../../internal/styles.js';
import type { PlassAnimateProps, PlassColor, PlassSize } from '../../types.js';

export interface PlAnimateLightingProps
  extends PlassAnimateProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Which family the light is drawn in. The arc turns between that family's two
   * ends as it travels, exactly as a `solid` fill does.
   * @default 'primary'
   */
  color?: PlassColor;
  /**
   * A CSS colour, when a semantic family is not what is wanted. Overrides
   * `color`, and the arc stops turning — one colour has nowhere to turn to.
   */
  glow?: string;
  /**
   * The radius the light follows, on the shared ladder. It has to match what is
   * inside, or the glow will cut a corner the content has rounded off.
   * @default 'md'
   */
  size?: PlassSize;
  /**
   * How far past the content the light reaches, in pixels.
   * @default 3
   */
  spread?: number;
  /**
   * How much of the outline is lit at once, in degrees. Small is a travelling
   * spark; large is a sweep.
   * @default 50
   */
  arc?: number;
  /**
   * How soft the light is, in pixels. At `0` it is a hard-edged wedge, which
   * reads as a graphic rather than as light.
   * @default 5
   */
  blur?: number;
  /** Runs the light the other way round. @default false */
  reverse?: boolean;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * A light travelling around the outside of something.
 *
 * The light is **behind** the content rather than on it, so what a reader sees
 * is a glow escaping from under the edges — which is why it works on a PlCard
 * or a PlButton without touching anything about how they are drawn. Nothing
 * inside is altered, nothing is overlaid, and the content stays exactly as
 * legible as it was.
 *
 * The arc itself is a gradient that turns between the two ends of the family,
 * which is the same rule every filled surface in the library follows: a flat
 * coloured arc would be paint, and nothing here is paint.
 *
 * Use it to mark the one thing on a screen that is currently live — the row
 * that is processing, the field being checked, the plan being recommended. It
 * draws attention with light rather than by moving anything, which is the only
 * way this library has of saying "here" without also saying "and it moved".
 *
 * `size` has to agree with the radius of what is inside it. The glow follows
 * the wrapper's own corners, so an `lg` card in an `xs` Lighting will show light
 * poking out of four corners the card has already rounded away.
 */
export const PlAnimateLighting = /* @__PURE__ */ React.forwardRef<
  HTMLDivElement,
  PlAnimateLightingProps
>(function PlAnimateLighting(
  {
    duration = 3000,
    delay = 0,
    easing,
    repeat = 'infinite',
    alternate,
    paused,
    trigger = 'mount',
    play,
    once = true,
    threshold = 0.2,
    color: colorProp,
    glow,
    size: sizeProp,
    spread = 3,
    arc = 50,
    blur = 5,
    reverse = false,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const defaults = useDefaults();
  const color = colorProp ?? defaults.color ?? 'primary';
  const size = sizeProp ?? defaults.size ?? 'md';

  const animate = useAnimateElement({
    // The keyframe runs on a pseudo-element rather than on the root, so there
    // is no effect class to apply here — only the slots it reads.
    effect: null,
    duration,
    delay,
    easing,
    repeat,
    alternate,
    mode: reverse ? 'out' : 'in',
    trigger,
    play,
    once,
    threshold,
    paused,
    infinite: isInfinite(repeat)
  });

  return useRender({
    render,
    ref: [ref, animate.ref],
    props: {
      ...props,
      className: cx('plass-anim-lighting', radiusClasses[size], className),
      style: {
        ...animate.style,
        '--p-anim-glow-from': glow ?? `var(--plass-${color}-solid)`,
        '--p-anim-glow-to': glow ?? `var(--plass-${color}-solid-to)`,
        '--p-anim-glow-width': `${spread}px`,
        '--p-anim-glow-arc': `${arc}deg`,
        '--p-anim-glow-blur': `${blur}px`,
        ...style
      } as React.CSSProperties,
      ...animate.props,
      'data-plass-animation': 'lighting',
      children
    }
  });
});
