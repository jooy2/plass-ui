import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  cx,
  hasContent,
  radiusClasses,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetRestClasses,
  sheetSectionGapClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassElevation, PlassPosition, PlassStyleProps } from '../../types.js';

export interface PlToolbarProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Drop shadow depth. `0` — the default — is flat even when the bar is pinned:
   * a shadow under a header is a way of saying "there is content beneath this",
   * and that is only true once the page has been scrolled. Raise it yourself, or
   * leave it flat and turn on `divider`.
   * @default 0
   */
  elevation?: PlassElevation;
  /**
   * How the bar sits in the page's scroll.
   *
   * - `static` — in the flow, scrolling away with the content.
   * - `sticky` — in the flow until it reaches the edge, then held there. What an
   *   application header usually wants: it takes up its own space, so nothing
   *   underneath has to be padded around it.
   * - `fixed` — out of the flow entirely. The page needs padding of its own, or
   *   the first screenful sits behind the bar.
   * @default 'static'
   */
  position?: PlassPosition;
  /** Which edge it is held against when `position` is not `static`. @default 'top' */
  side?: 'top' | 'bottom';
  /**
   * Draws a hairline along the edge that faces the content — under a `top` bar,
   * over a `bottom` one.
   * @default false
   */
  divider?: boolean;
  /** Pinned to the start of the bar: a logo, a title, a back button. */
  start?: React.ReactNode;
  /** Pinned to the end: the actions. */
  end?: React.ReactNode;
  /**
   * Renders something other than a `<div>` — `render={<header />}`,
   * `render={<nav />}`. Base UI's own escape hatch, and worth reaching for here:
   * a page's header should be a `<header>`.
   */
  render?: useRender.RenderProp;
  /** The middle. Takes whatever width `start` and `end` leave. */
  children?: React.ReactNode;
}

/**
 * The three materials, said the way a *container* says them — the bar is never
 * dyed, exactly as on a `PlBox` and a `PlCard`. A toolbar holds other people's
 * controls, and those controls arrive with colours of their own.
 */
const variantClasses = sheetRestClasses;

const positionClasses: Record<PlassPosition, Record<'top' | 'bottom', string>> = {
  static: { top: '', bottom: '' },
  sticky: { top: 'sticky top-0 z-20', bottom: 'sticky bottom-0 z-20' },
  fixed: { top: 'fixed inset-x-0 top-0 z-30', bottom: 'fixed inset-x-0 bottom-0 z-30' }
};

/**
 * The rule faces the content, so it moves to the other edge on a bottom bar.
 *
 * `--plass-divider` and not the sheet's own white edge line: this is a mark the
 * sheet makes on *itself*, and white light on a cut edge only reads when the
 * page wash is behind it.
 */
const dividerClasses: Record<'top' | 'bottom', string> = {
  top: 'border-b [border-color:var(--plass-divider)]',
  bottom: 'border-t [border-color:var(--plass-divider)]'
};

/**
 * A bar of controls: an application header, a page's action row, the strip along
 * the bottom of an editor.
 *
 * Three slots and a row. `start` and `end` are pinned to their ends and
 * `children` takes what is left, which is the arrangement every toolbar has ever
 * had — so it is laid out here rather than left to a caller and a spacer `<div>`
 * they have to remember.
 *
 * The one thing it does not do is take a height. A toolbar is as tall as the
 * controls in it plus its padding, and that padding is the `size` / `density`
 * pair every other surface uses — so `density="compact"` gives the dense bar
 * without a second prop meaning the same thing, and without the type scale
 * moving.
 *
 * It has **no `role="toolbar"`**, deliberately. That role is a promise about
 * keyboard behaviour — one tab stop for the whole bar, arrow keys between the
 * controls in it — and a bar that claims it without implementing it is worse for
 * a keyboard reader than one that never claimed anything. What a page header
 * wants is `render={<header />}`; what a genuine roving-focus set of choices
 * wants is a `PlSegmentedButton`, which is one.
 */
export const PlToolbar = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlToolbarProps>(
  function PlToolbar(
    {
      variant = 'glass',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      position = 'static',
      side = 'top',
      divider = false,
      start,
      end,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const classNames = cx(
      'flex w-full min-w-0 items-center',
      sheetPaddingXClasses[density][size],
      sheetPaddingYClasses[density][size],
      sheetSectionGapClasses[size],
      // A pinned bar spans an edge of the window, and a rounded corner against
      // the edge of the screen is a gap with nothing behind it. Only a bar
      // sitting in the flow is a sheet with corners.
      position === 'static' ? radiusClasses[size] : '',
      variantClasses[variant],
      divider ? dividerClasses[side] : '',
      positionClasses[position][side],
      transitionClasses,
      className
    );

    return useRender({
      render: render ?? <div />,
      ref,
      props: {
        className: classNames,
        style: { ...surfaceSlots(color, elevation), ...style },
        children: (
          <>
            {hasContent(start) ? (
              <div className="flex min-w-0 shrink-0 items-center gap-2">{start}</div>
            ) : null}

            {/* `flex-1` even when empty, so `start` and `end` stay at their ends
                rather than collapsing together in the middle of the bar. */}
            <div className="flex min-w-0 flex-1 items-center gap-2">{children}</div>

            {hasContent(end) ? (
              <div className="flex min-w-0 shrink-0 items-center gap-2">{end}</div>
            ) : null}
          </>
        ),
        ...props
      }
    });
  }
);
