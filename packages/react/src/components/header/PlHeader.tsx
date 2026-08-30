'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { PlPageLayoutContext } from '../../internal/page-layout.js';
import {
  cx,
  hasContent,
  sheetPaddingXClasses,
  sheetRestClasses,
  sheetSectionGapClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassAlign,
  PlassColor,
  PlassDensity,
  PlassElevation,
  PlassPosition,
  PlassSize,
  PlassVariant
} from '../../types.js';

/** How wide the row inside the bar is allowed to get. */
export type PlHeaderWidth = PlassSize | 'none';

export interface PlHeaderProps extends Omit<
  React.ComponentPropsWithoutRef<'header'>,
  'color' | 'title'
> {
  /**
   * The leading slot: the logo, the product's name, the thing that is the same
   * on every page.
   *
   * It is a slot rather than the first of `children` because the three regions
   * of a bar are laid out against each other — the middle can only be centred
   * in the bar if the two ends are measured — and a caller writing three
   * wrappers by hand is a caller whose header drifts from the next one.
   */
  brand?: React.ReactNode;
  /**
   * The trailing slot: the account menu, the theme switch, the call to action.
   * Laid out end-aligned, so a row of buttons needs no wrapper of its own.
   */
  actions?: React.ReactNode;
  /**
   * Where the middle slot sits.
   *
   * - `start` — packed against the brand, taking whatever is left. The
   *   arrangement of an application's bar, and the default.
   * - `center` — centred in the bar itself, not in the space left over. The two
   *   ends are given equal shares for this, so the middle stays on the bar's
   *   own midline however wide the brand is.
   * - `end` — packed against the actions.
   * @default 'start'
   */
  align?: PlassAlign;
  /**
   * How the bar sits in the page's scroll, spelled the way CSS spells it.
   *
   * `sticky` — the default — holds it against the top of the window once the
   * page has scrolled to it, while leaving it in the flow so nothing has to be
   * padded out of its way. `fixed` takes it out of the flow entirely, which a
   * `PlPageLayout` answers by reserving its height. `static` lets it scroll
   * away.
   * @default 'sticky'
   */
  position?: PlassPosition;
  /**
   * What the sheet is made of, said the way a **container** says it: the bar is
   * never dyed, because what is on it arrives with colours of its own.
   * @default 'glass'
   */
  variant?: PlassVariant;
  /**
   * The bar's scale — its height floor, its gutter and the air around its
   * slots. As on `PlBox`, `size` here is the size of the *sheet*.
   * @default 'md'
   */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** @default 'default' */
  density?: PlassDensity;
  /**
   * Drop shadow depth. `0` — the default — is flat: a header is attached to the
   * top of the window rather than floating over the middle of it, and `divider`
   * is what separates it from the content.
   * @default 0
   */
  elevation?: PlassElevation;
  /**
   * Draws a hairline along the bottom edge, against the content the bar is
   * over. On by default: a bar pinned over a scrolling page has content passing
   * underneath it at every moment, and a translucent sheet with nothing marking
   * its edge reads as part of that.
   * @default true
   */
  divider?: boolean;
  /**
   * Holds the row of slots to a measure and centres it, while the sheet itself
   * still spans the window. The same ladder `PlContainer`'s `maxWidth` uses, so
   * a header and the container under it line up on the same edge.
   * @default 'none'
   */
  maxWidth?: PlHeaderWidth;
  /** The gutter down each side of the row. @default true */
  padded?: boolean;
  /**
   * The name the bar is announced by. Worth writing when a page has more than
   * one `<header>` in it — an article's own header and the site's — because
   * "banner" twice tells a reader which is which not at all.
   */
  label?: string;
  /**
   * Renders something other than a `<header>`. Base UI's own escape hatch, and
   * rarely what you want: the bar at the top of a page is a banner, and the tag
   * is what says so to a search engine and to a screen reader's landmark list.
   */
  render?: useRender.RenderProp;
  /** The middle slot. */
  children?: React.ReactNode;
}

/**
 * The bar's floor: a control of the same `size` with air above and below it.
 *
 * Its own ladder rather than `controlHeightClasses`, because a header is not a
 * control — it *holds* controls, and a bar the height of the button in it is a
 * bar with no air. `md` is 64px, which is a 40px control with 12px either side.
 * The air is 8 · 8 · 12 · 16 · 20, and `barPaddingYClasses` is the same numbers
 * again so that a bar taller than its floor keeps breathing.
 */
const barMinHeightClasses: Record<PlassSize, string> = {
  xs: 'min-h-10',
  sm: 'min-h-12',
  md: 'min-h-16',
  lg: 'min-h-20',
  xl: 'min-h-24'
};

const barPaddingYClasses: Record<PlassSize, string> = {
  xs: 'py-2',
  sm: 'py-2',
  md: 'py-3',
  lg: 'py-4',
  xl: 'py-5'
};

/**
 * Between the brand, the middle and the actions — about twice the gap *inside*
 * a slot, and a separate ladder for that reason.
 *
 * The three slots are three regions, and a region needs to read as one. With a
 * single gap doing both jobs the first navigation link sits as far from the
 * logo as the logo sits from its own name, so the eye groups the wrong things
 * and the bar reads as one undifferentiated row.
 */
