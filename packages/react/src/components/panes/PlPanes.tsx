'use client';

import * as React from 'react';
import { cx, transitionClasses } from '../../internal/styles.js';
import type { PlassColor, PlassOrientation, PlassSize } from '../../types.js';

/**
 * A pane's share of the split, as a percentage of the container or as a CSS
 * length.
 *
 * A bare number is a percentage — that is what a split is usually described in,
 * and a percentage keeps its meaning when the window changes size. A string is
 * an absolute length (`'240px'`, `'15rem'`, `'20%'`), which is what a sidebar
 * with a minimum actually needs: "at least 200 pixels" does not survive being
 * written down as a percentage of a width nobody knows yet.
 */
export type PlPaneSize = number | string;

/** What a `PlPane` is told by the `PlPanes` around it. */
interface PlassPaneContextValue {
  /** The `flex-basis` this pane has been given, or `null` before measurement. */
  basis: string | null;
}

const PaneContext = /* @__PURE__ */ React.createContext<PlassPaneContextValue>({ basis: null });

export interface PlPanesProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Which way the panes run. `horizontal` puts them side by side with upright
   * handles between them; `vertical` stacks them.
   * @default 'horizontal'
   */
  orientation?: PlassOrientation;
  /**
   * Whether the handles between the panes can be dragged. Turn it off for a
   * split that is a layout rather than a control.
   * @default true
   */
  resizable?: boolean;
  /** The colour family the handles light up in. @default 'primary' */
  color?: PlassColor;
  /** How thick a handle is, and how far it reaches. @default 'md' */
  size?: PlassSize;
  /** Fires with every pane's share, in percent, while a handle is dragged. */
  onResize?: (sizes: number[]) => void;
  /** Fires once, with the same shape, when the handle is let go. */
  onResizeEnd?: (sizes: number[]) => void;
  /** The panes. Anything that is not a `PlPane` is still laid out, but has no size. */
  children?: React.ReactNode;
}

export interface PlPaneProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * The share this pane starts with. Panes with no `defaultSize` split whatever
   * is left over equally.
   */
  defaultSize?: PlPaneSize;
  /** How small it may be dragged. @default 0 */
  minSize?: PlPaneSize;
  /** How large it may be dragged. Unbounded when left out. */
  maxSize?: PlPaneSize;
  /** What is inside the pane. */
  children?: React.ReactNode;
}

/**
 * The width of a handle, and the width of the target the pointer has to hit.
 *
 * A visible line one pixel wide is a target one pixel wide, which is not a
 * target. So the handle is a track several pixels across with the hairline drawn
 * down the middle of it — the same split a scrollbar makes between what is drawn
 * and what can be grabbed.
 */
const handleTrackClasses: Record<PlassSize, string> = {
  xs: 'basis-1',
  sm: 'basis-1.5',
  md: 'basis-2',
  lg: 'basis-2.5',
  xl: 'basis-3'
};

/** The same numbers, as the total the panes have to give up to the handles. */
const handleTrackValues: Record<PlassSize, number> = {
  xs: 4,
  sm: 6,
  md: 8,
  lg: 10,
  xl: 12
};

/** How far one arrow key press moves a handle. */
const KEYBOARD_STEP = 16;

/**
 * A CSS length, in pixels.
 *
 * Only the four units a split is ever written in are accepted; anything else
 * resolves to `undefined`, which every caller here reads as "no constraint"
 * rather than as zero. A bad string should leave a pane unbounded, not pin it
 * shut.
 */
function toPixels(
  value: PlPaneSize | undefined,
  extent: number,
  root: Element | null
): number | undefined {
  if (value === undefined || value === null) return undefined;
  if (typeof value === 'number') return (extent * value) / 100;

  const match = /^\s*(-?[\d.]+)\s*(px|rem|em|%)\s*$/.exec(value);
  if (!match) return undefined;

  const amount = Number(match[1]);
  if (Number.isNaN(amount)) return undefined;

  switch (match[2]) {
    case 'px':
      return amount;
    case '%':
      return (extent * amount) / 100;
    case 'rem':
      return amount * parseFloat(getComputedStyle(document.documentElement).fontSize || '16');
    case 'em':
      return amount * parseFloat((root && getComputedStyle(root).fontSize) || '16');
    default:
      return undefined;
  }
}

