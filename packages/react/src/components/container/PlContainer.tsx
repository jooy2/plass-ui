'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useRender } from '@base-ui/react/use-render';
import { responsiveSlots } from '../../internal/responsive.js';
import { cx, sheetPaddingXClasses, toLength } from '../../internal/styles.js';
import type { PlassDensity, PlassResponsive, PlassSize } from '../../types.js';

/**
 * How wide the content is allowed to get: a rung of the measure ladder, any CSS
 * length, a number of pixels, or `none`.
 *
 * `none` is the extra step and the default, because a `PlContainer`'s job is
 * the gutter — a measure is a second decision, and a page should have to ask
 * for one.
 *
 * The `string` half is written as `string & {}` so that the five rungs still
 * autocomplete. A bare `string` in the union would swallow them and the ladder
 * would be five names a caller has to remember rather than five the editor
 * offers.
 */
export type PlContainerWidth = PlassSize | 'none' | number | (string & {});

export interface PlContainerProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * How wide the content is allowed to get.
   *
   * The five rungs are the same widths the breakpoints are — `xs` 30rem, `sm`
   * 40rem, `md` 48rem, `lg` 64rem, `xl` 80rem — so a container capped at `lg`
   * ends where an `lg:` utility begins. Anything else is taken as a length: a
   * number is pixels, and a string is any CSS length, which is how a measure in
   * **characters** gets written. `maxWidth="72ch"` is the one a paragraph
   * actually wants, and no ladder of `rem` can spell it.
   *
   * Responsive, and resolved in CSS rather than in JavaScript — so it is right
   * in the first paint a server sends, and a window being dragged costs no
   * re-render.
   * @default 'none'
   */
  maxWidth?: PlassResponsive<PlContainerWidth>;
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
 *
 * Written out rather than read from `--plass-breakpoint-*`, which they happen
 * to equal from `sm` up. They are not the same question: a breakpoint is where
 * the window changes shape and a measure is how wide text may get, and a
 * project that moved one because it wanted the other would have moved the wrong
 * thing.
 */
const measures: Record<PlassSize, string> = {
  xs: '30rem',
  sm: '40rem',
  md: '48rem',
  lg: '64rem',
  xl: '80rem'
};

/** A rung if it is one of the five, `none` as itself, anything else a length. */
function measureValue(value: PlContainerWidth): string {
  if (value === 'none') {
    return 'none';
  }

  if (typeof value === 'string' && value in measures) {
    return measures[value as PlassSize];
  }

  return toLength(value) as string;
}

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
      maxWidth,
      padded = true,
      size: sizeProp,
      density: densityProp,
      centered = true,
      render,
      className,
      children,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const density = densityProp ?? defaults.density ?? 'default';

    const classNames = cx(
      'block w-full',
      // Only when there is a measure to carry: a container with none needs
      // neither the class nor the slot, and the CSS's own fallback is `none`.
      maxWidth === undefined ? '' : 'plass-container',
      centered ? 'mx-auto' : '',
      padded ? sheetPaddingXClasses[density][size] : '',
      className
    );

    return useRender({
      render,
      ref,
      props: {
        className: classNames,
        style: responsiveSlots('maxw', maxWidth, measureValue),
        children,
        ...props
      }
    });
  }
);
