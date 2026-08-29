'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { cx, sheetPaddingXClasses } from '../../internal/styles.js';
import type { PlassDensity, PlassSize } from '../../types.js';

/**
 * How wide the content is allowed to get.
 *
 * `none` is the extra step and the default, because a `PlContainer`'s job is
 * the gutter — a measure is a second decision, and a page should have to ask
 * for one.
 */
export type PlContainerWidth = PlassSize | 'none';

export interface PlContainerProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * How wide the content is allowed to get, on the same ladder the breakpoints
   * use — `xs` 30rem, `sm` 40rem, `md` 48rem, `lg` 64rem, `xl` 80rem.
   * @default 'none'
   */
  maxWidth?: PlContainerWidth;
  /**
   * The gutter, on the `size`/`density` scale. Turn it off to keep the centring
   * and the measure without the padding.
   * @default true
   */
  padded?: boolean;
  /**
   * The gutter's scale.
   *
   * `size` here is the size of the *sheet* — it never touches a height or the
   * type scale — and it is independent of `maxWidth`, which is how wide the
   * content gets rather than how far it sits from the edge.
   * @default 'md'
   */
  size?: PlassSize;
  /** @default 'default' */
  density?: PlassDensity;
  /**
   * Centres the content once `maxWidth` is narrower than the page. No effect
   * while `maxWidth` is `none`, because there is nothing left over to centre in.
   * @default true
   */
  centered?: boolean;
  /**
   * Renders something other than a `<div>`: `render={<main />}`,
   * `render={<section />}`. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * The measure ladder, in `rem` rather than in Tailwind's named `max-w-*` steps,
 * so that a container's `lg` and an `lg:` utility are the same 64rem.
 *
 * Tailwind's own container scale is a different set of numbers, and having two
 * ladders called `lg` on one page is how a layout drifts by a few pixels for no
 * reason anybody can find later.
 */
const maxWidthClasses: Record<PlassSize, string> = {
  xs: 'max-w-[30rem]',
  sm: 'max-w-[40rem]',
  md: 'max-w-[48rem]',
  lg: 'max-w-[64rem]',
  xl: 'max-w-[80rem]'
};

/**
 * Horizontal breathing room, and optionally a measure.
 *
 * It draws nothing — no sheet, no hairline, no shadow — for the same reason
 * `PlAspectRatio` does not. The outermost element on a page is the one thing
 * that must not decide what the page looks like, and a container that carried a
 * `variant` would put a second pane behind every card on it.
 *
 * The two questions it answers are deliberately separate from how the content
 * inside divides itself up: a container holds a `PlGrid` as happily as it holds
 * a single paragraph, and a grid needs no container around it.
 *
 * The gutter is the **sheet** padding track rather than the control one. What
 * sits inside a container is a page, and the margin a page keeps from the edge
 * of a window is the margin a card keeps around a paragraph — not the room a
 * label needs beside the edge of the key it is printed on.
 */
export const PlContainer = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlContainerProps>(
  function PlContainer(
    {
      maxWidth = 'none',
      padded = true,
      size = 'md',
      density = 'default',
      centered = true,
      render,
      className,
      children,
      ...props
    },
    ref
  ) {
    const classNames = cx(
      'block w-full',
      maxWidth === 'none' ? '' : maxWidthClasses[maxWidth],
      centered ? 'mx-auto' : '',
      padded ? sheetPaddingXClasses[density][size] : '',
      className
    );

    return useRender({
      render,
      ref,
      props: {
        className: classNames,
        children,
        ...props
      }
    });
  }
);
