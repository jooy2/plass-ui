'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { cx, srOnlyClasses } from '../../internal/styles.js';

export interface PlVisuallyHiddenProps extends React.ComponentPropsWithoutRef<'span'> {
  /**
   * Brings the content back into the page while anything inside it has the
   * focus, and clips it again as soon as the focus leaves.
   *
   * Off by default, because the ordinary use of this component is a name that
   * is never meant to be seen. The exception is the one element that *must*
   * appear when it is reached — a skip link — and there is no way for a caller
   * to add it from the outside: the clip is `position: absolute`, so revealing
   * it means putting the element back in the flow, which a `className` cannot
   * do without also fighting the class it is trying to override.
   *
   * `:focus-within` rather than `:focus`, because the thing being tabbed to is
   * almost always a link *inside* the box rather than the box itself — and
   * `:focus-within` matches the element when it holds the focus too, so the
   * narrower case is covered by the wider one.
   * @default false
   */
  focusable?: boolean;
  /**
   * Renders something other than a `<span>`: `render={<div />}`,
   * `render={<h2 />}`. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Back into the flow, at the size the content actually is.
 *
 * Every one of these undoes a declaration in `srOnlyClasses`, and they have to
 * be written out rather than reached for with a `revert`: `position: static` is
 * what gives the box its size back, and a `clip-path` left behind would keep it
 * invisible at that size.
 */
const revealClasses = /* @__PURE__ */ [
  'focus-within:static focus-within:size-auto',
  'focus-within:overflow-visible focus-within:whitespace-normal',
  'focus-within:[clip-path:none]'
].join(' ');

/**
 * Content for a screen reader and for nobody else.
 *
 * It is not a styling escape hatch and it is not `display: none`. The two
 * obvious ways to hide something — `hidden` and `opacity: 0` — are both wrong
 * in the same place: the first takes the text off the accessibility tree along
 * with the screen, which is the one thing this component exists to avoid, and
 * the second leaves a clickable ghost the size of the words. A one-pixel
 * clipped box is the only form that is absent to a sighted reader and present
 * to every other kind.
 *
 * What it is for is the sentence a control cannot say out loud — the word
 * "Close" on a button that draws an ✕, the unit after a number, the change of
 * context on a link that says "read more". The library already reaches for this
 * inside a dozen components; this is the same rule, spelled once, for the
 * caller's own markup.
 */
export const PlVisuallyHidden = /* @__PURE__ */ React.forwardRef<
  HTMLSpanElement,
  PlVisuallyHiddenProps
>(function PlVisuallyHidden({ focusable = false, render, className, children, ...props }, ref) {
  return useRender({
    render: render ?? <span />,
    ref,
    props: {
      className: cx(srOnlyClasses, focusable ? revealClasses : '', className),
      children,
      ...props
    }
  });
});
