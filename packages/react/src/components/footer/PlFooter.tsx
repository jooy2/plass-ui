'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { PlPageLayoutContext } from '../../internal/page-layout.js';
import {
  cx,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetRestClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassColor,
  PlassDensity,
  PlassElevation,
  PlassPosition,
  PlassSize,
  PlassVariant
} from '../../types.js';

/** How wide the content inside the sheet is allowed to get. */
export type PlFooterWidth = PlassSize | 'none';

export interface PlFooterProps extends Omit<
  React.ComponentPropsWithoutRef<'footer'>,
  'color' | 'title'
> {
  /**
   * How the bar sits in the page's scroll.
   *
   * `static` — the default, and the opposite of `PlHeader`'s — is what a footer
   * is: the thing at the end of the document, reached by scrolling to it.
   * `sticky` and `fixed` are for the bar that has to stay in reach — a form's
   * save row, a cookie notice — and a `PlPageLayout` reserves the height a
   * `fixed` one takes out of the flow.
   * @default 'static'
   */
  position?: PlassPosition;
  /**
   * What the sheet is made of, said the way a **container** says it: the bar is
   * never dyed, because what is on it arrives with colours of its own.
   * @default 'glass'
   */
  variant?: PlassVariant;
  /**
   * The bar's scale — its gutter and the air above and below its content. As on
   * `PlBox`, `size` here is the size of the *sheet*.
   * @default 'md'
   */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** @default 'default' */
  density?: PlassDensity;
  /** Drop shadow depth. `0` — the default — is flat. @default 0 */
  elevation?: PlassElevation;
  /**
   * Draws a hairline along the top edge. On by default: a footer is the one
   * sheet on the page with content directly above it and nothing below, so the
   * line is the whole of what says the document ended.
   * @default true
   */
  divider?: boolean;
  /**
   * Holds the content to a measure and centres it, while the sheet itself still
   * spans the window. The same ladder `PlContainer`'s `maxWidth` uses.
   * @default 'none'
   */
  maxWidth?: PlFooterWidth;
  /** The gutter and the air above and below. @default true */
  padded?: boolean;
  /**
   * The name the bar is announced by. Worth writing when a page has more than
   * one `<footer>` in it — an article's own and the site's.
   */
  label?: string;
  /**
   * Renders something other than a `<footer>`. Base UI's own escape hatch, and
   * rarely what you want: at the top level of a document that tag is the
   * `contentinfo` landmark, and it is what says "this is the site's own
   * information" rather than "this is more of the article".
   */
  render?: useRender.RenderProp;
  /**
   * Everything in it. A footer's content is columns of links, a copyright line,
   * a logo — all of it the caller's, none of it something a component could
   * guess at, which is why this one has slots for nothing and space for
   * anything.
   */
  children?: React.ReactNode;
}

/**
 * The three materials, read the way a *container* reads them, exactly as on
 * `PlHeader`.
 */
const variantClasses = sheetRestClasses;

const positionClasses: Record<PlassPosition, string> = {
  static: '',
  sticky: 'sticky bottom-0 z-20',
  fixed: 'fixed inset-x-0 bottom-0 z-30'
};

/** The measure, on `PlContainer`'s ladder so the two line up on one edge. */
const maxWidthClasses: Record<PlassSize, string> = {
  xs: 'max-w-[30rem]',
  sm: 'max-w-[40rem]',
  md: 'max-w-[48rem]',
  lg: 'max-w-[64rem]',
  xl: 'max-w-[80rem]'
};

/**
 * The sheet at the end of a page.
 *
 * A real `<footer>`, which is the whole reason it is a component rather than a
 * `<div>`: at the top level of a document that tag is the `contentinfo`
 * landmark — the region a screen reader offers as "the site's own information"
 * and a search engine reads the copyright, the address and the site map out of.
 *
 * **It has no slots on purpose**, which is the difference between it and
 * `PlHeader`. A header's three regions are a fixed arrangement worth writing
 * once; a footer's content is four columns on one site and one line on the
 * next, and a component that guessed at the arrangement would be a component
 * every second site fights. What it decides is the sheet: the surface, the
 * gutter, the hairline that says the document ended, and whether it stays in
 * reach.
 *
 * Inside a `PlPageLayout` it also registers itself, so a `fixed` footer's
 * height is reserved rather than sitting on top of the last paragraph.
 */
export const PlFooter = /* @__PURE__ */ React.forwardRef<HTMLElement, PlFooterProps>(
  function PlFooter(
    {
      position = 'static',
      variant = 'glass',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      divider = true,
      maxWidth = 'none',
      padded = true,
      label,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const { register } = React.useContext(PlPageLayoutContext);

    const setRef = React.useCallback(
      (node: HTMLElement | null) => {
        register('footer', node);

        if (typeof ref === 'function') ref(node);
        else if (ref) ref.current = node;
      },
      [register, ref]
    );

    const classNames = cx(
      'w-full min-w-0',
      variantClasses[variant],
      // The rule faces the content, which is above a footer rather than below
      // it. `--plass-divider` and not the sheet's own white edge line, for the
      // reason every internal rule in the library is the neutral ink.
      divider ? 'border-t [border-color:var(--plass-divider)]' : '',
      positionClasses[position],
      transitionClasses,
      className
    );

    return useRender({
      render: render ?? <footer />,
      ref: setRef,
      props: {
        'aria-label': label,
        className: classNames,
        style: { ...surfaceSlots(color, elevation), ...style },
        children: (
          <div
            className={cx(
              'w-full',
              padded
                ? cx(sheetPaddingXClasses[density][size], sheetPaddingYClasses[density][size])
                : '',
              maxWidth === 'none' ? '' : cx(maxWidthClasses[maxWidth], 'mx-auto')
            )}
          >
            {children}
          </div>
        ),
        ...props
      }
    });
  }
);
