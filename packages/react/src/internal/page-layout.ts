'use client';

import * as React from 'react';
import { useMediaQuery } from './media.js';
import type { PlassBreakpoint, PlassSide } from '../types.js';

/**
 * The vocabulary a page's structure is written in, and the context the four
 * components that build one share.
 *
 * It lives here for the reason `menu.ts` does rather than the reason
 * `button-group.ts` does: five components read it — `PlPageLayout`, `PlHeader`,
 * `PlFooter`, `PlSidebar` and `PlSidebarTrigger` — and every one of them is
 * also usable on its own. Keeping the context in the layout's own file would
 * make a header import a layout it may never be inside.
 *
 * Nothing here draws anything. The arrangement is flexbox and media queries,
 * both of which CSS states better than JavaScript can; what needs a context is
 * the handful of facts a slot cannot work out from where it sits — how wide the
 * window has to be before a sidebar stops being a column, and whether a drawer
 * is open.
 */

/** Which end of the band a sidebar takes. Logical, so it flips under RTL. */
export type PlassSidebarSide = 'start' | 'end';

/** The two slots a layout measures, because a sidebar has to start below them. */
export type PlPageLayoutSlot = 'header' | 'footer';

/**
 * How far across a header or a footer reaches.
 *
 * - `full` — the whole width, with the sidebars beginning underneath it. The
 *   arrangement of a website: one bar across the top, and the page below it.
 * - `content` — only the column between the sidebars, which run the full height
 *   of the window beside it. The arrangement of an application: the navigation
 *   is the outermost thing on the screen and the bar belongs to the view.
 *
 * There is no third value, because there is no third arrangement: what is being
 * decided is which of the two takes the corner.
 */
export type PlPageLayoutSpan = 'full' | 'content';

/**
 * What scrolls.
 *
 * - `page` — the document does, the way a website does. The header and the
 *   sidebars hold their place with `position: sticky`, the browser's own
 *   address bar hides on a phone, and the scroll position is restored on a back
 *   navigation. This is the default, and it is what almost every page wants.
 * - `content` — the layout takes exactly the height of the window and only the
 *   region between the header and the footer scrolls, the way an application
 *   does. Reach for it when the page is a workspace rather than a document.
 */
export type PlPageLayoutScroll = 'page' | 'content';

/**
 * The width below which a sidebar stops being part of the layout and becomes a
 * drawer that is opened, or `none` to keep it a column at every width.
 *
 * `xs` is the breakpoint whose floor is `0`, so nothing is ever below it — it
 * means the same as `none`, and is accepted only because `PlassBreakpoint` has
 * five values everywhere else in the library.
 */
export type PlPageLayoutCollapse = PlassBreakpoint | 'none';

export interface PlPageLayoutContextValue {
  /**
   * Whether there is a `PlPageLayout` above at all.
   *
   * A header, a footer and a sidebar all render perfectly well without one —
   * they are a bar, a bar and a panel. What they cannot do on their own is
   * agree with each other about where they sit, which is the whole of what a
   * layout adds and the reason a component has to be able to tell.
   */
  present: boolean;
  /**
   * Hands the layout the element filling one of its slots.
   *
   * The layout measures it and writes its height onto its own root as a custom
   * property, because a sidebar that holds its place has to start below a
   * header whose height only the header knows. A callback rather than a
   * `querySelector`, so a bar rendered through `render={<MyBar />}` is found as
   * reliably as one that is not.
   */
  register: (slot: PlPageLayoutSlot, node: HTMLElement | null) => void;
  /** Where the sidebars stop being columns. */
  collapseBelow: PlPageLayoutCollapse;
  /** Whether each sidebar's drawer is open. Only meaningful while it is collapsed. */
  open: Record<PlassSidebarSide, boolean>;
  setOpen: (side: PlassSidebarSide, open: boolean) => void;
  /** How the page scrolls, which decides how a sidebar holds its place. */
  scroll: PlPageLayoutScroll;
}

