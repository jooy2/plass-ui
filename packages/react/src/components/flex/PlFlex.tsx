'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  alignContentClasses,
  alignItemsClasses,
  justifyClasses,
  spacingValue
} from '../../internal/grid.js';
import { responsiveSlots, withBaseline } from '../../internal/responsive.js';
import { cx } from '../../internal/styles.js';
import type {
  PlassAlignItems,
  PlassJustify,
  PlassOrientation,
  PlassResponsive
} from '../../types.js';

export interface PlFlexProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * Which way the children run. `horizontal` is a row, `vertical` is a column.
   *
   * Responsive: `direction={{ xs: 'vertical', md: 'horizontal' }}` stacks on a
   * phone and lines up on a laptop, which is most of what this component is
   * for.
   * @default 'horizontal'
   */
  direction?: PlassResponsive<PlassOrientation>;
  /**
   * Runs the children the other way along that axis — the last one first.
   *
   * It reverses the **painting order and nothing else**: the DOM order is what
   * a screen reader reads and what the Tab key walks, and neither of them
   * changes here. Use it for a visual arrangement, never to reorder content.
   * @default false
   */
  reverse?: boolean;
  /**
   * The gap between children, on Tailwind's spacing scale — `spacing={4}` is
   * `1rem`, the same length `gap-4` is. Fractions are allowed, so `1.5` is
   * `0.375rem`.
   * @default 2
   */
  spacing?: PlassResponsive<number>;
  /** The gap between rows only. Falls back to `spacing`. */
  rowSpacing?: PlassResponsive<number>;
  /** The gap between columns only. Falls back to `spacing`. */
  columnSpacing?: PlassResponsive<number>;
  /** How the box distributes the space its children did not use, along the axis. */
  justify?: PlassJustify;
  /** How the children sit against each other across the axis. @default 'stretch' */
  alignItems?: PlassAlignItems;
  /** Where the lines sit when the box is longer across than its content. */
  alignContent?: PlassJustify;
  /**
   * Whether children that run out of room continue on the next line.
   *
   * `false` by default, which is what a flex box already does — a row that
   * wraps is a decision rather than the absence of one, and the opposite
   * default would silently reflow a toolbar somebody sized to fit.
   * @default false
   */
  wrap?: boolean;
  /**
   * Lays the box out **inline**, so it sits in a line of text and is only as
   * wide as its children.
   * @default false
   */
  inline?: boolean;
  /**
   * Renders something other than a `<div>`: `render={<ul />}`,
   * `render={<nav />}`. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  /** What is laid out. */
  children?: React.ReactNode;
}

/** Two Tailwind steps, and what `PlGrid` already defaults its gutters to. */
const DEFAULT_SPACING = 2;

/**
 * The four values `flex-direction` takes, from the two props that decide it.
 *
 * `reverse` is not responsive and `direction` is, which is why they meet here
 * rather than in two slots: one custom property carries the answer, so a
 * breakpoint changes the axis without having to restate which end it starts
 * from.
 */
function directionValue(orientation: PlassOrientation, reverse: boolean): string {
  const axis = orientation === 'vertical' ? 'column' : 'row';

  return reverse ? `${axis}-reverse` : axis;
}

/**
 * A row or a column, and the gap between the things in it.
 *
 * This is the layout box with no arithmetic in it — the one to reach for when
 * the answer is "these, side by side, with a gap". A [PlGrid](./grid) divides a
 * row into columns and needs a `PlGridItem` to take them; here the children
 * are whatever they are and the box only decides which way they run.
 *
 * **`direction` is responsive and resolves in CSS**, which is the whole reason
 * it is worth a component rather than three Tailwind classes. `{ xs:
 * 'vertical', md: 'horizontal' }` is a form that stacks on a phone and lines up
 * on a laptop, decided by the stylesheet — so a server renders it correctly at
 * every width, and dragging a window costs no re-render. It is also the only
 * way to say that in a project that imports `plass-ui/styles.css` and has no
 * Tailwind of its own.
 *
 * It draws **nothing**: no surface, no padding, no `variant`, `color`, `size`
 * or `density`. A flex box is the arrangement of the surfaces inside it, and
 * `spacing` — the space *between* children — is the only measurement it owns.
 */
export const PlFlex = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlFlexProps>(function PlFlex(
  {
    direction,
    reverse = false,
    spacing,
    rowSpacing,
    columnSpacing,
    justify,
    alignItems,
    alignContent,
    wrap = false,
    inline = false,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const classNames = cx(
    'plass-flex',
    inline ? 'inline-flex' : 'flex',
    wrap ? 'flex-wrap' : 'flex-nowrap',
    // Both gaps are read from the slots below, which is what lets a media query
    // change them without React re-rendering.
    'gap-x-(--p-gap-x) gap-y-(--p-gap-y)',
    justify ? justifyClasses[justify] : '',
    alignItems ? alignItemsClasses[alignItems] : '',
    alignContent ? alignContentClasses[alignContent] : '',
    className
  );

  return useRender({
    render,
    ref,
    props: {
      className: classNames,
      style: {
        ...responsiveSlots('dir', withBaseline(direction, 'horizontal'), (value) =>
          directionValue(value, reverse)
        ),
        ...responsiveSlots(
          'gap-x',
          withBaseline(columnSpacing ?? spacing, DEFAULT_SPACING),
          spacingValue
        ),
        ...responsiveSlots(
          'gap-y',
          withBaseline(rowSpacing ?? spacing, DEFAULT_SPACING),
          spacingValue
        ),
        ...style
      },
      children,
      ...props
    }
  });
});
