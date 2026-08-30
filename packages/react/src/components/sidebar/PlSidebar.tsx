'use client';

import * as React from 'react';
import { PlDrawer } from '../drawer/PlDrawer.js';
import {
  drawerSide,
  expandedOnlyClasses,
  PlPageLayoutContext,
  PlassSidebarSideContext,
  useCollapsed
} from '../../internal/page-layout.js';
import type { PlPageLayoutCollapse, PlassSidebarSide } from '../../internal/page-layout.js';
import {
  cx,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetRestClasses,
  surfaceSlots,
  toLength,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassColor,
  PlassDensity,
  PlassElevation,
  PlassSize,
  PlassVariant
} from '../../types.js';

export type { PlassSidebarSide } from '../../internal/page-layout.js';

export interface PlSidebarProps extends Omit<
  React.ComponentPropsWithoutRef<'aside'>,
  'color' | 'title'
> {
  /**
   * Which end of the band it takes. Logical rather than physical — `start` is
   * the left of an English page and the right of an Arabic one — because a
   * navigation rail is beside the text it belongs to in every writing
   * direction.
   *
   * Inside a `PlPageLayout` this is already decided by which slot the sidebar
   * was handed to, and setting it again is only a way of disagreeing with the
   * layout.
   * @default 'start'
   */
  side?: PlassSidebarSide;
  /**
   * How wide the column is — a number in pixels or any CSS length. Left out, it
   * is the width `size` implies.
   *
   * With `resizable` it is only the width the sidebar *starts* at: dragging
   * writes over it, and the caller hears about it through `onResize`.
   */
  width?: number | string;
  /** How narrow it may be dragged. @default 160 */
  minWidth?: number | string;
  /** And how wide. @default 480 */
  maxWidth?: number | string;
  /**
   * Lets the reader drag the inner edge to change the column's width.
   *
   * Off by default. A sidebar that can be resized is a sidebar whose width is
   * the reader's to remember, which means a caller who turns this on usually
   * also wants to store what `onResizeEnd` reports.
   * @default false
   */
  resizable?: boolean;
  /** Fires with the width in pixels while the edge is being dragged. */
  onResize?: (width: number) => void;
  /** Fires once, with the same number, when it is let go. */
  onResizeEnd?: (width: number) => void;
  /**
   * The window width below which the sidebar stops being a column and becomes a
   * drawer that is opened — with a `PlSidebarTrigger` somewhere on the page as
   * the way to open it. `none` keeps it a column at every width.
   *
   * Defaults to the `PlPageLayout`'s own `collapseBelow`, and to `none` outside
   * one: a sidebar that collapsed with nothing on the page able to bring it
   * back would be a sidebar the reader has lost.
   */
  collapseBelow?: PlPageLayoutCollapse;
  /**
   * Whether the drawer is open. Only meaningful once the sidebar has collapsed;
   * a column is not opened, it is there.
   *
   * Inside a `PlPageLayout` the layout owns this — it is what a trigger
   * anywhere on the page talks to — so control it there rather than here.
   * `onOpenChange` still fires either way.
   */
  open?: boolean;
  /** Which state it starts in, for an uncontrolled standalone sidebar. @default false */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * Whether the column holds its place while the page scrolls past it.
   *
   * On by default, and it costs nothing when it is not needed: with the page
   * scrolling it becomes a `sticky` column as tall as what is left of the
   * window under the header, and with only the content scrolling it is already
   * as tall as the layout and this changes nothing.
   * @default true
   */
  sticky?: boolean;
  /**
   * The heading, drawn only while the sidebar is a drawer. A column has the
   * page around it to say what it is; a panel that has covered the page does
   * not.
   */
  title?: React.ReactNode;
  /**
   * What the sheet is made of, said the way a **container** says it: the panel
   * is never dyed, because what is on it arrives with colours of its own.
   * @default 'glass'
   */
  variant?: PlassVariant;
  /** The panel's scale — its default width and the air around its content. @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** @default 'default' */
  density?: PlassDensity;
  /** Drop shadow depth. `0` — the default — is flat. @default 0 */
  elevation?: PlassElevation;
  /**
   * Draws a hairline down the inner edge — the one facing the content. The
   * outer edge is against the window, where there is nothing on the other side
   * to be separated from.
   * @default true
   */
  divider?: boolean;
  /** The gutter and the air above and below the content. @default true */
  padded?: boolean;
  /**
   * The name the region is announced by. Every `<aside>` on a page should have
   * one, and a page with two sidebars *must*, or a screen reader offers two
   * regions called "complementary".
   * @default 'Sidebar'
   */
  label?: string;
  /** What the drawer's close button says, once the sidebar has collapsed. @default 'Close sidebar' */
  closeLabel?: string;
  /** What the drag handle is announced as. @default 'Resize sidebar' */
  resizeLabel?: string;
  /** Everything in it: a nav, a filter panel, a table of contents. */
  children?: React.ReactNode;
}

