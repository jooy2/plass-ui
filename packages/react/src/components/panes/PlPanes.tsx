'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { beginPointerDrag } from '../../internal/drag.js';
import { layoutBox } from '../../internal/layout-box.js';
import { cx, transitionClasses } from '../../internal/styles.js';
import { useResponsiveValue } from '../../internal/responsive.js';
import type { PlassColor, PlassOrientation, PlassResponsive, PlassSize } from '../../types.js';

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
  /** The `flex` this pane has been given. */
  flex: string;
  /** The `id` the handle before it points at with `aria-controls`. */
  id: string | undefined;
}

/**
 * The `flex` of a pane nothing has sized: an even share of what is left. It is
 * what a pane outside a split gets, and one inside a split whose sizes only a
 * measurement can work out, until it has been measured.
 */
const EVEN_SHARE = '1 1 0%';

const PaneContext = /* @__PURE__ */ React.createContext<PlassPaneContextValue>({
  flex: EVEN_SHARE,
  id: undefined
});

export interface PlPanesProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Which way the panes run. `horizontal` puts them side by side with upright
   * handles between them; `vertical` stacks them.
   * @default 'horizontal'
   */
  orientation?: PlassResponsive<PlassOrientation>;
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
  /**
   * What a screen reader calls a handle, before the share it is at. Without one,
   * every handle of a split is read only as "separator" and a number.
   */
  label?: string;
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

/** A pane size taken apart: a bare number is a percentage. */
interface PaneLength {
  amount: number;
  unit: 'px' | 'rem' | 'em' | '%';
}

/**
 * A pane size as an amount and a unit.
 *
 * Only the four units a split is ever written in are accepted; anything else
 * resolves to `undefined`, which every caller here reads as "no constraint"
 * rather than as zero. A bad string should leave a pane unbounded, not pin it
 * shut.
 */
function parseLength(value: PlPaneSize | undefined): PaneLength | undefined {
  if (value === undefined || value === null) return undefined;
  if (typeof value === 'number') return { amount: value, unit: '%' };

  const match = /^\s*(-?[\d.]+)\s*(px|rem|em|%)\s*$/.exec(value);
  if (!match) return undefined;

  const amount = Number(match[1]);
  if (Number.isNaN(amount)) return undefined;

  return { amount, unit: match[2] as PaneLength['unit'] };
}

/** A CSS length, in pixels. `undefined` for anything `parseLength` refuses. */
function toPixels(
  value: PlPaneSize | undefined,
  extent: number,
  root: Element | null
): number | undefined {
  const length = parseLength(value);
  if (!length) return undefined;

  switch (length.unit) {
    case 'px':
      return length.amount;
    case '%':
      return (extent * length.amount) / 100;
    case 'rem':
      return (
        length.amount * parseFloat(getComputedStyle(document.documentElement).fontSize || '16')
      );
    case 'em':
      return length.amount * parseFloat((root && getComputedStyle(root).fontSize) || '16');
  }
}

