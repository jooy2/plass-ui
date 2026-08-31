'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import {
  PlPageLayoutContext,
  PlassSidebarSideContext,
  type PlPageLayoutCollapse,
  type PlPageLayoutScroll,
  type PlPageLayoutSlot,
  type PlPageLayoutSpan,
  type PlassSidebarSide
} from '../../internal/page-layout.js';
import { controlSlots, cx, hasContent, toLength } from '../../internal/styles.js';
import type { PlassColor } from '../../types.js';

export type {
  PlPageLayoutCollapse,
  PlPageLayoutScroll,
  PlPageLayoutSpan
} from '../../internal/page-layout.js';

export interface PlPageLayoutProps extends React.ComponentPropsWithoutRef<'div'> {
  /** The bar across the top. A `PlHeader`, usually. */
  header?: React.ReactNode;
  /** The sheet at the end. A `PlFooter`, usually. */
  footer?: React.ReactNode;
  /**
   * The leading column — the left of an English page, the right of an Arabic
   * one. A `PlSidebar`, which is told which end it is on and needs no `side`
   * prop of its own in here.
   */
  sidebar?: React.ReactNode;
  /**
   * The trailing column, for the layouts that have two: navigation down one
   * side and a table of contents, an inspector or a filter panel down the
   * other. Each is a sidebar with its own width, its own drawer and its own
   * trigger.
   */
  endSidebar?: React.ReactNode;
  /**
   * Which of the header and the sidebars takes the top corner.
   *
   * - `full` — the header spans the whole width and the sidebars begin
   *   underneath it. The arrangement of a website. The default.
   * - `content` — the sidebars run the full height of the window and the header
   *   sits between them, belonging to the view rather than to the site. The
   *   arrangement of an application.
   * @default 'full'
   */
  headerSpan?: PlPageLayoutSpan;
  /**
   * The same question for the footer, and it is worth answering separately: a
   * dashboard with a full-height navigation rail still usually wants its
   * copyright line under the content rather than under the rail.
   * @default 'full'
   */
  footerSpan?: PlPageLayoutSpan;
  /**
   * What scrolls: the document, or only the region between the header and the
   * footer.
   *
   * `page` is the default and is what almost every page wants — the browser's
   * own address bar hides on a phone, the scroll position is restored on a back
   * navigation, and the header holds its place with `position: sticky` without
   * anything having to be padded out of its way. Reach for `content` when the
   * page is a workspace rather than a document.
   * @default 'page'
   */
  scroll?: PlPageLayoutScroll;
  /**
   * How tall the layout is.
   *
   * - `viewport` — the window's, which is what a page wants: a short page still
   *   pushes its footer to the bottom of the screen, and with `scroll="content"`
   *   the layout is exactly one screen tall. The default.
   * - `auto` — its parent's, for a layout that is not the page. An app shell
   *   inside a preview, a pane of a larger tool, the frame in a documentation
   *   demo.
   * - a length — a number in pixels, or any CSS length.
   *
   * It sets a floor while the page scrolls and an exact height while only the
   * content does, which is the same difference `scroll` makes everywhere else.
   * @default 'viewport'
   */
  height?: 'viewport' | 'auto' | number | string;
  /**
   * The window width below which the sidebars stop being columns and become
   * drawers, with a `PlSidebarTrigger` as the way to open them. `none` keeps
   * them as columns at every width.
   * @default 'md'
   */
  collapseBelow?: PlPageLayoutCollapse;
  /**
   * Whether the leading sidebar's drawer is open. Use with
   * `onSidebarOpenChange` for a controlled layout — a route change that should
   * close the drawer behind it, a state the app already stores.
   */
  sidebarOpen?: boolean;
  /** Which state it starts in. @default false */
  defaultSidebarOpen?: boolean;
  onSidebarOpenChange?: (open: boolean) => void;
  /** The same three for the trailing sidebar. */
  endSidebarOpen?: boolean;
  defaultEndSidebarOpen?: boolean;
  onEndSidebarOpenChange?: (open: boolean) => void;
  /**
   * Puts a "Skip to content" link first in the document, drawn only while it
   * holds the focus.
   *
   * On by default, and it is the one thing here that is not a style decision. A
   * keyboard reader arriving on a page whose navigation holds forty links has
   * to walk past all forty on every page before reaching the article, and this
   * is the one link that spares them. It costs a sighted reader nothing,
   * because it is invisible until it is tabbed to.
   * @default true
   */
  skipLink?: boolean;
  /** What that link says. @default 'Skip to content' */
  skipLabel?: React.ReactNode;
  /**
   * The `id` the skip link jumps to, put on the `<main>`.
   * @default 'main'
   */
  mainId?: string;
  /** Anything else the `<main>` needs — a `className`, an `aria-label`. */
  mainProps?: Omit<React.ComponentPropsWithoutRef<'main'>, 'id' | 'children'>;
  /** The colour family the skip link lights up in. @default 'primary' */
  color?: PlassColor;
  /** The page. Rendered inside the `<main>`. */
  children?: React.ReactNode;
}