/**
 * The default width, as raw lengths rather than as `w-*` classes.
 *
 * A width that can be dragged has to live in a custom property, because a drag
 * writes a number that no class name could have been generated for — the same
 * split `paddingXValues` makes for a table cell, and for the same reason.
 *
 * `md` is 16rem, which is what a navigation rail has been since sidebars had
 * names: wide enough for two words and an icon, narrow enough that the article
 * beside it still holds a readable measure on a 13" screen.
 */
const widthValues: Record<PlassSize, string> = {
  xs: '11rem',
  sm: '13rem',
  md: '16rem',
  lg: '18rem',
  xl: '21rem'
};

/**
 * The three materials, read the way a *container* reads them, exactly as on
 * `PlHeader` and `PlFooter`.
 */
const variantClasses = sheetRestClasses;

/** How far one arrow key press moves the edge. The same step `PlPanes` uses. */
const KEYBOARD_STEP = 16;

/** A length in pixels, for the two bounds a drag is clamped to. */
function toPixels(value: number | string | undefined, fallback: number): number {
  if (value === undefined || value === null) return fallback;
  if (typeof value === 'number') return value;

  const match = /^\s*(-?[\d.]+)\s*(px|rem|em|%)\s*$/.exec(value);
  if (!match) return fallback;

  const amount = Number(match[1]);
  if (Number.isNaN(amount)) return fallback;

  switch (match[2]) {
    case 'px':
      return amount;
    case '%':
      return typeof window === 'undefined' ? fallback : (window.innerWidth * amount) / 100;
    default:
      return (
        amount *
        parseFloat(
          (typeof document === 'undefined'
            ? ''
            : getComputedStyle(document.documentElement).fontSize) || '16'
        )
      );
  }
}

/**
 * A column beside the page's content, and a drawer once the window is too
 * narrow to hold one.
 *
 * Two presentations of one panel, exactly as `PlDrawer` is: above
 * `collapseBelow` it is an `<aside>` in the layout that the content is laid out
 * around, and below it the same children are a drawer over a scrim with a focus
 * trap, an Escape and a way back to the trigger. They are one component because
 * they are one thing — a caller should not have to swap components at a
 * breakpoint — and because the children only exist once either way, so nothing
 * inside is rendered twice into the document for a screen reader to read twice.
 *
 * Which of the two is showing is a media query, and it is answered in CSS for
 * the first paint and in JavaScript from then on. That split is deliberate: the
 * markup a server sends is the column, so a narrow screen would draw a full
 * width sidebar and throw it away a moment later — the class that hides it
 * below the breakpoint is what stops that, and `matchMedia` is what decides,
 * once there is a window to ask, that the drawer should exist at all.
 *
 * A real `<aside>`, which is the `complementary` landmark: the region a screen
 * reader offers as "related to the page but not the page", and what a search
 * engine reads as navigation chrome rather than as the article.
 */