const barGapClasses: Record<PlassSize, string> = {
  xs: 'gap-3',
  sm: 'gap-4',
  md: 'gap-6',
  lg: 'gap-7',
  xl: 'gap-8'
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
 * The three materials, read the way a *container* reads them — the sheet is
 * never dyed, exactly as on a `PlToolbar`, a `PlBox` and a `PlCard`. What
 * carries the colour family is whatever the caller put on the bar.
 */
const variantClasses = sheetRestClasses;

const positionClasses: Record<PlassPosition, string> = {
  static: '',
  // `top-0` and nothing else: a header is what everything *else* starts below,
  // so it is the one thing in a layout with nothing above it to clear.
  sticky: 'sticky top-0 z-20',
  fixed: 'fixed inset-x-0 top-0 z-30'
};

/**
 * How the three slots divide the bar.
 *
 * `center` is the one that needs explaining. Centring the middle in the space
 * *left over* puts it wherever the brand happens to end, so a logo that grows
 * by one character moves the navigation — which is exactly what a reader
 * notices between two pages of the same site. Giving both ends `flex-1`
 * instead makes them equal by construction, and equal ends put the middle on
 * the bar's own midline whatever is in them.
 */
const endClasses: Record<PlassAlign, string> = {
  start: 'shrink-0',
  center: 'flex-1 basis-0',
  end: 'shrink-0'
};

const middleClasses: Record<PlassAlign, string> = {
  start: 'flex min-w-0 flex-1 items-center justify-start',
  center: 'flex min-w-0 shrink items-center justify-center',
  end: 'flex min-w-0 flex-1 items-center justify-end'
};

/**
 * The bar across the top of a page.
 *
 * A real `<header>`, which is the whole reason it is a component rather than a
 * row of `<div>`s: at the top level of a document that tag is the `banner`
 * landmark, and it is what a screen reader's landmark list, a reader mode and a
 * search engine's understanding of the page are all built out of.
 *
 * Its three slots are props rather than compound sub-components, for `PlCard`'s
 * reason: the arrangement is fixed — brand, middle, actions — and what a caller
 * wants to decide is what goes in each. That the middle can be centred on the
 * bar's own midline is only possible because the ends are the component's to
 * measure.
 *
 * Inside a `PlPageLayout` it also registers itself, so a sidebar that holds its
 * place knows how far down the window to start. Outside one it is simply a bar,
 * and everything above still works.
 *
 * It is not a `PlToolbar` with a tag on it. A toolbar is a row of controls
 * anywhere on a screen and takes a height from its padding alone; a header is
 * the page's banner, and it has a height floor, a measure, a brand slot and a
 * place in a layout — none of which mean anything on a row of controls beside a
 * table.
 */
export const PlHeader = /* @__PURE__ */ React.forwardRef<HTMLElement, PlHeaderProps>(
  function PlHeader(
    {
      brand,
      actions,
      align = 'start',
      position = 'sticky',
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
        register('header', node);

        if (typeof ref === 'function') ref(node);
        else if (ref) ref.current = node;
      },
      [register, ref]
    );

    const classNames = cx(
      'w-full min-w-0',
      variantClasses[variant],
      // The rule faces the content. `--plass-divider` and not the sheet's own
      // white edge line: this is a mark the sheet makes on itself, and white
      // light on a cut edge only reads when the page wash is behind it.
      divider ? 'border-b [border-color:var(--plass-divider)]' : '',
      positionClasses[position],
      transitionClasses,
      className
    );

    return useRender({
      render: render ?? <header />,
      ref: setRef,
      props: {
        'aria-label': label,
        className: classNames,
        style: { ...surfaceSlots(color, elevation), ...style },
        children: (
          <div
            className={cx(
              'flex w-full items-center',
              barMinHeightClasses[size],
              barPaddingYClasses[size],
              barGapClasses[size],
              padded ? sheetPaddingXClasses[density][size] : '',
              maxWidth === 'none' ? '' : cx(maxWidthClasses[maxWidth], 'mx-auto')
            )}
          >
            {hasContent(brand) ? (
              <div
                className={cx(
                  'flex min-w-0 items-center',
                  endClasses[align],
                  sheetSectionGapClasses[size]
                )}
              >
                {brand}
              </div>
            ) : align === 'center' ? (
              // An empty leading end still takes its half, or the middle would
              // be centred on the space left over rather than on the bar.
              <div aria-hidden="true" className={endClasses[align]} />
            ) : null}

            {hasContent(children) ? (
              <div className={cx(middleClasses[align], sheetSectionGapClasses[size])}>
                {children}
              </div>
            ) : null}

            {hasContent(actions) ? (
              <div
                className={cx(
                  'flex min-w-0 items-center justify-end',
                  endClasses[align],
                  sheetSectionGapClasses[size]
                )}
              >
                {actions}
              </div>
            ) : align === 'center' ? (
              <div aria-hidden="true" className={endClasses[align]} />
            ) : null}
          </div>
        ),
        ...props
      }
    });
  }
);
