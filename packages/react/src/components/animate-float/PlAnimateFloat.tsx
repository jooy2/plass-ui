'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { animBaseClass, lengthValue, useAnimateElement } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import type { PlassAnimateProps, PlassOrientation } from '../../types.js';

export interface PlAnimateFloatProps
  extends PlassAnimateProps, React.ComponentPropsWithoutRef<'div'> {
  /**
   * How far it drifts from where it started. A number is pixels.
   *
   * Small on purpose. A float is meant to be noticed at the edge of attention
   * and not looked at, and past about a dozen pixels it stops being a drift and
   * starts being something moving on the page.
   * @default 8
   */
  distance?: number | string;
  /**
   * Which way it drifts.
   * @default 'vertical'
   */
  orientation?: PlassOrientation;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Content drifting gently, and not going anywhere.
 *
 * The odd one out among the `PlAnimate*` components, and the page says so: the
 * other effects are **entrances**, played once when content arrives. This one
 * never finishes. It is for the thing that is meant to read as weightless — an
 * illustration on a landing page, a mark over an empty state — and for nothing
 * that a reader has to read while it moves.
 *
 * That is also why it is **not** in `PlassAnimation`, the union `mode`,
 * `stagger` and the shared effect map are built on. That union is the set of
 * ways content can arrive; an endless drift is not an arrival, and every
 * component importing the map would have paid for a row nothing else could
 * want.
 *
 * The cycle is symmetric — home, out, home — so however many times it runs it
 * ends where it started. A float stopped mid-cycle would leave the element
 * permanently a few pixels out of place, which reads as a layout bug rather
 * than as an effect that ended.
 *
 * `easing` defaults to `ease-in-out` rather than to the house curve, which is
 * the one place in the library that is right: the house curve is an entrance's,
 * fast out of the gate and slow into place, and a drift with it would lurch at
 * each end of the cycle instead of turning around.
 *
 * A reader who asked for less motion sees none of it, as with every effect
 * here. Nothing may depend on the movement.
 */
export const PlAnimateFloat = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlAnimateFloatProps>(
  function PlAnimateFloat(
    {
      duration = 3000,
      delay = 0,
      easing = 'ease-in-out',
      repeat = 'infinite',
      alternate,
      paused,
      trigger = 'mount',
      play,
      once = true,
      threshold = 0.2,
      distance = 8,
      orientation = 'vertical',
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const length = lengthValue(distance);
    const vertical = orientation === 'vertical';

    const animate = useAnimateElement({
      // Its own keyframe rather than one of the seven: see the note above.
      effect: null,
      duration,
      delay,
      easing,
      repeat,
      alternate,
      x: vertical ? '0' : length,
      // Up rather than down, which is what "float" means everywhere it is used.
      y: vertical ? `-${length}` : '0',
      trigger,
      play,
      once,
      threshold,
      paused,
      infinite: true,
      children
    });

    return useRender({
      render,
      ref: [ref, animate.ref],
      props: {
        ...props,
        className: cx(animBaseClass, 'plass-anim-float', animate.className, className),
        style: { ...animate.style, ...style },
        ...animate.props,
        'data-plass-animation': 'float',
        children: animate.children
      }
    });
  }
);
