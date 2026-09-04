'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { animBaseClass, lengthValue, useAnimateElement } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import type { PlassAnimateProps } from '../../types.js';

export interface PlAnimateShakeProps
  extends PlassAnimateProps, React.ComponentPropsWithoutRef<'div'> {
  /**
   * Plays the shake again whenever this value changes, and never on the first
   * render.
   *
   * The prop the component exists around. `play` is a boolean, so replaying
   * with it means toggling off and on — two renders for one event, and a piece
   * of state whose only job is to be flipped back. A refusal is an **event**,
   * and a value that has changed is the closest React has to one: a count of
   * failed attempts already is this.
   *
   * ```tsx
   * <PlAnimateShake replay={attempts}>…</PlAnimateShake>
   * ```
   */
  replay?: unknown;
  /**
   * How far it travels either side of where it started. A number is pixels.
   * @default 6
   */
  distance?: number | string;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * A refusal.
 *
 * The one effect in the set that is a **response** rather than an entrance: it
 * is what a form does when the password was wrong again, what a locked control
 * does when it is pressed. So it starts held still and plays only when it is
 * told to, where every other effect here starts on mount.
 *
 * `replay` is the prop it exists around. A refusal can happen twice, and
 * `play`, being a boolean, cannot say "again" — replaying with it means
 * toggling off and on, which is two renders for one event and a piece of state
 * whose only job is to be flipped back. A value that has changed is the closest
 * React has to an event, and the count of failed attempts a form already keeps
 * is exactly that value.
 *
 * It is not in `PlassAnimation`, for `PlAnimateFloat`'s reason: that union is
 * the set of ways content can arrive, and this is not an arrival.
 *
 * Three shudders either side of home and back to nothing, so a shaken element
 * is exactly where it was. This is the one effect a caller will run over
 * content that is still being typed into, and a field left a few pixels off its
 * label would be worse than the error it was reporting.
 *
 * **A reader who asked for less motion sees none of it**, which is the whole
 * reason the words matter more than the shake: whatever a refusal is saying has
 * to be said in text as well, in something a screen reader is told about. The
 * shake is emphasis, never the message.
 */
export const PlAnimateShake = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlAnimateShakeProps>(
  function PlAnimateShake(
    {
      duration = 400,
      delay = 0,
      easing,
      repeat = 1,
      alternate,
      paused,
      // Held still until something happens, unlike every other effect here.
      trigger = 'manual',
      play = false,
      once = true,
      threshold = 0.2,
      replay,
      distance = 6,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const animate = useAnimateElement({
      // Its own keyframe rather than one of the seven: a refusal is not an
      // arrival.
      effect: null,
      duration,
      delay,
      easing,
      repeat,
      alternate,
      x: lengthValue(distance),
      trigger,
      play,
      once,
      threshold,
      paused,
      infinite: false,
      nonce: replay,
      children
    });

    return useRender({
      render,
      ref: [ref, animate.ref],
      props: {
        ...props,
        className: cx(animBaseClass, 'plass-anim-shake', animate.className, className),
        style: { ...animate.style, ...style },
        ...animate.props,
        'data-plass-animation': 'shake',
        children: animate.children
      }
    });
  }
);
