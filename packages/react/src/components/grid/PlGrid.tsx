import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  alignContentClasses,
  alignItemsClasses,
  columnCount,
  justifyClasses,
  responsiveSlots,
  spacingValue,
  withBaseline
} from '../../internal/grid.js';
import { cx } from '../../internal/styles.js';
import type { PlassAlignItems, PlassJustify, PlassResponsive } from '../../types.js';

export interface PlGridProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * How many columns a row is divided into. Every `span` and every `offset`
   * inside is read against this number, so `columns={24}` makes `span={12}` a
   * half and not a full width.
   * @default 12
   */
  columns?: PlassResponsive<number>;
  /**
   * The gutter between items, on Tailwind's spacing scale — `spacing={4}` is
   * `1rem`, the same length `gap-4` is. Fractions are allowed, so `1.5` is
   * `0.375rem`.
   * @default 2
   */
  spacing?: PlassResponsive<number>;
  /** The gutter between rows only. Falls back to `spacing`. */
  rowSpacing?: PlassResponsive<number>;
  /** The gutter between columns only. Falls back to `spacing`. */
  columnSpacing?: PlassResponsive<number>;
  /** How a row distributes the space its items did not use. */
  justify?: PlassJustify;
  /** How items sit against each other across the row. @default 'stretch' */
  alignItems?: PlassAlignItems;
  /** Where the rows sit when the grid is shorter than the box holding it. */
  alignContent?: PlassJustify;
  /**
   * Whether a row that runs out of columns continues on the next one. Turning
   * it off gives one row that overflows, which is what a horizontally scrolling
   * strip wants.
   * @default true
   */
  wrap?: boolean;
  /**
   * Renders something other than a `<div>`: `render={<section />}`,
   * `render={<ul />}`. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  /** The `PlGridItem`s. */
  children?: React.ReactNode;
}

const DEFAULT_COLUMNS = 12;

/** Two Tailwind steps, and the reason a bare `PlGrid` already looks like one. */
const DEFAULT_SPACING = 2;

/**
 * A twelve-column row, and the parent every `PlGridItem` needs.
 *
 * It owns the three numbers an item cannot know on its own — how many columns
 * there are and how wide the two gutters are — and hands them down as inherited
 * custom properties rather than through a React context. That is not a
 * shortcut: the values are responsive, and a media query can change an inherited
 * custom property without React hearing about it, so the column count an item
 * lays itself out against is always the one that is actually on screen. A
 * context would have to re-render the tree at every breakpoint to say the same
 * thing.
 *
 * It draws nothing, and it takes no `variant`, `color`, `elevation`, `size` or
 * `density`. A grid is not a surface — it is the arrangement of the surfaces
 * inside it — and there is no padding here either: the gutter round a page is a
 * `PlContainer`'s and the padding round content is a `PlCard`'s, and a grid that
 * had a track of its own would be a third one to keep in step. `spacing` is the
 * only measurement it owns, and it is the space *between* items.
 *
 * Nesting is a `PlGrid` inside a `PlGridItem`, not an item that is also a grid:
 * the inner grid re-declares the column count for its own subtree while the item
 * around it keeps the width the outer grid gave it.
 */
export const PlGrid = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlGridProps>(function PlGrid(
  {
    columns,
    spacing,
    rowSpacing,
    columnSpacing,
    justify,
    alignItems,
    alignContent,
    wrap = true,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const classNames = cx(
    'plass-grid flex',
    wrap ? 'flex-wrap' : 'flex-nowrap',
    // Both gutters are read from the slots below, which is what lets a media
    // query change them without React re-rendering.
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
        ...responsiveSlots('cols', withBaseline(columns, DEFAULT_COLUMNS), columnCount),
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