/** Every pane's share of the space, summing to 1. */
function initialFractions(
  constraints: PlPaneProps[],
  extent: number,
  root: Element | null
): number[] {
  const sizes = constraints.map((pane) => toPixels(pane.defaultSize, extent, root));
  const named = sizes.reduce<number>((total, size) => total + (size ?? 0), 0);
  const unnamed = sizes.filter((size) => size === undefined).length;
  // Whatever is left after the named panes, split evenly. Negative when the
  // caller asked for more than there is, which the clamp below turns into zero.
  const share = unnamed > 0 ? Math.max(0, extent - named) / unnamed : 0;

  const resolved = sizes.map((size) => Math.max(0, size ?? share));
  const total = resolved.reduce((sum, size) => sum + size, 0);

  if (total <= 0) return resolved.map(() => 1 / Math.max(1, resolved.length));

  return resolved.map((size) => size / total);
}

/**
 * A set of panes with draggable handles between them.
 *
 * The panes are sized in **fractions**, written out as
 * `flex-basis: calc((100% - gutters) * fraction)`. That is the one decision the
 * rest of this file follows from: a split described in percentages survives the
 * window being resized without a single line of JavaScript running, so the
 * component measures itself only twice — once on mount, to turn a `'240px'`
 * default into a fraction, and once at the start of each drag, to know what a
 * pixel of pointer movement is worth.
 *
 * The handles are interleaved here rather than written by the caller, so the
 * children of a `PlPanes` are just panes. That does mean the direct children have
 * to *be* `PlPane`s: the constraints are read off their props, and a pane wrapped
 * in something else is a pane with no minimum.
 */
