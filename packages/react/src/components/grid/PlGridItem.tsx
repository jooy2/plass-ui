import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { alignSelfClasses, offsetValue, responsiveSlots, spanValue } from '../../internal/grid';
import { cx } from '../../internal/styles';
import type { PlassAlignSelf, PlassResponsive } from '../../types';

export interface PlGridItemProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * How many of the grid's columns the item takes. Read against the grid's
   * `columns`, so `span={6}` is a half of the default twelve and a quarter of
   * `columns={24}`.
   *
   * Responsive: `span={{ xs: 12, md: 6, lg: 4 }}` is full width on a phone, half
   * from 48rem and a third from 64rem. Every entry applies from its own
   * breakpoint up, so two of them usually describe a whole layout.
   *
   * A span wider than the row is clamped to the row rather than overflowing.
   * @default the grid's full width
   */
  span?: PlassResponsive<number>;
  /**
   * Columns left empty *before* the item — space pushed in ahead of it, not an
   * absolute position in the row. First in a twelve-column row, `offset={4}`
   * with `span={4}` is the middle third; after an item that already took four
   * columns, the same offset skips four more and lands on the last third.
   *
   * Responsive in the same way `span` is.
   * @default 0
   */
  offset?: PlassResponsive<number>;
  /** Overrides the row's `alignItems` for this item alone. */
  alignSelf?: PlassAlignSelf;
  /**
   * Renders something other than a `<div>`: `render={<li />}`,
   * `render={<article />}`. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * One cell of a `PlGrid`.
 *
 * It is a width and nothing else — no sheet, no padding, no typography. What
 * goes inside brings its own, which is the whole reason a cell and a `PlCard`
 * are two components: wrapping something in a layout must not change how it
 * looks, and a cell that drew a sheet would make `span` a visual decision.
 *
 * The column count it divides by is inherited from the grid as a custom
 * property, so an item with no `PlGrid` above it falls back to twelve rather
 * than breaking — but it will be a lone width in a plain parent, which is not a
 * layout. Always wrap.
 */
export const PlGridItem = React.forwardRef<HTMLDivElement, PlGridItemProps>(function PlGridItem(
  { span, offset, alignSelf, render, className, style, children, ...props },
  ref
) {
  const classNames = cx('plass-grid-item', alignSelf ? alignSelfClasses[alignSelf] : '', className);

  return useRender({
    render,
    ref,
    props: {
      className: classNames,
      style: {
        ...responsiveSlots('span', span, spanValue),
        ...responsiveSlots('offset', offset, offsetValue),
        ...style
      },
      children,
      ...props
    }
  });
});
