'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, useAnimateElement } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import type { PlassAnimateMode, PlassAnimateProps, PlassAnimateStaggerProps } from '../../types.js';

export interface PlAnimateZoomProps
  extends PlassAnimateProps, PlassAnimateStaggerProps, React.ComponentPropsWithoutRef<'div'> {
  /**
   * Whether the content comes forward or falls away.
   * @default 'in'
   */
  mode?: PlassAnimateMode;
  /**
   * The scale it starts from, as a multiple of its final size. Above `1` it
   * arrives oversized and settles back, which reads as coming *towards* the
   * reader rather than up out of the page.
   * @default 0.4
   */
  from?: number;
  /**
   * Fades in as it zooms.
   * @default true
   */
  fade?: boolean;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Content arriving from the middle of where it will end up.
 *
 * The same arithmetic as Grow at more than twice the distance, and always about
 * the centre — which is the whole difference. A Grow unfolds from somewhere; a
 * Zoom comes at you. Use it for the one thing on a screen that is meant to
 * interrupt: a confirmation, a result, a number that has just landed.
 *
 * There is no `origin`, on purpose. A zoom anchored to a corner is a grow, and
 * the library does not offer two spellings of one idea.
 */
export const PlAnimateZoom = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlAnimateZoomProps>(
  function PlAnimateZoom(
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
      stagger = 0,
      durationStep = 0,
      reverse = false,
      mode = 'in',
      from = 0.4,
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
      effect: 'zoom',
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
      infinite: isInfinite(repeat),
      origin: 'center',
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