/** The two slots whose height something else has to start below. */
const SLOTS: readonly PlPageLayoutSlot[] = ['header', 'footer'];

/**
 * The skeleton a page is hung on: a header, a footer, one sidebar or two, and
 * the content between them.
 *
 * What it is really for is the landmarks. A page assembled out of `<div>`s is a
 * page a screen reader offers as one undifferentiated region and a search
 * engine reads as one undifferentiated blob; the same page built out of
 * `<header>`, `<nav>`, `<aside>`, `<main>` and `<footer>` is a page with a
 * table of contents. Those tags come from the components this one arranges — it
 * draws no surface of its own and contributes exactly one element to the
 * document, plus the `<main>` and the skip link that jumps to it.
 *
 * The arrangement is flexbox and media queries, which is deliberate rather than
 * incidental: everything that decides where a column goes is stated in CSS, so
 * the layout is right in the first frame the browser paints and right in a page
 * with JavaScript turned off. The only things measured are the header's and the
 * footer's heights, and only because a sidebar that holds its place has to
 * start below a bar whose height nobody but the bar knows.
 *
 * It draws no gutter and no measure. That is `PlContainer`'s job, and a layout
 * that also did it would be a second spelling of one idea — put a container
 * inside, where a page can have a wide dashboard on one route and a narrow
 * article on the next.
 */