export const PlSidebar = /* @__PURE__ */ React.forwardRef<HTMLElement, PlSidebarProps>(
  function PlSidebar(
    {
      side: sideProp,
      width: widthProp,
      minWidth = 160,
      maxWidth = 480,
      resizable = false,
      onResize,
      onResizeEnd,
      collapseBelow: collapseBelowProp,
      open: openProp,
      defaultOpen = false,
      onOpenChange,
      sticky = true,
      title,
      variant = 'glass',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      divider = true,
      padded = true,
      label = 'Sidebar',
      closeLabel = 'Close sidebar',
      resizeLabel = 'Resize sidebar',
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const layout = React.useContext(PlPageLayoutContext);
    const slotSide = React.useContext(PlassSidebarSideContext);
    const side = sideProp ?? slotSide ?? 'start';

    const collapseBelow = collapseBelowProp ?? (layout.present ? layout.collapseBelow : 'none');
    const collapsed = useCollapsed(collapseBelow);

    const [ownOpen, setOwnOpen] = React.useState(defaultOpen);
    const controlled = openProp !== undefined;
    const open = controlled ? openProp : layout.present ? layout.open[side] : ownOpen;

    const changeOpen = (next: boolean) => {
      if (!controlled) {
        if (layout.present) layout.setOpen(side, next);
        else setOwnOpen(next);
      }

      onOpenChange?.(next);
    };

    const width = toLength(widthProp) ?? widthValues[size];

    const rootRef = React.useRef<HTMLElement | null>(null);
    const setRootRef = React.useCallback(
      (node: HTMLElement | null) => {
        rootRef.current = node;

        if (typeof ref === 'function') ref(node);
        else if (ref) ref.current = node;
      },
      [ref]
    );

    /**
     * A drag writes the width straight onto the element rather than into state.
     *
     * Nothing in the tree depends on the number except one CSS declaration, and
     * a `setState` per pointer move would re-render every row in the sidebar to
     * change it. The caller still hears every step through `onResize`.
     */
    const teardownRef = React.useRef<(() => void) | null>(null);
    React.useEffect(() => () => teardownRef.current?.(), []);

    const applyWidth = (pixels: number) => {
      const node = rootRef.current;
      if (!node) return pixels;

      const sized = Math.min(
        toPixels(maxWidth, 480),
        Math.max(toPixels(minWidth, 160), Math.round(pixels))
      );

      node.style.setProperty('--p-sidebar-w', `${sized}px`);

      return sized;
    };

    const beginDrag = (event: React.PointerEvent<HTMLDivElement>) => {
      const node = rootRef.current;
      if (!node || event.button !== 0) return;

      const handle = event.currentTarget;
      handle.setPointerCapture(event.pointerId);
      handle.dataset.dragging = 'true';

      // The same prefixed write `PlPanes` makes, for the same reason: WebKit
      // has no `userSelect` on a style declaration, so the unprefixed form
      // changes nothing and Safari selects text through the whole drag.
      const selection = document.body.style.getPropertyValue('-webkit-user-select');
      document.body.style.setProperty('-webkit-user-select', 'none');

      const origin = event.clientX;
      const start = node.getBoundingClientRect().width;
      // Positive is always "wider", so a drag under RTL — where the start edge
      // is on the right — moves the edge the way the pointer went rather than
      // the way the axis is numbered.
      const rtl = getComputedStyle(node).direction === 'rtl';
      const outwards = (side === 'start') === rtl ? -1 : 1;

      let latest = start;

      const move = (moveEvent: PointerEvent) => {
        latest = applyWidth(start + (moveEvent.clientX - origin) * outwards);
        onResize?.(latest);
      };

      const release = () => {
        teardownRef.current = null;
        handle.removeEventListener('pointermove', move);
        handle.removeEventListener('pointerup', end);
        handle.removeEventListener('pointercancel', end);
        delete handle.dataset.dragging;

        if (selection) document.body.style.setProperty('-webkit-user-select', selection);
        else document.body.style.removeProperty('-webkit-user-select');
      };

      const end = () => {
        release();
        onResizeEnd?.(latest);
      };

      teardownRef.current = release;
      handle.addEventListener('pointermove', move);
      handle.addEventListener('pointerup', end);
      handle.addEventListener('pointercancel', end);
    };

    const nudge = (pixels: number) => {
      const node = rootRef.current;
      if (!node) return;

      const next = applyWidth(node.getBoundingClientRect().width + pixels);
      onResize?.(next);
      // A key press is a whole gesture on its own — there is no "let go" to
      // wait for, so the settled callback fires with it.
      onResizeEnd?.(next);
    };

    if (collapsed) {
      return (
        <PlDrawer
          side={drawerSide(side)}
          mode="overlay"
          open={open}
          onOpenChange={changeOpen}
          title={title}
          size={size}
          color={color}
          density={density}
          closeLabel={closeLabel}
          // An explicit width is the caller's decision and survives the change
          // of shape; the default one does not, because a column sized against
          // the article beside it and a panel sized against a phone are two
          // different numbers, and the drawer's own ladder already knows the
          // second.
          extent={widthProp === undefined ? undefined : width}
          aria-label={title ? undefined : label}
          className={className}
          style={style}
        >
          {children}
        </PlDrawer>
      );
    }

    return (
      <aside
        ref={setRootRef}
        aria-label={label}
        className={cx(
          'relative flex min-w-0 shrink-0 flex-col',
          'w-(--p-sidebar-w)',
          variantClasses[variant],
          divider
            ? cx(side === 'start' ? 'border-e' : 'border-s', '[border-color:var(--plass-divider)]')
            : '',
          layout.scroll === 'content'
            ? 'h-full'
            : sticky
              ? cx(
                  'self-start',
                  'sticky [top:var(--p-layout-header,0px)]',
                  '[height:calc(100dvh-var(--p-layout-header,0px)-var(--p-layout-footer,0px))]'
                )
              : '',
          // What holds the first paint together. The server has no window to
          // measure, so it sends the column; this is what keeps that column off
          // a screen too narrow for it until `matchMedia` can say the same.
          expandedOnlyClasses[collapseBelow],
          transitionClasses,
          className
        )}
        style={
          {
            ...surfaceSlots(color, elevation),
            '--p-sidebar-w': width,
            ...style
          } as React.CSSProperties
        }
        {...props}
      >
        <div
          className={cx(
            'min-h-0 flex-1 overflow-y-auto overscroll-contain',
            padded
              ? cx(sheetPaddingXClasses[density][size], sheetPaddingYClasses[density][size])
              : ''
          )}
        >
          {children}
        </div>

        {resizable ? (
          <div
            role="separator"
            aria-orientation="vertical"
            aria-label={resizeLabel}
            tabIndex={0}
            className={cx(
              // Straddling the edge rather than sitting inside it: a hairline
              // one pixel wide is a target one pixel wide, which is not a
              // target. The same split between what is drawn and what can be
              // grabbed that a scrollbar makes, and that `PlPanes` makes.
              'absolute inset-y-0 z-1 w-2 cursor-col-resize',
              side === 'start' ? 'end-0 -me-1' : 'start-0 -ms-1',
              'bg-transparent hover:bg-(--p-soft) data-[dragging]:bg-(--p-soft)',
              transitionClasses,
              '[outline:none] focus-visible:[outline:2px_solid_var(--p-ring)]',
              'focus-visible:[outline-offset:0px]'
            )}
            onPointerDown={beginDrag}
            onKeyDown={(event) => {
              if (event.key !== 'ArrowLeft' && event.key !== 'ArrowRight') return;
              event.preventDefault();

              const rtl = getComputedStyle(event.currentTarget).direction === 'rtl';
              const outwards = (side === 'start') === rtl ? -1 : 1;
              nudge((event.key === 'ArrowRight' ? KEYBOARD_STEP : -KEYBOARD_STEP) * outwards);
            }}
          />
        ) : null}
      </aside>
    );
  }
);
