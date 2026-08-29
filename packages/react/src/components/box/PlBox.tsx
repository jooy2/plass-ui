'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  cx,
  radiusClasses,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetRestClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassElevation, PlassStyleProps } from '../../types.js';

export interface PlBoxProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Drop shadow depth. `0` is the default and it is flat — the glass edge is
   * what separates the box from the page. Raise it only for a surface that
   * genuinely floats above the content around it.
   * @default 0
   */
  elevation?: PlassElevation;
  /**
   * Inner padding, on the `size` / `density` scale. Turn it off for full-bleed
   * content — an image, a table, a list that draws its own rows.
   * @default true
   */
  padded?: boolean;
  /**
   * Renders something other than a `<div>`: `render={<section />}`,
   * `render={<li />}`, or a function for full control. Base UI's own escape
   * hatch, so it behaves the same here as on every Base UI primitive.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * A sheet of glass with content on it. The plainest surface in the library: it
 * groups things, and that is all it does.
 *
 * Everything structural — a title, a footer, hairlines between sections —
 * belongs to `PlCard`, which is a box with those sections laid out on it. What
 * is left here is the sheet itself, and the reason it is worth having on its own
 * is that most of what a screen groups has no heading: a well behind a form, a
 * tile in a shelf, a panel round a chart.
 *
 * `size` means something different here from what it means on a control, and
 * this is the one place in the library where that is true. A box is as tall as
 * what it holds, and its children bring their own typography — a container that
 * reset the type scale would render the same paragraph at two sizes depending
 * on what it was wrapped in. So `size` is the size of the **sheet**: its radius
 * and its padding, and nothing else.
 *
 * The three materials say what they say everywhere else, read as a container's:
 * the sheet is never dyed, because what a box holds arrives with its own
 * colours and tinting the pane under them puts every one on a background it was
 * not chosen against. The family reaches the hairline and the focus ring and
 * stops. `ghost` is the one to reach for inside another surface, where a second
 * bordered rectangle is a second rectangle.
 */
export const PlBox = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlBoxProps>(function PlBox(
  {
    variant = 'glass',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    padded = true,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const classNames = cx(
    'block',
    radiusClasses[size],
    padded ? `${sheetPaddingXClasses[density][size]} ${sheetPaddingYClasses[density][size]}` : '',
    sheetRestClasses[variant],
    // The same property list and duration as everything else, so a box whose
    // colour or elevation changes settles at the house pace. There is no
    // `:active` treatment because a box is not pressed — it holds things that
    // are.
    transitionClasses,
    className
  );

  return useRender({
    render: render ?? <div />,
    ref,
    props: {
      className: classNames,
      style: { ...surfaceSlots(color, elevation), ...style },
      children,
      ...props
    }
  });
});
