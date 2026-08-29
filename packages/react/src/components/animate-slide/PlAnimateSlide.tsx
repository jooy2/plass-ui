'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, slideOffsets, useAnimateElement } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import type { PlassAnimateMode, PlassAnimateProps, PlassSide } from '../../types.js';

export interface PlAnimateSlideProps
  extends PlassAnimateProps, React.ComponentPropsWithoutRef<'div'> {
  /**
   * Whether the content slides in or slides away. `out` leaves by the same edge
   * it would have come from.
   * @default 'in'
   */
  mode?: PlassAnimateMode;
  /**
   * Which edge it travels from. Physical, as `PlassSide` is everywhere — a
   * panel coming down from the top comes from the top in every writing
   * direction.
   * @default 'bottom'
   */
  from?: PlassSide;
  /**
   * How far it travels — a CSS length, or a number in pixels. `'100%'` is the
   * element's own width or height, which is what makes it appear from behind
   * its own edge.
   * @default '100%'
   */
  distance?: number | string;
  /**
   * Fades in as it slides.
   * @default true
   */
  fade?: boolean;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Content travelling in from one edge.
 *
 * The default distance is the element's own size, so it starts exactly out of
 * frame and arrives without ever having been half drawn somewhere it does not
 * belong. Put it in a box with `overflow: hidden` and the effect is a panel
 * appearing from behind that box's edge.
 *
 * A slide moves the element, so what is *around* it does not move: this is a
 * `translate` rather than a change of layout, and nothing on the page reflows
 * while it runs. For a much shorter travel over a list of things, one after
 * another, use PlAnimateAppear.
 */
export const PlAnimateSlide = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlAnimateSlideProps>(
  function PlAnimateSlide(
    {
      duration = 360,
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
      from = 'bottom',
      distance = '100%',
      fade = true,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const { x, y } = slideOffsets(from, distance);

    const animate = useAnimateElement({
      effect: 'slide',
      duration,
      delay,
      easing,
      repeat,
      alternate,
      mode,
      x,
      y,
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
        style: { ...animate.style, ...style },
        ...animate.props,
        children
      }
    });
  }
);