export const PlPageLayout = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlPageLayoutProps>(
  function PlPageLayout(
    {
      header,
      footer,
      sidebar,
      endSidebar,
      headerSpan = 'full',
      footerSpan = 'full',
      scroll = 'page',
      height = 'viewport',
      collapseBelow = 'md',
      sidebarOpen,
      defaultSidebarOpen = false,
      onSidebarOpenChange,
      endSidebarOpen,
      defaultEndSidebarOpen = false,
      onEndSidebarOpenChange,
      skipLink = true,
      skipLabel = 'Skip to content',
      mainId = 'main',
      mainProps,
      color: colorProp,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const color = colorProp ?? defaults.color ?? 'primary';

    const [ownStart, setOwnStart] = React.useState(defaultSidebarOpen);
    const [ownEnd, setOwnEnd] = React.useState(defaultEndSidebarOpen);

    const open = React.useMemo(
      () => ({ start: sidebarOpen ?? ownStart, end: endSidebarOpen ?? ownEnd }),
      [sidebarOpen, ownStart, endSidebarOpen, ownEnd]
    );

    const setOpen = React.useCallback(
      (side: PlassSidebarSide, next: boolean) => {
        if (side === 'start') {
          if (sidebarOpen === undefined) setOwnStart(next);
          onSidebarOpenChange?.(next);
          return;
        }

        if (endSidebarOpen === undefined) setOwnEnd(next);
        onEndSidebarOpenChange?.(next);
      },
      [sidebarOpen, endSidebarOpen, onSidebarOpenChange, onEndSidebarOpenChange]
    );

    const rootRef = React.useRef<HTMLDivElement | null>(null);
    const setRootRef = React.useCallback(
      (node: HTMLDivElement | null) => {
        rootRef.current = node;

        if (typeof ref === 'function') ref(node);
        else if (ref) ref.current = node;
      },
      [ref]
    );

    const slotsRef = React.useRef<Record<PlPageLayoutSlot, HTMLElement | null>>({
      header: null,
      footer: null
    });
    const observerRef = React.useRef<ResizeObserver | null>(null);

    /**
     * Writes what the header and the footer take out of the viewport onto the
     * root, as two custom properties each.
     *
     * They are two rather than one because a bar takes two different things
     * away depending on how it is positioned, and a sidebar and the page need
     * opposite halves of that. A `sticky` bar is still in the flow, so nothing
     * has to be reserved for it — but it is permanently across the top of the
     * window, so a column that holds its place has to start below it. A `fixed`
     * bar is out of the flow, so the page *does* have to reserve its height,
     * and it is across the top as well. Which of the two a bar is is read off
     * the element rather than plumbed through a prop: the bar already knows,
     * `position` is what it knows it as, and asking is one line.
     *
     * Written straight to the DOM rather than held in state: nothing in the
     * tree depends on the numbers except a handful of CSS declarations, and a
     * `setState` here would re-render the whole page on every resize.
     */
    const measure = React.useCallback(() => {
      const root = rootRef.current;
      if (!root) return;

      for (const slot of SLOTS) {
        const node = slotsRef.current[slot];
        const span = slot === 'header' ? headerSpan : footerSpan;

        if (!node) {
          root.style.setProperty(`--p-layout-${slot}`, '0px');
          root.style.setProperty(`--p-layout-${slot}-inset`, '0px');
          continue;
        }

        const position = getComputedStyle(node).position;
        const extent = `${node.offsetHeight}px`;
        const pinned = position === 'sticky' || position === 'fixed';

        // A bar that only spans the content column has the sidebars *beside*
        // it, not under it, so it takes nothing off the top of theirs.
        root.style.setProperty(`--p-layout-${slot}`, pinned && span === 'full' ? extent : '0px');
        root.style.setProperty(`--p-layout-${slot}-inset`, position === 'fixed' ? extent : '0px');
      }
    }, [headerSpan, footerSpan]);

    const observe = React.useCallback(() => {
      const observer = observerRef.current;

      if (observer) {
        observer.disconnect();

        for (const slot of SLOTS) {
          const node = slotsRef.current[slot];
          if (node) observer.observe(node);
        }
      }

      measure();
    }, [measure]);

    React.useEffect(() => {
      observerRef.current = new ResizeObserver(() => measure());
      observe();

      return () => {
        observerRef.current?.disconnect();
        observerRef.current = null;
      };
    }, [measure, observe]);

    const register = React.useCallback(
      (slot: PlPageLayoutSlot, node: HTMLElement | null) => {
        slotsRef.current[slot] = node;
        observe();
      },
      [observe]
    );

    const context = React.useMemo(
      () => ({ present: true, register, collapseBelow, open, setOpen, scroll }),
      [register, collapseBelow, open, setOpen, scroll]
    );

    const fills = scroll === 'content';

    // A named height is a class, because both of those are exactly two class
    // names; anything else is a length nobody could have generated one for.
    const extent = toLength(height === 'viewport' || height === 'auto' ? undefined : height);
    const extentClasses =
      extent !== undefined
        ? ''
        : height === 'auto'
          ? fills
            ? 'h-full'
            : 'min-h-full'
          : fills
            ? 'h-dvh'
            : 'min-h-dvh';

    const headerSlot = hasContent(header) ? header : null;
    const footerSlot = hasContent(footer) ? footer : null;

    return (
      <PlPageLayoutContext.Provider value={context}>
        <div
          ref={setRootRef}
          className={cx(
            'relative flex w-full flex-col',
            // The whole difference between a document and a workspace. A floor
            // lets the page grow and the window scroll it; an exact height with
            // the overflow taken away pins the layout down and hands the
            // scrolling to whichever region below asks for it.
            fills ? 'overflow-hidden' : '',
            extentClasses,
            headerSpan === 'full' ? '[padding-top:var(--p-layout-header-inset,0px)]' : '',
            footerSpan === 'full' ? '[padding-bottom:var(--p-layout-footer-inset,0px)]' : '',
            className
          )}
          style={
            extent === undefined
              ? style
              : { ...(fills ? { height: extent } : { minHeight: extent }), ...style }
          }
          {...props}
        >
          {skipLink ? (
            <a
              href={`#${mainId}`}
              // Clipped to a pixel until it is tabbed to, and a real key from
              // then on — not `hidden`, which would take it off the
              // accessibility tree along with the screen and leave nothing for
              // the Tab key to find in the first place. `z-40` clears a `fixed`
              // header and stays under a portal, which is the one thing that
              // should be over it.
              className={cx(
                'absolute start-3 top-3 z-40 size-px overflow-hidden whitespace-nowrap',
                '[clip-path:inset(50%)] focus:size-auto focus:overflow-visible focus:[clip-path:none]',
                'focus:rounded-(--plass-radius-md) focus:[background-image:var(--p-fill)]',
                'focus:px-4 focus:py-2 focus:font-medium focus:text-(--p-on-solid) focus:no-underline',
                'focus:[box-shadow:var(--p-elev),var(--p-lift)]',
                'focus:[outline:2px_solid_var(--p-ring)] focus:[outline-offset:0px]'
              )}
              style={controlSlots(color, 2, 'solid')}
            >
              {skipLabel}
            </a>
          ) : null}

          {headerSpan === 'full' ? headerSlot : null}

          <div className={cx('flex w-full flex-1', fills ? 'min-h-0' : '')}>
            {hasContent(sidebar) ? (
              <PlassSidebarSideContext.Provider value="start">
                {sidebar}
              </PlassSidebarSideContext.Provider>
            ) : null}

            <div
              className={cx(
                'flex min-w-0 flex-1 flex-col',
                fills ? 'min-h-0' : '',
                headerSpan === 'content' ? '[padding-top:var(--p-layout-header-inset,0px)]' : '',
                footerSpan === 'content' ? '[padding-bottom:var(--p-layout-footer-inset,0px)]' : ''
              )}
            >
              {headerSpan === 'content' ? headerSlot : null}

              <main
                {...mainProps}
                id={mainId}
                className={cx(
                  'min-w-0 flex-1',
                  fills ? 'min-h-0 overflow-y-auto' : '',
                  mainProps?.className
                )}
              >
                {children}
              </main>

              {footerSpan === 'content' ? footerSlot : null}
            </div>

            {hasContent(endSidebar) ? (
              <PlassSidebarSideContext.Provider value="end">
                {endSidebar}
              </PlassSidebarSideContext.Provider>
            ) : null}
          </div>

          {footerSpan === 'full' ? footerSlot : null}
        </div>
      </PlPageLayoutContext.Provider>
    );
  }
);
