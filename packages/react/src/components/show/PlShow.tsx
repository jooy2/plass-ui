import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { cx } from '../../internal/styles.js';
import type { PlassBreakpointFloor } from '../../types.js';

export interface PlShowProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * The narrowest width this is drawn at. Below it, nothing.
   *
   * There is no `xs`: everything is at or above the bottom rung, so `from="xs"`
   * would mean "always" — which is what leaving the prop out already means.
   */
  from?: PlassBreakpointFloor;
  /**
   * The width it stops being drawn at. From that rung up, nothing.
   *
   * Exclusive, and it has to be: `until="md"` on one element and `from="md"` on
   * another are then the two halves of one decision, with no width that draws
   * both and none that draws neither.
   */
  until?: PlassBreakpointFloor;
  /**
   * Renders something other than a `<div>`: `render={<span />}`. Base UI's own
   * escape hatch.
   *
   * A paragraph cannot hold a `<div>`, so inside a `<p>` an HTML parser closes
   * the paragraph in front of it and a page rendered on a server no longer
   * hydrates. A gate in a line of text wants a `<span>`, and gates the same way.
   */
  render?: useRender.RenderProp;
  /** What is shown, at the widths it is shown at. */
  children?: React.ReactNode;
}

/**
 * Content at some widths and not others.
 *
 * ```tsx
 * <PlShow from="md">
 *   <PlTable columns={columns} rows={rows} />
 * </PlShow>
 * <PlShow until="md">
 *   <PlList>…</PlList>
 * </PlShow>
 * ```
 *
 * **It is not a box.** While it is showing it is `display: contents`, so its
 * children take part in the layout around it exactly as they would have without
 * it — a gate inside a flex row does not become a flex item, and one inside a
 * grid does not become a cell. Which also means a `className` carrying a margin
 * or a width does nothing here: there is no box for it to land on. Put your own
 * element inside.
 *
 * **It decides in CSS, and that is the whole point.** A media query answered in
 * JavaScript is `false` on a server and on the first frame a browser renders,
 * so a `useMediaQuery` and a ternary draw the wrong half of a responsive layout
 * and then throw it away — a flash on every page load rather than an edge case.
 * The stylesheet knows the width before React has been asked anything.
 *
 * What follows from that is the trade worth knowing: **both halves are in the
 * document**. Hiding is `display: none`, which takes the subtree off the
 * accessibility tree and out of the layout, so nothing is read twice and
 * nothing is drawn — but both were rendered and both were sent. That is right
 * for two arrangements of the same content and wrong for a subtree that is
 * expensive to build or that must not mount at all; for those,
 * `usePlBreakpointValue` picks one and only that one is mounted, at the cost of
 * a server rendering the `xs` answer.
 *
 * **A layer that portals out is not hidden with its half.** A `PlModal`, a
 * `PlDrawer` or a popover renders at the end of `<body>`, outside the box that
 * `display: none` hides, so an open one in the closed half shows. Two halves
 * that read the same `open` open two windows. Keep layers outside `PlShow`, or
 * choose between them with `usePlBreakpointValue`.
 *
 * There is no `PlHide`, deliberately. `until` is the inverse of `from` and the
 * two together are a band, so a second component would be a second way to spell
 * the same three cases.
 */
export const PlShow = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlShowProps>(function PlShow(
  { from, until, render, className, children, ...props },
  ref
) {
  return useRender({
    render,
    ref,
    props: {
      className: cx('plass-show', className),
      'data-from': from,
      'data-until': until,
      children,
      ...props
    }
  });
});