export const PlPageLayoutContext = /* @__PURE__ */ React.createContext<PlPageLayoutContextValue>({
  present: false,
  register: () => {},
  collapseBelow: 'none',
  open: { start: false, end: false },
  setOpen: () => {},
  scroll: 'page'
});

/**
 * Which end of the band the sidebar being rendered right now takes.
 *
 * A second, one-value context rather than a field on the one above, because it
 * is the one fact that differs *between* two sidebars in the same layout: the
 * layout wraps each slot in its own provider, so a sidebar handed to the
 * trailing slot needs no `side` prop of its own to know where it is. `null` is
 * "nobody said", which a standalone sidebar reads as `start`.
 */
export const PlassSidebarSideContext = /* @__PURE__ */ React.createContext<PlassSidebarSide | null>(
  null
);

/**
 * The media query each breakpoint's floor makes, written the way `styles.css`
 * writes the grid's.
 *
 * `xs` has no query because its floor is zero: there is no width below it, so a
 * sidebar that collapses there never collapses.
 */
const collapseQueries: Record<PlassBreakpoint, string | null> = {
  xs: null,
  sm: '(width < 40rem)',
  md: '(width < 48rem)',
  lg: '(width < 64rem)',
  xl: '(width < 80rem)'
};

/**
 * The same five widths as Tailwind variants, for the parts of this that are
 * decided in CSS rather than in JavaScript.
 *
 * Written out per breakpoint because Tailwind only ever sees class names that
 * appear literally in the source — the same reason every table in
 * `internal/styles.ts` is a `Record` of complete strings.
 *
 * `collapsedOnlyClasses` hides something at and above the breakpoint, which is
 * what a sidebar's own trigger wants: the hamburger exists exactly while the
 * column does not. `expandedOnlyClasses` hides it below, which is what the
 * column wants for the one paint between the server's HTML arriving and
 * JavaScript finding out how wide the window is — without it a phone draws the
 * sidebar full width and then throws it away.
 */
export const collapsedOnlyClasses: Record<PlPageLayoutCollapse, string> = {
  none: 'hidden',
  xs: 'hidden',
  sm: 'sm:hidden',
  md: 'md:hidden',
  lg: 'lg:hidden',
  xl: 'xl:hidden'
};

export const expandedOnlyClasses: Record<PlPageLayoutCollapse, string> = {
  none: '',
  xs: '',
  sm: 'max-sm:hidden',
  md: 'max-md:hidden',
  lg: 'max-lg:hidden',
  xl: 'max-xl:hidden'
};

/**
 * Whether the window is currently narrower than the breakpoint a sidebar
 * collapses at.
 *
 * The store behind it is `internal/media.ts`, and the one reason that matters
 * here is its server snapshot: the server's answer has to be "not collapsed". A
 * collapsed sidebar is a `PlDrawer`, a drawer is a portal, and a portal
 * rendered into `document.body` on the server is not a thing — so the markup
 * that ships is the column, and the classes above are what keep that column off
 * a narrow screen until this hook can say otherwise.
 */
export function useCollapsed(breakpoint: PlPageLayoutCollapse): boolean {
  return useMediaQuery(breakpoint === 'none' ? null : collapseQueries[breakpoint]);
}

/**
 * `start` and `end` as the two sides a `PlDrawer` speaks.
 *
 * A sidebar says which end of the band it takes, because that is a layout
 * question and a layout flips under RTL on its own. A drawer is attached to an
 * edge of the *window*, which `PlassSide` names physically for the same reason
 * a tooltip above a button is above it in every writing direction — so the two
 * have to be translated, and the document's own direction is what translates
 * them.
 *
 * Read during render rather than in an effect, which is safe here for a
 * narrower reason than it looks: the only caller is a sidebar that has already
 * collapsed, and collapsing is a client-side answer. There is no server render
 * of this to disagree with.
 */
export function drawerSide(side: PlassSidebarSide): PlassSide {
  const rtl =
    typeof document !== 'undefined' &&
    getComputedStyle(document.documentElement).direction === 'rtl';

  if (side === 'start') return rtl ? 'right' : 'left';

  return rtl ? 'left' : 'right';
}
