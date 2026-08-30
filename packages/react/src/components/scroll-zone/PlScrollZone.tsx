'use client';

import * as React from 'react';
import { PlIconButton } from '../icon-button/PlIconButton.js';
import { spacingValue } from '../../internal/grid.js';
import { ChevronIcon } from '../../internal/icons.js';
import { cx } from '../../internal/styles.js';
import type { PlassOrientation, PlassSize, PlassStyleProps } from '../../types.js';

/**
 * When the scroll buttons are drawn.
 *
 * - `auto` — only the one that has somewhere to go, and neither of them while
 *   everything fits. The default: a control that cannot do anything is worse
 *   than no control, and a row that does not overflow is not a scroller.
 * - `always` — both, from the first paint, with the one that has nowhere to go
 *   `disabled` rather than gone. What a row whose content arrives later wants,
 *   since the buttons do not appear under the pointer half a second in.
 * - `none` — none at all. Dragging, the wheel and the arrow keys are still
 *   there; this is the strip that scrolls the way a phone scrolls.
 */
export type PlScrollZoneButtons = 'auto' | 'always' | 'none';

/**
 * What pressing a scroll button does.
 *
 * - `item` — moves to the next child along, `step` of them at a time. The
 *   default, and the only one that lands on something rather than between two
 *   things.
 * - `page` — moves by everything currently on screen, the way Page Down does.
 * - `hold` — scrolls for as long as the button is held, at `speed` pixels a
 *   second. A press too short to be a hold falls back to one `item`, so the
 *   button is never dead to a quick tap.
 */
export type PlScrollZoneMode = 'item' | 'page' | 'hold';

/**
 * Where the scroll buttons sit, which is also where the strip ends.
 *
 * - `overlay` — over the ends of the strip, which keeps every pixel of the box
 *   for content and lets an item pass under a button. The default, and what a
 *   shelf of pictures wants.
 * - `inline` — beside the strip, in the layout. The scroller stops where the
 *   button starts, so an item is *cut off* at the button's edge rather than
 *   sliding beneath it: nothing is ever half-hidden behind a control, and the
 *   button is legible over the page rather than over whatever it landed on.
 *
 * The lane an `inline` button sits in is kept even while that button has
 * nowhere to go, or the strip would resize under the pointer every time it
 * reached an end.
 */
export type PlScrollZoneButtonPlacement = 'overlay' | 'inline';

export interface PlScrollZoneProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Which way the children run, and therefore which way the zone scrolls.
   * @default 'horizontal'
   */
  orientation?: PlassOrientation;
  /**
   * How many rows a horizontal zone lays its children out in before it starts a
   * new column — and how many columns a vertical one uses. `2` is the shelf
   * that holds twice as much in the same width.
   * @default 1
   */
  lines?: number;
  /**
   * The gap between children, on Tailwind's spacing scale: `2` is `0.5rem`, the
   * same step `gap-2` is. The same ladder `PlGrid`'s own `spacing` is on.
   * @default 2
   */
  spacing?: number;
  /** When the scroll buttons are drawn. @default 'auto' */
  buttons?: PlScrollZoneButtons;
  /**
   * Whether the buttons sit over the strip or beside it. `inline` is what to
   * reach for when an item disappearing under a button reads as a bug rather
   * than as depth.
   * @default 'overlay'
   */
  buttonPlacement?: PlScrollZoneButtonPlacement;
  /** What pressing one does. @default 'item' */
  mode?: PlScrollZoneMode;
  /** How many children one press moves, in `item` mode. @default 1 */
  step?: number;
  /** How fast a held button scrolls, in pixels a second. @default 900 */
  speed?: number;
  /**
   * Snaps the nearest child to the leading edge when the scrolling stops —
   * dragging and the wheel included, not only the buttons.
   * @default false
   */
  snap?: boolean;
  /**
   * Lets a mouse or a pen drag the strip along, the way a finger already does.
   * Touch is left to the browser, whose own scrolling is better than anything a
   * handler can imitate: momentum, rubber-banding and the scrollbar all come
   * with it.
   * @default true
   */
  drag?: boolean;
  /**
   * Turns a vertical wheel over a horizontal strip into scrolling along it.
   *
   * A mouse has one wheel and it points the wrong way for a strip that runs
   * across the box. What a browser does with it there is its own business,
   * which is the problem: it makes the answer depend on which browser the
   * reader happens to be in. The pointer being on the strip is them saying
   * which of the two things under it they meant to move.
   *
   * Only the vertical half of a gesture, and only while the strip has somewhere
   * to go. A trackpad's two fingers, a tilt wheel and Shift held down already
   * scroll it sideways and are left alone; and the moment it reaches an end the
   * wheel goes back to the page, so a reader on their way down a long page is
   * held up by one shelf rather than caught in it.
   * @default true
   */
  wheel?: boolean;
  /** Shows the native scrollbar. @default false */
  scrollbar?: boolean;
  /** What the scrollable region is called — "Categories", "Recent files". */
  label?: string;
  /**
   * What the buttons are called. Never drawn — a disc with a chevron in it has
   * no accessible name of its own, which is the defect `PlIconButton`'s `label`
   * exists to make impossible.
   * @default 'Previous'
   */
  previousLabel?: string;
  /** @default 'Next' */
  nextLabel?: string;
  /** What is being laid out. Every top-level child is one item of the strip. */
  children?: React.ReactNode;
}

