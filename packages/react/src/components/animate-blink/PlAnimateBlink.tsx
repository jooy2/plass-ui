'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, useAnimateElement } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import type { PlassAnimateProps, PlassAnimateStaggerProps } from '../../types.js';

export interface PlAnimateBlinkProps
  extends PlassAnimateProps, PlassAnimateStaggerProps, React.ComponentPropsWithoutRef<'div'> {
  /**
   * How faint it gets at the bottom of the cycle, between `0` and `1`. Raise it
   * for something that has to stay readable while it pulses.
   * @default 0
   */
  min?: number;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Content pulsing between full opacity and a floor.
 *
 * The cycle is symmetric — full, faint, full — so however many times it runs it
 * ends where it started. A blink that finished halfway would leave the element
 * permanently half drawn, which reads as a rendering fault rather than as an
 * effect that ended.
 *
 * It repeats forever unless told otherwise, because a single blink is a flicker
 * and nobody asks for a flicker. Two things are worth saying about using it at
 * all: something that never stops moving in the corner of a page being read is
 * the one kind of motion this library otherwise refuses, and a reader with a
 * reduced-motion preference will see none of it — so `min` is a dimming, never
 * the only thing carrying the message. If it is urgent, say so in words too.
 */
export const PlAnimateBlink = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlAnimateBlinkProps>(
  function PlAnimateBlink(
    {
      duration = 1000,
      delay = 0,
      easing,
      repeat = 'infinite',
      alternate,
      paused,
      trigger = 'mount',
      play,
      once = true,
      threshold = 0.2,
      stagger = 0,
      durationStep = 0,
      reverse = false,
      min = 0,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const animate = useAnimateElement({
      effect: 'blink',
      duration,
      delay,
      easing,
      repeat,
      alternate,
      opacity: min,
      trigger,
      play,
      once,
      threshold,
      paused,
      infinite: isInfinite(repeat),
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
  }
);