export const PlPanes = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlPanesProps>(
  function PlPanes(
    {
      orientation = 'horizontal',
      resizable = true,
      color = 'primary',
      size = 'md',
      onResize,
      onResizeEnd,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const items = React.Children.toArray(children).filter(
      React.isValidElement
    ) as React.ReactElement<PlPaneProps>[];
    const count = items.length;

    const rootRef = React.useRef<HTMLDivElement | null>(null);
    const setRootRef = React.useCallback(
      (node: HTMLDivElement | null) => {
        rootRef.current = node;
        if (typeof ref === 'function') ref(node);
        else if (ref) ref.current = node;
      },
      [ref]
    );

    // The constraints are read during render and used inside pointer handlers that
    // outlive it, so they go through a ref rather than through the closure.
    const constraintsRef = React.useRef<PlPaneProps[]>([]);
    constraintsRef.current = items.map((item) => item.props);

    const [stored, setFractions] = React.useState<number[] | null>(null);
    // A pane added or removed leaves the stored split a render behind the children
    // — the effect below re-splits, but the render in between would be reading a
    // share off the end of the list. Until the two agree, nobody has a size and
    // every pane falls back to an even share.
    const fractions = stored && stored.length === count ? stored : null;
    const fractionsRef = React.useRef<number[] | null>(null);
    fractionsRef.current = fractions;

    const horizontal = orientation === 'horizontal';
    const gutter = handleTrackValues[size] * Math.max(0, count - 1);

    /*
     * One measurement, for one purpose: turning a `defaultSize` written as a
     * length into a fraction. It is an observer rather than a single read because
     * a split inside a closed `PlAccordion` or an unselected `PlTab` is zero wide when
     * it mounts, and dividing by that would put every pane at nothing.
     */
    React.useEffect(() => {
      const root = rootRef.current;
      if (!root) return;

      const measure = () => {
        const rect = root.getBoundingClientRect();
        const extent = (horizontal ? rect.width : rect.height) - gutter;
        if (extent <= 0) return;

        setFractions((previous) =>
          previous && previous.length === count
            ? previous
            : initialFractions(constraintsRef.current, extent, root)
        );
      };

      measure();

      const observer = new ResizeObserver(measure);
      observer.observe(root);

      return () => observer.disconnect();
    }, [count, horizontal, gutter]);

    /**
     * Everything a drag needs to know, measured at the moment it starts.
     *
     * A drag only ever moves the boundary between two panes, so their total is
     * fixed and one pane's floor is the other's ceiling. Folding all four bounds
     * into a single range on the first of the pair is what keeps every move to one
     * clamp and one division.
     */
    function grip(index: number) {
      const root = rootRef.current;
      const current = fractionsRef.current;
      if (!resizable || !root || !current || current[index + 1] === undefined) return null;

      const rect = root.getBoundingClientRect();
      const extent = (horizontal ? rect.width : rect.height) - gutter;
      if (extent <= 0) return null;

      const before = constraintsRef.current[index];
      const after = constraintsRef.current[index + 1];
      const start = current[index] * extent;
      const pair = start + current[index + 1] * extent;

      const lower = Math.max(
        toPixels(before?.minSize, extent, root) ?? 0,
        pair - (toPixels(after?.maxSize, extent, root) ?? pair)
      );
      const upper = Math.min(
        toPixels(before?.maxSize, extent, root) ?? pair,
        pair - (toPixels(after?.minSize, extent, root) ?? 0)
      );

      if (upper < lower) return null;

      return {
        root,
        current,
        extent,
        start,
        pair,
        resize(delta: number) {
          const sized = Math.min(upper, Math.max(lower, start + delta));
          const next = [...current];
          next[index] = sized / extent;
          next[index + 1] = (pair - sized) / extent;

          setFractions(next);
          onResize?.(next.map((fraction) => fraction * 100));

          return next;
        }
      };
    }

    /**
     * How to take a drag in flight apart, held for as long as one is running.
     *
     * A drag is torn down by the `pointerup` that ends it, and that event never
     * arrives if the split goes away first — a route change, a closed accordion, a
     * pane list that shrank. What is left behind is not only two listeners on a
     * detached node: the drag takes the whole document's text selection away while
     * it runs, and nothing else ever puts it back.
     */
    const teardownRef = React.useRef<(() => void) | null>(null);

    React.useEffect(() => () => teardownRef.current?.(), []);

    function beginDrag(index: number, event: React.PointerEvent<HTMLDivElement>) {
      const held = grip(index);
      if (!held) return;

      const handle = event.currentTarget;
      handle.setPointerCapture(event.pointerId);
      handle.dataset.dragging = 'true';

      /*
       * A drag across a page selects the text it passes over, and the obvious cure
       * — `preventDefault` on the press — also stops the browser focusing the
       * handle, which leaves the component focusing it by hand and every mouse
       * press wearing a keyboard focus ring. Taking the selection off the document
       * for the length of the drag fixes the selection without touching the focus.
       *
       * The property is written prefixed and through `setProperty`, because WebKit
       * implements only `-webkit-user-select`: it has no `userSelect` on a style
       * declaration, so `style.userSelect = 'none'` hangs a plain JS property off
       * the object, changes nothing, and Safari selects text through the whole
       * drag. Chromium and Firefox both read the prefixed name as the standard
       * one. This is what Tailwind's own `select-none` emits, for the same reason.
       */
      const selection = document.body.style.getPropertyValue('-webkit-user-select');
      document.body.style.setProperty('-webkit-user-select', 'none');

      const origin = horizontal ? event.clientX : event.clientY;
      // Positive is always "toward the end", so a drag under RTL moves the
      // boundary the way the pointer went rather than the way the axis is numbered.
      const towardsEnd = horizontal && getComputedStyle(held.root).direction === 'rtl' ? -1 : 1;

      let latest = held.current;

      const move = (moveEvent: PointerEvent) => {
        const position = horizontal ? moveEvent.clientX : moveEvent.clientY;
        latest = held.resize((position - origin) * towardsEnd);
      };

      // Everything the drag took from outside itself, given back. Split from `end`
      // because unmounting has to run this half and must not run the other: a
      // component that disappeared did not finish resizing, and telling a caller it
      // did would set state on the way out of the tree.
      const release = () => {
        teardownRef.current = null;
        handle.removeEventListener('pointermove', move);
        handle.removeEventListener('pointerup', end);
        handle.removeEventListener('pointercancel', end);
        delete handle.dataset.dragging;

        // Removed rather than set back to '', so a page that never wrote the
        // property inline is left with the declaration it actually had.
        if (selection) document.body.style.setProperty('-webkit-user-select', selection);
        else document.body.style.removeProperty('-webkit-user-select');
      };

      const end = () => {
        release();
        onResizeEnd?.(latest.map((fraction) => fraction * 100));
      };

      teardownRef.current = release;
      handle.addEventListener('pointermove', move);
      handle.addEventListener('pointerup', end);
      handle.addEventListener('pointercancel', end);
    }

    function nudge(index: number, pixels: number) {
      const held = grip(index);
      if (!held) return;

      const next = held.resize(pixels);
      // A key press is a whole gesture on its own — there is no "let go" to wait
      // for, so the settled callback fires with it.
      onResizeEnd?.(next.map((fraction) => fraction * 100));
    }

    const handleClassNames = cx(
      'group/handle relative z-1 flex shrink-0 grow-0 items-center justify-center',
      handleTrackClasses[size],
      transitionClasses,
      '[outline:none] focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:outline-offset-0',
      resizable
        ? cx(
            horizontal ? 'cursor-col-resize' : 'cursor-row-resize',
            'hover:bg-(--p-soft) data-[dragging]:bg-(--p-soft)'
          )
        : ''
    );

    return (
      <div
        ref={setRootRef}
        className={cx(
          'flex h-full w-full',
          horizontal ? 'flex-row' : 'flex-col',
          // A flex item refuses to go below its content's intrinsic size unless it
          // is told to, which is what turns a pane holding a long line into a pane
          // that cannot be dragged narrower.
          'min-h-0 min-w-0',
          className
        )}
        // Three slots rather than the whole `surfaceSlots` set: a split draws no
        // sheet, so the family only ever shows up in the handle's hairline, the
        // tint under a hovered handle and the focus ring.
        style={
          {
            '--p-accent': `var(--plass-${color}-accent)`,
            '--p-soft': `var(--plass-${color}-soft)`,
            '--p-ring': `var(--plass-${color}-ring)`,
            ...style
          } as React.CSSProperties
        }
        {...props}
      >
        {items.map((item, index) => (
          <React.Fragment key={item.key ?? index}>
            {index > 0 ? (
              <div
                role="separator"
                aria-orientation={horizontal ? 'vertical' : 'horizontal'}
                aria-valuenow={fractions ? Math.round(fractions[index - 1] * 100) : undefined}
                aria-valuemin={0}
                aria-valuemax={100}
                aria-disabled={!resizable || undefined}
                tabIndex={resizable ? 0 : -1}
                className={handleClassNames}
                // No `preventDefault` and no explicit focus: the browser focuses
                // the handle on a press by itself, and it knows that a press is
                // not a keystroke — which is what keeps the focus ring off a
                // handle somebody merely dragged. `beginDrag` takes the page's
                // text selection away for the length of the drag instead.
                onPointerDown={(event) => {
                  if (event.button !== 0) return;
                  beginDrag(index - 1, event);
                }}
                onKeyDown={(event) => {
                  const back = horizontal ? 'ArrowLeft' : 'ArrowUp';
                  const forward = horizontal ? 'ArrowRight' : 'ArrowDown';
                  if (event.key !== back && event.key !== forward) return;
                  event.preventDefault();
                  nudge(index - 1, event.key === forward ? KEYBOARD_STEP : -KEYBOARD_STEP);
                }}
              >
                {/*
                The hairline, drawn down the middle of the track. It changes
                colour and nothing else — the track it sits in has a fixed width,
                so nothing either side of it moves when the pointer arrives.
              */}
                <span
                  aria-hidden="true"
                  className={cx(
                    'pointer-events-none bg-(--plass-border)',
                    transitionClasses,
                    horizontal ? 'h-full w-px' : 'h-px w-full',
                    resizable
                      ? 'group-hover/handle:bg-(--p-accent) group-focus-visible/handle:bg-(--p-accent) group-data-[dragging]/handle:bg-(--p-accent)'
                      : ''
                  )}
                />
              </div>
            ) : null}

            <PaneContext.Provider
              value={{
                basis: fractions
                  ? `calc((100% - ${gutter}px) * ${fractions[index].toFixed(6)})`
                  : null
              }}
            >
              {item}
            </PaneContext.Provider>
          </React.Fragment>
        ))}
      </div>
    );
  }
);

/**
 * One region of a split.
 *
 * It carries no surface of its own on purpose: a split is layout, and the moment
 * a pane drew a sheet it would stop being usable as the thing a `PlCard`, a
 * `PlTable` or an editor is put inside. Put a `PlCard` in it when a surface is
 * wanted.
 *
 * `defaultSize`, `minSize` and `maxSize` are read by the `PlPanes` around it
 * rather than used here — a pane cannot know what "half" is, only the split can.
 */
export const PlPane = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlPaneProps>(function PlPane(
  // The three sizing props are named here only so they are taken out of the
  // rest, which is spread onto a `<div>` — `defaultSize` on a div is an
  // attribute React does not know and would hand straight to the DOM.
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  { defaultSize, minSize, maxSize, className, style, children, ...props },
  ref
) {
  const { basis } = React.useContext(PaneContext);

  return (
    <div
      ref={ref}
      className={cx('relative min-h-0 min-w-0 overflow-auto', className)}
      // `1 1 0%` before the split has measured itself, so a pane renders at an
      // even share on the first paint instead of at nothing and then jumping.
      style={{ flex: basis ? `0 0 ${basis}` : '1 1 0%', ...style }}
      {...props}
    >
      {children}
    </div>
  );
});
