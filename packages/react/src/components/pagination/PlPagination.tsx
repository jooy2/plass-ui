import * as React from 'react';
import { PlButton } from '../button/PlButton';
import { ChevronIcon } from '../../internal/icons';
import { controlTextClasses, gapClasses, srOnlyClasses } from '../../internal/styles';
import type { PlassElevation, PlassSize, PlassStyleProps } from '../../types';

export interface PlPaginationProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'nav'>, 'color' | 'onChange'> {
  /** How many pages there are. Fewer than two and the whole control renders nothing. */
  count: number;
  /** The current page, 1-based. Use with `onPageChange` for a controlled row. */
  page?: number;
  /** Which page starts current, for an uncontrolled one. @default 1 */
  defaultPage?: number;
  onPageChange?: (page: number) => void;
  /**
   * How many pages are always shown on either side of the current one.
   * @default 1
   */
  siblingCount?: number;
  /**
   * How many pages are always shown at each end, whatever the current page is.
   * `0` drops the first and last page from the row, leaving only the window.
   * @default 1
   */
  boundaryCount?: number;
  /** Shows the jump-to-first and jump-to-last steppers. @default false */
  showEdges?: boolean;
  /** Shows the previous and next steppers. @default true */
  showArrows?: boolean;
  /**
   * Drop shadow depth of the page buttons. `0` is the default: a row of nine
   * keys each casting its own shadow is nine shadows.
   * @default 0
   */
  elevation?: PlassElevation;
  /** Unavailable. Every button in the row stops answering. */
  disabled?: boolean;
  /**
   * The address of a page, which turns every number in the row into a real
   * link.
   *
   * Without it the row is buttons, and a crawler cannot press one — so a paged
   * list of articles, products or search results exists for a reader and stops
   * at page one for everything else. With it the numbers are `<a href>`, the
   * two arrows carry `rel="prev"` / `rel="next"`, and the browser's own
   * behaviour comes back: open in a new tab, copy the address, see where a
   * press is going before making it.
   *
   * `onPageChange` still fires and the press is still cancelled first, so a
   * client-side router keeps the page it already has. A link with nowhere to go
   * — the current page, a stepper at the end of the row — stays a `<button>`,
   * because `disabled` is not something an `<a>` can be.
   */
  getPageHref?: (page: number) => string;
  /**
   * The accessible names, none of which is ever drawn.
   *
   * They are props rather than being read from a message catalogue for the same
   * reason `PlTable` takes its `empty` line as one: a library that shipped
   * translations would have to be told which language a page is in, and the page
   * already knows.
   */
  label?: string;
  /** Accessible name of a page button. @default `Page {n}` */
  pageLabel?: (page: number) => string;
  previousLabel?: string;
  nextLabel?: string;
  firstLabel?: string;
  lastLabel?: string;
  /** The live-region sentence a screen reader hears when the page changes. */
  statusLabel?: (page: number, count: number) => string;
}

/** `'…'` in two flavours, so a caller reading the range can tell them apart. */
type PaginationSlot = number | 'start-ellipsis' | 'end-ellipsis';

function range(start: number, end: number): number[] {
  return Array.from({ length: Math.max(0, end - start + 1) }, (_, index) => start + index);
}

/**
 * Which pages the row actually shows.
 *
 * The shape every pagination converges on — a fixed run at each end, a window
 * around the current page, and an ellipsis wherever those leave a gap — with one
 * detail that is easy to get wrong and matters: a gap of exactly one page is
 * filled with that page rather than with an ellipsis. `1 … 3 … 9` hides a single
 * number behind a symbol wider than the number it replaced.
 *
 * The row is also pinned to a constant number of slots, whatever page it is on:
 * the window slides toward whichever end it is near instead of being clipped by
 * it, so page 1 shows `1 2 3 4 5 … 20` and page 10 shows `1 … 9 10 11 … 20`.
 * Which slots are pages and which are ellipses changes; how many there are does
 * not. Without that, stepping from page 1 to page 2 would relayout the row and
 * every button would move out from under the pointer that just pressed one.
 */