/**
 * How far the buttons sit in from the edge they are held against.
 *
 * Padding on the overlay rather than an inset on each button, so the two are
 * written once and a zone with only one of them drawn keeps the other's
 * position.
 */
const buttonInsetClasses: Record<PlassSize, string> = {
  xs: 'p-1',
  sm: 'p-1.5',
  md: 'p-2',
  lg: 'p-3',
  xl: 'p-4'
};

/** And the air between an inline button and the strip it flanks. */
const buttonGapClasses: Record<PlassSize, string> = {
  xs: 'gap-1',
  sm: 'gap-1.5',
  md: 'gap-2',
  lg: 'gap-3',
  xl: 'gap-4'
};

/** How far a press has to travel before it stops being a click. */
const DRAG_THRESHOLD = 4;

/** Under this, a press in `hold` mode was a tap and moves one item instead. */
const TAP_MS = 140;

/**
 * What one line is worth in pixels, for the browsers that report a wheel in
 * lines rather than in pixels.
 */
const WHEEL_LINE = 16;

/** A reader who has asked for less motion gets the cut rather than the travel. */
function scrollBehavior(): ScrollBehavior {
  return typeof window !== 'undefined' &&
    window.matchMedia?.('(prefers-reduced-motion: reduce)').matches
    ? 'auto'
    : 'smooth';
}

/**
 * A strip of anything, laid out in one direction and scrolled in it.
 *
 * The mechanism is an ordinary scroll container, and everything the component
 * offers is a way of driving one. Swiping on a phone, two-finger dragging on a
 * trackpad, the arrow keys and the scrollbar are the browser's own and are
 * never intercepted; what is added on top is a pair of buttons for the pointer
 * that has neither a wheel nor a finger, a mouse drag for the strip that reads
 * as something to pull rather than something to page, and the vertical wheel a
 * horizontal strip would otherwise have no use for.
 *
 * Nothing is transformed. A translated track would have to argue for an
 * exception to the house rule; a scroll offset does not, and it is also what
 * makes the strip run the other way under RTL without being told, keeps the
 * scrollbar honest, and lets the browser scroll a focused child into view.
 *
 * It draws no sheet of its own, and there is no `elevation` to give it one: a
 * shelf is a way of laying children out, and the children arrive with their own
 * surfaces. `variant`, `size`, `color` and `density` reach the two buttons,
 * which are real `PlIconButton`s.
 *
 * `lines` is what separates this from a `PlCarousel`: a carousel is one thing at
 * a time and knows which one, a scroll zone is a shelf that happens to be longer
 * than the room it is in.
 */