/** The `flex-basis` of a pane given `fraction` of what the handles leave. */
function basisOf(fraction: number, gutter: number): string {
  return `calc((100% - ${gutter}px) * ${fraction.toFixed(6)})`;
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
 * Every pane's `flex` before the split has measured itself, worked out from the
 * `defaultSize`s alone, so the server's HTML and the first paint already have
 * the split the measurement then arrives at. `null` when only the container's
 * size can say it.
 *
 * - **No pane is a pixel length**, or **every pane is one**: the shares come out
 *   the same whatever size the container is, so they are worked out at any
 *   size and written as the measurement writes them.
 * - **A pixel length beside a pane that takes what is left**: the length is
 *   written as it is and the panes with no size share the rest, which is what
 *   the measurement turns into fractions, as long as the lengths fit.
 * - Anything else, a `rem` or an `em`, or pixel lengths beside percentages with
 *   no pane to take up the difference, is left to the measurement, and every
 *   pane takes an even share until it has run.
 */
function presplit(constraints: PlPaneProps[], gutter: number): string[] | null {
  const lengths = constraints.map((pane) => parseLength(pane.defaultSize));
  const units = new Set(lengths.map((length) => length?.unit));

  if (units.has('rem') || units.has('em')) return null;

  if (!units.has('px') || (!units.has('%') && !units.has(undefined))) {
    return initialFractions(constraints, 100, null).map(
      (fraction) => `0 0 ${basisOf(fraction, gutter)}`
    );
  }

  if (!units.has(undefined)) return null;

  return lengths.map((length) => {
    if (!length) return EVEN_SHARE;

    const amount = Math.max(0, length.amount);

    return length.unit === 'px' ? `0 0 ${amount}px` : `0 0 ${basisOf(amount / 100, gutter)}`;
  });
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
 * pixel of pointer movement is worth. Until the first measurement the panes are
 * drawn from their `defaultSize`s alone wherever those settle the split on
 * their own (see `presplit`), so a split rendered on the server does not move
 * as it hydrates.
 *
 * The handles are interleaved here rather than written by the caller, so the
 * children of a `PlPanes` are just panes. That does mean the direct children have
 * to *be* `PlPane`s: the constraints are read off their props, and a pane wrapped
 * in something else is a pane with no minimum.
 */
export const PlPanes = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlPanesProps>(
  function PlPanes(
    {
      orientation: orientationProp,
      resizable = true,
      color: colorProp,
      size: sizeProp,
      onResize,
      onResizeEnd,
      label,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    // Resolved here rather than in CSS, and it has to be: an orientation
    // changes which DOM this builds, which ARIA it claims and which way its
    // arrow keys go. The cost is the one every JavaScript answer about width
    // pays — a server renders the `xs` entry — and a bare value subscribes to
    // nothing at all.
    const orientation = useResponsiveValue(orientationProp, 'horizontal');

    const defaults = useDefaults();
    const color = colorProp ?? defaults.color ?? 'primary';
    const size = sizeProp ?? defaults.size ?? 'md';

    const items = React.Children.toArray(children).filter(
      React.isValidElement
    ) as React.ReactElement<PlPaneProps>[];
    const count = items.length;

    // Each pane's `id`, its own when it has one, so a handle can say which pane
    // it resizes: the one before it.
    const baseId = React.useId();
    const paneId = (index: number) => items[index]?.props.id ?? `${baseId}-pane-${index}`;

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
    const constraints = items.map((item) => item.props);
    const constraintsRef = React.useRef<PlPaneProps[]>([]);
    constraintsRef.current = constraints;

    const [stored, setFractions] = React.useState<number[] | null>(null);
    // A pane added or removed leaves the stored split a render behind the children
    // — the effect below re-splits, but the render in between would be reading a
    // share off the end of the list. Until the two agree, nobody has a measured
    // size, and every pane takes what the `defaultSize`s say on their own.
    const fractions = stored && stored.length === count ? stored : null;
    const fractionsRef = React.useRef<number[] | null>(null);
    fractionsRef.current = fractions;

    const horizontal = orientation === 'horizontal';
    const gutter = handleTrackValues[size] * Math.max(0, count - 1);

    // What a pane is drawn at before the split has been measured: on the
    // server, on the first paint, and while a pane added or removed waits for
    // the effect below.
    const early = fractions ? null : presplit(constraints, gutter);

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
        // The content box rather than the border box, which is the same number
        // only while the split has no padding and no border: a padded split
        // measured by its border box gave every fraction more room than the
        // panes have, so a length moved as the split measured itself and a
        // handle fell behind the pointer dragging it.
        const extent = layoutBox(root, horizontal).content - gutter;
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

      const { content, perPixel } = layoutBox(root, horizontal);
      const extent = content - gutter;
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
        perPixel,
        /** Moves the boundary `delta` of the split's own pixels from where it started. */
        resize(delta: number) {
          const sized = Math.min(upper, Math.max(lower, start + delta));

          // A move that leaves the line where it was, a pane held at its limit,
          // reports nothing.
          if (sized === start) return current;

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
     * The drag in flight, held so that an unmount can take it apart.
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

      const origin = horizontal ? event.clientX : event.clientY;
      // Positive is always "toward the end", so a drag under RTL moves the
      // boundary the way the pointer went rather than the way the axis is numbered.
      const towardsEnd = horizontal && getComputedStyle(held.root).direction === 'rtl' ? -1 : 1;

      let latest = held.current;

      const stop = beginPointerDrag({
        target: event.currentTarget,
        pointerId: event.pointerId,
        onMove: (moveEvent) => {
          const position = horizontal ? moveEvent.clientX : moveEvent.clientY;
          // The pointer moves in the screen's pixels and the panes are laid out
          // in the split's own, which differ inside a scaled ancestor.
          latest = held.resize((position - origin) * towardsEnd * held.perPixel);
        },
        // Only the pointer being released settles the split. An unmount runs the
        // teardown below instead, which gives back the listeners and the selection
        // and says nothing: a component that disappeared did not finish resizing,
        // and telling a caller it did would set state on the way out of the tree.
        onEnd: () => {
          teardownRef.current = null;
          onResizeEnd?.(latest.map((fraction) => fraction * 100));
        }
      });

      teardownRef.current = stop;
    }

    function nudge(index: number, pixels: number) {
      const held = grip(index);
      if (!held) return;

      const next = held.resize(pixels);
      // A key press is a whole gesture on its own — there is no "let go" to wait
      // for, so the settled callback fires with it, when it moved the line.
      if (next !== held.current) {
        onResizeEnd?.(next.map((fraction) => fraction * 100));
      }
    }

    const handleClassNames = cx(
      'group/handle relative z-1 flex shrink-0 grow-0 items-center justify-center',
      handleTrackClasses[size],
      transitionClasses,
      '[outline:none] focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:outline-offset-0',
      resizable
        ? cx(
            horizontal ? 'cursor-col-resize' : 'cursor-row-resize',
            // A finger's drag is the handle's, not a pan the browser takes
            // after a few pixels and ends with `pointercancel`.
            'touch-none',
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
              // eslint-disable-next-line jsx-a11y/no-noninteractive-element-interactions -- a separator that takes the focus is a window splitter, which ARIA counts as a widget
              <div
                role="separator"
                aria-label={label}
                aria-controls={paneId(index - 1)}
                aria-orientation={horizontal ? 'vertical' : 'horizontal'}
                aria-valuenow={fractions ? Math.round(fractions[index - 1] * 100) : undefined}
                aria-valuemin={0}
                aria-valuemax={100}
                aria-disabled={!resizable || undefined}
                // eslint-disable-next-line jsx-a11y/no-noninteractive-tabindex -- a separator that takes the focus is a window splitter, which ARIA counts as a widget
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
                  // The same flip a drag makes, and for the same reason: the
                  // arrow keys are physical, the split is not, and a boundary
                  // that moved left when ArrowRight was pressed would be moving
                  // away from the key under RTL.
                  const towardsEnd =
                    horizontal && getComputedStyle(event.currentTarget).direction === 'rtl'
                      ? -1
                      : 1;
                  const step = event.key === forward ? KEYBOARD_STEP : -KEYBOARD_STEP;
                  nudge(index - 1, step * towardsEnd);
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
                flex: fractions
                  ? `0 0 ${basisOf(fractions[index], gutter)}`
                  : (early?.[index] ?? EVEN_SHARE),
                id: paneId(index)
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
  const { flex, id } = React.useContext(PaneContext);

  return (
    <div
      ref={ref}
      id={id}
      className={cx('relative min-h-0 min-w-0 overflow-auto', className)}
      style={{ flex, ...style }}
      {...props}
    >
      {children}
    </div>
  );
});
