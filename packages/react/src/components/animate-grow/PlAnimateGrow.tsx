'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, useAnimateElement } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import type { PlassAnimateMode, PlassAnimateProps } from '../../types.js';

export interface PlAnimateGrowProps
  extends PlassAnimateProps, React.ComponentPropsWithoutRef<'div'> {
  /**
   * Whether the content unfolds or folds away.
   * @default 'in'
   */
  mode?: PlassAnimateMode;
  /**
   * The scale it starts from, as a multiple of its final size. Above `1` it
   * settles down onto the page instead of up out of it.
   * @default 0.8
   */
  from?: number;
  /**
   * Which point stays put while the rest moves — any CSS `transform-origin`.
   * `'top'` unfolds downwards, `'bottom left'` out of a corner.
   * @default 'center'
   */
  origin?: string;
  /**
   * Fades in as it grows. Turn it off for something already on the page that is
   * only changing size.
   * @default true
   */
  fade?: boolean;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Content unfolding from a point.
 *
 * The difference from Zoom is `origin` and how far it travels: a Grow starts
 * close to its final size and can be anchored to an edge, so it reads as
 * something opening out of the thing beside it — a panel out of a toolbar, a
 * card out of the row it belongs to. A Zoom starts much smaller and always from
 * the middle.
 *
 * Short travel is what makes it safe on glass. A sheet growing from 0.8 stays
 * recognisably the same sheet the whole way, and the blur behind it never has
 * to resolve a surface that is a fifth of the size it is about to be.
 */
export const PlAnimateGrow = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlAnimateGrowProps>(
  function PlAnimateGrow(
    {
      duration = 320,
      delay = 0,
      easing,
      repeat = 1,
      alternate,
      paused,
      trigger = 'mount',
      play,
      once = true,
      threshold = 0.2,
      mode = 'in',
      from = 0.8,
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
      effect: 'grow',
      duration,
      delay,
      easing,
      repeat,
      alternate,
      mode,
      scale: from,
      opacity: fade ? 0 : 1,
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
        className: cx(animate.className, className),
        // `transform-origin` governs the standalone `scale` property too, which
        // is what lets the effect stay off the `transform` shorthand entirely.
        style: { transformOrigin: origin, ...animate.style, ...style },
        ...animate.props,
        children
      }
    });
  }
);