function paginationRange(
  count: number,
  page: number,
  siblingCount: number,
  boundaryCount: number
): PaginationSlot[] {
  const startPages = range(1, Math.min(boundaryCount, count));
  const endPages = range(Math.max(count - boundaryCount + 1, boundaryCount + 1), count);

  const siblingsStart = Math.max(
    Math.min(page - siblingCount, count - boundaryCount - siblingCount * 2 - 1),
    boundaryCount + 2
  );
  const siblingsEnd = Math.min(
    Math.max(page + siblingCount, boundaryCount + siblingCount * 2 + 2),
    endPages.length > 0 ? endPages[0] - 2 : count - 1
  );

  return [
    ...startPages,

    // An ellipsis when more than one page is hidden, the page itself when
    // exactly one is, and nothing when none is.
    ...(siblingsStart > boundaryCount + 2
      ? (['start-ellipsis'] as PaginationSlot[])
      : boundaryCount + 1 < count - boundaryCount
        ? [boundaryCount + 1]
        : []),

    ...range(siblingsStart, siblingsEnd),

    ...(siblingsEnd < count - boundaryCount - 1
      ? (['end-ellipsis'] as PaginationSlot[])
      : count - boundaryCount > boundaryCount
        ? [count - boundaryCount]
        : []),

    ...endPages
  ];
}

/** Two chevrons, for the steppers that jump to an end rather than by one page. */
function DoubleChevronIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m7.5 4.5 3.5 3.5-3.5 3.5M3.5 4.5 7 8l-3.5 3.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/**
 * The ellipsis. A `<span>`, not a button and not a disabled button: it is not a
 * control that happens to be unavailable, it is punctuation.
 */
const ellipsisClasses: Record<PlassSize, string> = {
  xs: 'h-6 min-w-6',
  sm: 'h-8 min-w-8',
  md: 'h-10 min-w-10',
  lg: 'h-12 min-w-12',
  xl: 'h-14 min-w-14'
};

/**
 * A row of page numbers.
 *
 * Every button in it is a real `PlButton`, which is the point: a pagination is
 * not a new kind of control, it is buttons in a row that happen to know about
 * each other. Reusing the component means the row inherits the glass, the
 * pointer bloom, the press signature, the focus ring and every future change to
 * any of them for free — and it means an `lg` pagination lines up with an `lg`
 * button beside it, because it *is* one.
 *
 * `variant` sets how the pages at rest look; the current page is always `solid`,
 * which is the one thing the row has to say without being read. That is why the
 * default here is `ghost` rather than the `solid` a lone PlButton takes — nine
 * panes of tinted glass in a row say that all nine are the primary action.
 *
 * The markup is a `<nav>` around a `<ul>` because that is what a screen reader
 * needs to hear: a named landmark it can skip, holding a list whose length says
 * how far the pages go, with `aria-current="page"` marking where it is.
 */