export const PlScrollZone = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlScrollZoneProps>(
  function PlScrollZone(
    {
      orientation = 'horizontal',
      lines = 1,
      spacing = 2,
      buttons = 'auto',
      buttonPlacement = 'overlay',
      mode = 'item',
      step = 1,
      speed = 900,
      snap = false,
      drag = true,
      wheel = true,
      scrollbar = false,
      variant = 'glass',
      size = 'md',
      color = 'primary',
      density = 'default',
      label,
      previousLabel = 'Previous',
      nextLabel = 'Next',
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const horizontal = orientation === 'horizontal';
    const rows = Math.max(1, Math.round(lines));
    const items = Math.max(1, Math.round(step));

    const scrollerRef = React.useRef<HTMLDivElement>(null);
    const trackRef = React.useRef<HTMLDivElement>(null);

    /**
     * Whether there is anything left in each direction, as one object so a
     * measurement that changed nothing costs no render.
     */
    const [reach, setReach] = React.useState({ back: false, forward: false });

    const measure = React.useCallback(() => {
      const element = scrollerRef.current;

      if (!element) {
        return;
      }

      const extent = horizontal ? element.clientWidth : element.clientHeight;
      const total = horizontal ? element.scrollWidth : element.scrollHeight;
      // `abs`, because a right-to-left container counts its scroll backwards
      // from zero. How far along we are is a distance either way.
      const along = Math.abs(horizontal ? element.scrollLeft : element.scrollTop);

      setReach((previous) => {
        const back = along > 1;
        const forward = total - extent - along > 1;

        return previous.back === back && previous.forward === forward
          ? previous
          : { back, forward };
      });
    }, [horizontal]);

    /*
     * Three things change what the buttons should say, and only one of them is
     * an event: the strip being scrolled, the zone being resized, and the
     * content inside it changing size. The observer covers the last two —
     * including the case that matters most, a zone that mounts inside a closed
     * `PlAccordion` or an unselected `PlTab` and is zero wide until it is
     * opened.
     */
    React.useEffect(() => {
      const element = scrollerRef.current;
      const track = trackRef.current;

      if (!element) {
        return;
      }

      measure();

      if (typeof ResizeObserver === 'undefined') {
        return;
      }

      const observer = new ResizeObserver(measure);

      observer.observe(element);

      if (track) {
        observer.observe(track);
      }

      return () => observer.disconnect();
    }, [measure]);

    /** Which way "forward" is on the physical axis: flipped under RTL. */
    const forwardSign = React.useCallback(() => {
      const element = scrollerRef.current;

      if (!element || !horizontal) {
        return 1;
      }

      return getComputedStyle(element).direction === 'rtl' ? -1 : 1;
    }, [horizontal]);

    const scrollByPixels = React.useCallback(
      (distance: number, smooth: boolean) => {
        const element = scrollerRef.current;

        if (!element) {
          return;
        }

        const behavior = smooth ? scrollBehavior() : 'auto';

        element.scrollBy(horizontal ? { left: distance, behavior } : { top: distance, behavior });
      },
      [horizontal]
    );

    /*
     * The wheel, and the one place the component takes an event off the
     * browser. What a vertical wheel does over a strip that runs across the box
     * is not the same in every browser, and leaving it alone buys a shelf that
     * answers the wheel on one machine and sits still on the next.
     *
     * A native listener rather than `onWheel`, because React attaches its own
     * wheel listener to the root passively, and `preventDefault` inside a
     * passive listener does nothing but log.
     */
    React.useEffect(() => {
      const element = scrollerRef.current;

      if (!element || !wheel || !horizontal) {
        return;
      }

      const onWheel = (event: WheelEvent) => {
        // A gesture that already has a horizontal half is one the browser
        // scrolls the strip with by itself: a trackpad, a tilt wheel, or Shift
        // held down.
        if (Math.abs(event.deltaY) <= Math.abs(event.deltaX)) {
          return;
        }

        const distance =
          event.deltaMode === event.DOM_DELTA_LINE
            ? event.deltaY * WHEEL_LINE
            : event.deltaMode === event.DOM_DELTA_PAGE
              ? event.deltaY * element.clientWidth
              : event.deltaY;

        // `abs`, for the reason `measure` gives: a right-to-left container
        // counts its scroll backwards from zero.
        const along = Math.abs(element.scrollLeft);
        const room =
          distance > 0 ? element.scrollWidth - element.clientWidth - along > 1 : along > 1;

        // Nothing left this way, so the page has it back. A shelf that swallowed
        // the wheel at both ends would be a hole a reader scrolls into.
        if (!room) {
          return;
        }

        event.preventDefault();
        scrollByPixels(distance * forwardSign(), false);
      };

      element.addEventListener('wheel', onWheel, { passive: false });

      return () => element.removeEventListener('wheel', onWheel);
    }, [forwardSign, horizontal, scrollByPixels, wheel]);

    /**
     * Where each child starts, measured from the leading edge of the viewport
     * and signed so that ahead is positive in both writing directions.
     *
     * Distinct offsets rather than one per child, which is what makes `lines`
     * work: four children stacked two by two are two columns, and pressing next
     * once should move one column rather than half of one.
     */
    const itemStarts = React.useCallback(() => {
      const element = scrollerRef.current;
      const track = trackRef.current;

      if (!element || !track) {
        return [];
      }

      const rtl = horizontal && getComputedStyle(element).direction === 'rtl';
      const edge = horizontal ? (rtl ? 'right' : 'left') : 'top';
      const sign = rtl ? -1 : 1;
      const origin = element.getBoundingClientRect()[edge];

      const starts: number[] = [];

      for (const child of Array.from(track.children) as HTMLElement[]) {
        const start = Math.round((child.getBoundingClientRect()[edge] - origin) * sign);

        if (!starts.includes(start)) {
          starts.push(start);
        }
      }

      return starts.sort((a, b) => a - b);
    }, [horizontal]);

    /** One press, in whichever unit `mode` is counted in. */
    const advance = React.useCallback(
      (forward: boolean, unit: PlScrollZoneMode = mode) => {
        const element = scrollerRef.current;

        if (!element) {
          return;
        }

        const sign = forwardSign();
        const extent = horizontal ? element.clientWidth : element.clientHeight;

        if (unit === 'page') {
          scrollByPixels(extent * (forward ? 1 : -1) * sign, true);

          return;
        }

        // An item, and it is measured rather than assumed: the children of a
        // scroll zone are whatever the caller put there, so no two of them are
        // necessarily the same width.
        const starts = itemStarts();
        const ahead = starts.filter((start) => start > 1);
        const behind = starts.filter((start) => start < -1);
        const target = forward ? ahead[items - 1] : behind[behind.length - items];

        if (target === undefined) {
          // Nothing that far along: go as far as there is. Without this, the
          // last half-item of a strip would be unreachable by button.
          scrollByPixels(extent * (forward ? 1 : -1) * sign, true);

          return;
        }

        scrollByPixels(target * sign, true);
      },
      [forwardSign, horizontal, itemStarts, items, mode, scrollByPixels]
    );

    /*
     * `hold` — a frame loop rather than an interval, so the strip moves at
     * `speed` pixels a second whatever the display is doing. The whole gesture
     * is torn down through one ref, because the `pointerup` that would normally
     * end it never arrives if the zone is unmounted mid-press.
     */
    const holdRef = React.useRef<(() => void) | null>(null);

    React.useEffect(() => () => holdRef.current?.(), []);

    const beginHold = React.useCallback(
      (forward: boolean, stop: 'pointerup' | 'keyup') => {
        if (holdRef.current) {
          return;
        }

        const sign = forwardSign();
        const started = performance.now();
        let previous = started;
        let frame = 0;

        const tick = (now: number) => {
          const elapsed = now - previous;

          previous = now;
          scrollByPixels(((speed * elapsed) / 1000) * (forward ? 1 : -1) * sign, false);
          frame = requestAnimationFrame(tick);
        };

        frame = requestAnimationFrame(tick);

        const release = () => {
          cancelAnimationFrame(frame);
          holdRef.current = null;
          window.removeEventListener(stop, release);
          window.removeEventListener('pointercancel', release);
          // A press released outside the browser window throws neither of the
          // two above, and a frame loop nobody can stop is the worst kind.
          window.removeEventListener('blur', release);

          // A press shorter than a hold was a click, and a click that scrolled
          // three pixels reads as a broken button.
          if (performance.now() - started < TAP_MS) {
            advance(forward, 'item');
          }
        };

        holdRef.current = release;
        window.addEventListener(stop, release);
        window.addEventListener('pointercancel', release);
        window.addEventListener('blur', release);
      },
      [advance, forwardSign, scrollByPixels, speed]
    );

    /*
     * Dragging. Mouse and pen only — a finger already scrolls, and the browser's
     * own scrolling has momentum, rubber-banding and a scrollbar that no handler
     * reproduces.
     */
    const dragRef = React.useRef<(() => void) | null>(null);

    React.useEffect(() => () => dragRef.current?.(), []);

    function beginDrag(event: React.PointerEvent<HTMLDivElement>) {
      if (!drag || event.pointerType === 'touch' || event.button !== 0) {
        return;
      }

      // A press released outside the page never reaches the listeners below, so
      // the drag before this one is torn down here rather than never.
      dragRef.current?.();

      const element = event.currentTarget;
      const fromX = event.clientX;
      const fromY = event.clientY;
      const fromLeft = element.scrollLeft;
      const fromTop = element.scrollTop;
      let dragging = false;

      // Taken off the document for the length of the drag rather than fixed
      // with `preventDefault`, which would also stop the browser focusing what
      // was pressed. Written prefixed and through `setProperty` because WebKit
      // implements only `-webkit-user-select`.
      const selection = document.body.style.getPropertyValue('-webkit-user-select');

      const move = (moveEvent: PointerEvent) => {
        const dx = moveEvent.clientX - fromX;
        const dy = moveEvent.clientY - fromY;

        if (!dragging) {
          if (Math.abs(horizontal ? dx : dy) < DRAG_THRESHOLD) {
            return;
          }

          dragging = true;
          element.setPointerCapture(moveEvent.pointerId);
          element.dataset.dragging = 'true';
          document.body.style.setProperty('-webkit-user-select', 'none');
        }

        if (horizontal) {
          element.scrollLeft = fromLeft - dx;
        } else {
          element.scrollTop = fromTop - dy;
        }
      };

      const release = () => {
        dragRef.current = null;
        element.removeEventListener('pointermove', move);
        element.removeEventListener('pointerup', end);
        element.removeEventListener('pointercancel', release);
        delete element.dataset.dragging;

        if (selection) {
          document.body.style.setProperty('-webkit-user-select', selection);
        } else {
          document.body.style.removeProperty('-webkit-user-select');
        }
      };

      const end = () => {
        const moved = dragging;

        release();

        if (!moved) {
          return;
        }

        // The `pointerup` that ends a drag is still followed by a click, and
        // that click lands on whatever card the strip happened to stop under.
        // It is swallowed on the way down, and the listener is dropped on the
        // next task in case no click was coming.
        const swallow = (clickEvent: MouseEvent) => {
          clickEvent.stopPropagation();
          clickEvent.preventDefault();
        };

        element.addEventListener('click', swallow, { capture: true, once: true });
        window.setTimeout(() => element.removeEventListener('click', swallow, true), 0);
      };

      dragRef.current = release;
      element.addEventListener('pointermove', move);
      element.addEventListener('pointerup', end);
      element.addEventListener('pointercancel', release);
    }

    function pressHandlers(forward: boolean) {
      if (mode !== 'hold') {
        return { onClick: () => advance(forward) };
      }

      return {
        onPointerDown: (event: React.PointerEvent<HTMLButtonElement>) => {
          if (event.button !== 0) {
            return;
          }

          beginHold(forward, 'pointerup');
        },
        // The keyboard's own half of a hold. Without it the button is a control
        // a pointer can use and a keyboard cannot, which is the one thing a
        // scroll affordance must never be.
        onKeyDown: (event: React.KeyboardEvent<HTMLButtonElement>) => {
          if (event.key !== 'Enter' && event.key !== ' ') {
            return;
          }

          event.preventDefault();
          beginHold(forward, 'keyup');
        }
      };
    }

    const drawn = buttons !== 'none' && (buttons === 'always' || reach.back || reach.forward);
    const inline = buttonPlacement === 'inline';

    function scrollButton(forward: boolean) {
      const available = forward ? reach.forward : reach.back;

      // An overlay button with nowhere to go is not drawn at all; an inline one
      // leaves its lane behind, because a lane that came and went would resize
      // the strip under the pointer that had just reached the end of it.
      // `inert` rather than `hidden`, so the space is kept and the button is out
      // of the tab order and out of the accessibility tree while it is
      // invisible.
      if (buttons === 'auto' && !available && !inline) {
        return <span />;
      }

      const turn = horizontal
        ? forward
          ? '-rotate-90 rtl:rotate-90'
          : 'rotate-90 rtl:-rotate-90'
        : forward
          ? ''
          : 'rotate-180';

      const spare = buttons === 'auto' && !available;

      const button = (
        <PlIconButton
          variant={variant}
          size={size}
          color={color}
          density={density}
          elevation={1}
          label={forward ? nextLabel : previousLabel}
          disabled={!available}
          className="pointer-events-auto"
          // Drawn pointing down and turned, which is the one allowance the
          // no-transform rule makes.
          icon={
            <span className={cx('flex items-center', turn)}>
              <ChevronIcon />
            </span>
          }
          {...pressHandlers(forward)}
        />
      );

      if (!inline) {
        return button;
      }

      return (
        <span
          className={cx('flex shrink-0 items-center justify-center', spare ? 'invisible' : '')}
          inert={spare}
        >
          {button}
        </span>
      );
    }

    return (
      <div
        ref={ref}
        // A flex column, so a zone that was given a height passes it to the
        // scroller: a vertical strip only scrolls if something bounds it, and
        // the thing a caller sizes is the component rather than the box inside
        // it.
        className={cx(
          'relative flex min-w-0',
          inline && horizontal ? 'flex-row items-stretch' : 'flex-col',
          inline ? buttonGapClasses[size] : '',
          className
        )}
        // One slot rather than the whole set: a scroll zone draws no sheet, so
        // the family only ever shows up in the focus ring the scroller takes.
        // The buttons are real `PlIconButton`s and carry their own.
        style={{ '--p-ring': `var(--plass-${color}-ring)`, ...style } as React.CSSProperties}
        {...props}
      >
        {drawn && inline ? scrollButton(false) : null}

        <div
          ref={scrollerRef}
          // Focusable, so the strip can be scrolled with the arrow keys by
          // whoever is not using a pointer. That is the browser's own key
          // handling on a scroll container, which means it is already right
          // under RTL — a handler of ours mapping ArrowRight to "forward" would
          // not have been.
          tabIndex={0}
          role={label ? 'group' : undefined}
          aria-label={label}
          className={cx(
            // `grow` with the basis left at `auto`, never `flex-1`: a zero basis
            // in a column whose own height is `auto` resolves to no height at
            // all, and a horizontal strip would come out flat.
            'min-h-0 min-w-0 grow',
            horizontal ? 'overflow-x-auto overflow-y-hidden' : 'overflow-y-auto overflow-x-hidden',
            snap ? (horizontal ? 'snap-x snap-mandatory' : 'snap-y snap-mandatory') : '',
            scrollbar ? '' : '[scrollbar-width:none] [&::-webkit-scrollbar]:hidden',
            drag && (reach.back || reach.forward)
              ? 'cursor-grab data-[dragging]:cursor-grabbing'
              : '',
            'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:[outline-offset:-2px]'
          )}
          onScroll={measure}
          onPointerDown={beginDrag}
        >
          <div
            ref={trackRef}
            className={cx(snap ? '[&>*]:snap-start' : '')}
            // The whole track is laid out inline rather than in utilities, for
            // the reason `internal/grid.ts` gives: `repeat(3, auto)` is a count
            // the caller picked and Tailwind only ever sees class names written
            // out literally. Half of the declaration in a class and half of it
            // here would be two places to read one layout.
            //
            // A grid rather than a flex row, because `lines` is exactly the
            // thing flex cannot state: a wrapping row wraps at the viewport, and
            // what is wanted here is a fixed number of rows and as many columns
            // as it takes.
            style={{
              display: 'grid',
              gap: spacingValue(spacing),
              gridAutoFlow: horizontal ? 'column' : 'row',
              ...(horizontal
                ? {
                    // `max-content`, or the track would be squeezed back to the
                    // width of the box it is supposed to be longer than.
                    width: 'max-content',
                    gridTemplateRows: `repeat(${rows}, auto)`,
                    gridAutoColumns: 'max-content'
                  }
                : {
                    gridTemplateColumns: `repeat(${rows}, minmax(0, 1fr))`,
                    gridAutoRows: 'max-content'
                  })
            }}
          >
            {children}
          </div>
        </div>

        {drawn && inline ? scrollButton(true) : null}

        {drawn && !inline ? (
          <div
            className={cx(
              'pointer-events-none absolute inset-0 flex justify-between',
              horizontal ? 'items-center' : 'flex-col items-center',
              buttonInsetClasses[size]
            )}
          >
            {scrollButton(false)}
            {scrollButton(true)}
          </div>
        ) : null}
      </div>
    );
  }
);