export const PlPagination = React.forwardRef<HTMLElement, PlPaginationProps>(function PlPagination(
  {
    variant = 'ghost',
    size = 'md',
    color = 'primary',
    density = 'compact',
    elevation = 0,
    count,
    page: pageProp,
    defaultPage = 1,
    onPageChange,
    siblingCount = 1,
    boundaryCount = 1,
    showEdges = false,
    showArrows = true,
    disabled = false,
    getPageHref,
    label = 'Pagination',
    pageLabel = (value) => `Page ${value}`,
    previousLabel = 'Previous page',
    nextLabel = 'Next page',
    firstLabel = 'First page',
    lastLabel = 'Last page',
    statusLabel = (value, total) => `Page ${value} of ${total}`,
    className,
    children,
    ...props
  },
  ref
) {
  const [uncontrolled, setUncontrolled] = React.useState(defaultPage);
  const current = Math.min(Math.max(pageProp ?? uncontrolled, 1), Math.max(count, 1));

  const go = (next: number) => {
    const clamped = Math.min(Math.max(next, 1), count);

    if (clamped === current) {
      return;
    }
    if (pageProp === undefined) {
      setUncontrolled(clamped);
    }
    onPageChange?.(clamped);
  };

  // One page is not a set of pages, and no pages is not a thing to say out
  // loud. A row that renders a lone disabled "1" is a control advertising
  // that it has nothing to do.
  if (count < 2) {
    return null;
  }

  const slots = paginationRange(count, current, siblingCount, boundaryCount);
  const atStart = current <= 1;
  const atEnd = current >= count;

  /*
   * A link only where there is somewhere to go. The page being read and a
   * stepper at the end of the row are both `disabled`, and `disabled` is not
   * something an `<a>` can be — a link that only looks unavailable is one a
   * keyboard still lands on and a crawler still follows.
   */
  const linkProps = (to: number, inert: boolean, rel?: 'prev' | 'next') =>
    getPageHref && !inert ? { render: <a href={getPageHref(to)} rel={rel} /> } : null;

  /*
   * Who answers the press.
   *
   * With an `href` and a handler both, the handler wins and the navigation is
   * cancelled: that is a client-side router keeping the page it already has.
   * With an `href` and no handler, the link is left to do what a link does —
   * which is also what makes the row work with JavaScript still loading.
   */
  const press = (event: React.MouseEvent<HTMLElement>, to: number) => {
    // A press carrying a modifier is the reader asking the browser for it: a
    // new tab, a new window, a saved copy. Never ours to cancel.
    if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) {
      return;
    }

    if (getPageHref && !onPageChange) {
      return;
    }

    event.preventDefault();
    go(to);
  };

  /**
   * The steppers. Icon-only PlButtons, so they go square and land on exactly
   * the same footprint as a single-digit page — a row whose ends are a
   * different width from its middle reads as two controls pushed together.
   */
  const stepper = (
    key: string,
    accessibleName: string,
    to: number,
    inert: boolean,
    rotation: string,
    glyph: React.ReactNode,
    rel?: 'prev' | 'next'
  ) => (
    <li key={key} className="flex">
      <PlButton
        variant={variant}
        size={size}
        color={color}
        density={density}
        elevation={elevation}
        disabled={disabled || inert}
        aria-label={accessibleName}
        startIcon={<span className={`flex items-center ${rotation}`}>{glyph}</span>}
        onClick={(event) => press(event, to)}
        {...linkProps(to, disabled || inert, rel)}
      />
    </li>
  );

  return (
    <nav
      ref={ref}
      aria-label={label}
      className={['flex items-center', className ?? ''].filter(Boolean).join(' ')}
      {...props}
    >
      <ul role="list" className={`m-0 flex list-none items-center p-0 ${gapClasses[size]}`}>
        {showEdges
          ? stepper(
              'first',
              firstLabel,
              1,
              atStart,
              'rotate-180 rtl:rotate-0',
              <DoubleChevronIcon />
            )
          : null}

        {showArrows
          ? stepper(
              'previous',
              previousLabel,
              current - 1,
              atStart,
              'rotate-90 rtl:-rotate-90',
              <ChevronIcon />,
              'prev'
            )
          : null}

        {/* Keyed by *slot*, never by page number.
              The window recentres on the page that was just chosen, so almost
              every number moves one place along — and with the number as the
              key, React moves the DOM nodes to match. The button under the
              pointer is then a different element from the one that was pressed:
              its hover bloom fades out while a freshly mounted neighbour's fades
              in from the centre it has no pointer position for, and the release
              afterglow drains somewhere the cursor is not. That reads as a
              flicker. Keying by position keeps every node where it is and
              changes only its label and variant, which is what the row is
              actually doing. */}
        {slots.map((slot, index) =>
          typeof slot === 'number' ? (
            <li key={`slot-${index}`} className="flex">
              <PlButton
                // The current page is always filled, whatever the row's
                // resting variant is: it is the one thing here that has to be
                // legible without being read.
                variant={slot === current ? 'solid' : variant}
                size={size}
                color={color}
                density={density}
                elevation={elevation}
                disabled={disabled}
                aria-label={pageLabel(slot)}
                aria-current={slot === current ? 'page' : undefined}
                className="tabular-nums"
                onClick={(event) => press(event, slot)}
                // The page being read is not somewhere to go, so it keeps its
                // `aria-current` and stops being a link.
                {...linkProps(slot, disabled || slot === current)}
              >
                {slot}
              </PlButton>
            </li>
          ) : (
            <li
              key={`slot-${index}`}
              aria-hidden="true"
              className={[
                'flex select-none items-center justify-center',
                'text-(--plass-muted-fg)',
                controlTextClasses[size],
                ellipsisClasses[size]
              ].join(' ')}
            >
              …
            </li>
          )
        )}

        {showArrows
          ? stepper(
              'next',
              nextLabel,
              current + 1,
              atEnd,
              '-rotate-90 rtl:rotate-90',
              <ChevronIcon />,
              'next'
            )
          : null}

        {showEdges
          ? stepper('last', lastLabel, count, atEnd, 'rtl:rotate-180', <DoubleChevronIcon />)
          : null}
      </ul>

      {/* Where the reader is, as a sentence rather than as a highlighted
            button. `aria-current` says which page is chosen; this says how many
            there are, which the list length alone does not once an ellipsis is
            in it. */}
      <span className={srOnlyClasses} aria-live="polite">
        {statusLabel(current, count)}
      </span>

      {children}
    </nav>
  );
});
