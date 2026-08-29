'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  cx,
  hasContent,
  iconClasses,
  metaTextClasses,
  sheetBodyClasses,
  sheetTitleClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassDensity, PlassOrientation, PlassSize } from '../../types.js';

/**
 * How far along one item is.
 *
 * Three states rather than two, because "the one you are on" is not the same
 * claim as "done", and a sequence that cannot say which step is current is a
 * list. Each gets its own axis — a filled bullet, a filled bullet with a halo
 * around it, an empty one — rather than three shades of the same thing.
 */
export type PlTimelineStatus = 'complete' | 'current' | 'upcoming';

/** How the line between two items is drawn. `none` leaves the gap open. */
export type PlTimelineConnector = 'solid' | 'dashed' | 'dotted' | 'none';

interface TimelineContextValue {
  size: PlassSize;
  density: PlassDensity;
  orientation: PlassOrientation;
  color: PlassColor;
  active: number | null;
}

interface TimelineItemContextValue {
  index: number;
  last: boolean;
}

const TimelineContext = /* @__PURE__ */ React.createContext<TimelineContextValue | null>(null);
const TimelineItemContext = /* @__PURE__ */ React.createContext<TimelineItemContextValue>({
  index: 0,
  last: false
});

export interface PlTimelineProps extends Omit<React.ComponentPropsWithoutRef<'ol'>, 'color'> {
  /**
   * How far the sequence has got: the index of the item being worked on now.
   * Everything before it is complete, everything after it is still to come.
   *
   * An index rather than a value, because a timeline has no selection — nothing
   * here is chosen, and the only question is how far down the list reality has
   * reached. Omit it and every item is `upcoming` unless it says otherwise; pass
   * the item count to mark the whole sequence done.
   */
  active?: number;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** Spacing between items. Never the type scale, never the bullet. */
  density?: PlassDensity;
  /**
   * Which way the sequence runs. `vertical` is the default and the one that
   * takes an arbitrary number of steps with an arbitrary amount to say about
   * each; `horizontal` is the stepper across the top of a checkout, and it is
   * only honest while every label is short.
   * @default 'vertical'
   */
  orientation?: PlassOrientation;
  /** Renders something other than an `<ol>` — Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

export interface PlTimelineItemProps extends Omit<
  React.ComponentPropsWithoutRef<'li'>,
  'color' | 'title'
> {
  /** The heading of this step. */
  title?: React.ReactNode;
  /**
   * When it happened — a date, a duration, a name. Set beside the title on a
   * wide item and under it on a narrow one.
   */
  meta?: React.ReactNode;
  /**
   * What goes inside the bullet: a number, an icon, an avatar. Omit it and the
   * bullet is a plain disc, which is what a step with nothing to say about
   * itself should be.
   */
  bullet?: React.ReactNode;
  /**
   * Overrides what the timeline's `active` would have computed for this item — a
   * step that failed and stopped the sequence, a step that was skipped.
   */
  status?: PlTimelineStatus;
  /** Overrides the timeline's colour family for this item alone. */
  color?: PlassColor;
  /**
   * How the line to the next item is drawn.
   * @default 'solid'
   */
  connector?: PlTimelineConnector;
  /** The body of the step. */
  children?: React.ReactNode;
}

/* ---------------------------------------------------------------------------
 * Scales
 * ------------------------------------------------------------------------- */

/**
 * The bullet.
 *
 * Its own ladder rather than a step off `controlHeightClasses`, for the reason
 * `tickSizeClasses` has one: a bullet is not a control you can put a label
 * inside. It is a mark beside one, sized against the title next to it — which is
 * why the steps are close to the tick ladder and not to the control ladder.
 *
 * It is written as a custom property rather than as a class because the
 * connector has to know it: the line is centred on the bullet, and centring is
 * arithmetic on this number.
 */
const bulletSizeValues: Record<PlassSize, string> = {
  xs: '0.875rem',
  sm: '1rem',
  md: '1.25rem',
  lg: '1.5rem',
  xl: '1.875rem'
};

/** Between the bullet column and the content beside it. */
const bulletGapClasses: Record<PlassSize, string> = {
  xs: 'gap-2',
  sm: 'gap-2.5',
  md: 'gap-3',
  lg: 'gap-3.5',
  xl: 'gap-4'
};

/**
 * How far apart two items sit, and the one thing `density` is allowed to touch
 * here — a compact timeline is the same type at the same bullet size with less
 * air between the steps.
 *
 * The floor is set by the item with nothing in it. A step that is only a title
 * and a time is one line tall, so the gap is the *whole* of what separates it
 * from the next one — where a step with a paragraph under it has the paragraph's
 * own leading working for it as well. Tuned against that case, which is why even
 * `compact` keeps more air than a list of one-liners would otherwise suggest.
 */
const itemGapClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'pb-5', sm: 'pb-6', md: 'pb-7', lg: 'pb-8', xl: 'pb-10' },
  compact: { xs: 'pb-3', sm: 'pb-3.5', md: 'pb-4', lg: 'pb-5', xl: 'pb-6' }
};

/** The same ladder across, for the horizontal form. */
const itemGapXClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'pe-5', sm: 'pe-6', md: 'pe-7', lg: 'pe-8', xl: 'pe-10' },
  compact: { xs: 'pe-3', sm: 'pe-3.5', md: 'pe-4', lg: 'pe-5', xl: 'pe-6' }
};

const borderStyleClasses: Record<PlTimelineConnector, string> = {
  solid: 'border-solid',
  dashed: 'border-dashed',
  dotted: 'border-dotted',
  none: ''
};

/**
 * The bullet at each of the three states.
 *
 * Every one of them is a different axis, never a different opacity: `complete`
 * is the family's gradient, `current` is that gradient with a halo of the soft
 * tint around it, and `upcoming` is a hairline ring on the page's own surface. A
 * reader who cannot tell the colours apart still has a filled shape, a haloed
 * shape and an empty one.
 *
 * There is no gloss line on the two filled ones, for the reason a filled
 * `PlButton` has none — the gradient is the form. The `upcoming` ring is drawn
 * in the neutral hairline rather than the sheet's white one, the same call a
 * checkbox's edge makes: a bullet is small enough that its edge *is* the object,
 * and white light on a translucent pane disappears on a light card.
 */
const bulletStatusClasses: Record<PlTimelineStatus, string> = {
  complete: '[background-image:var(--p-fill)] text-(--p-on-solid)',
  current:
    '[background-image:var(--p-fill)] text-(--p-on-solid) [box-shadow:0_0_0_0.25rem_var(--p-soft)]',
  upcoming:
    'border-2 bg-(--plass-surface) text-(--plass-muted-fg) [border-color:var(--plass-border)]'
};

/**
 * The line *after* an item, which is what makes it the item's own property: a
 * connector is coloured by whether the step it leaves has been reached, not by
 * where it arrives.
 */
const connectorColorClasses: Record<PlTimelineStatus, string> = {
  complete: '[border-color:var(--p-line-hover)]',
  current: '[border-color:var(--plass-border)]',
  upcoming: '[border-color:var(--plass-border)]'
};

const titleStatusClasses: Record<PlTimelineStatus, string> = {
  complete: 'text-(--plass-fg)',
  current: 'text-(--p-accent)',
  upcoming: 'text-(--plass-muted-fg)'
};

/**
 * One step.
 *
 * Its index is not a prop and cannot be: an item that had to be told where it
 * was in the list would be an item every caller could put in the wrong place,
 * and `active={2}` would stop meaning anything. The `PlTimeline` numbers its
 * children as it walks them, and hands each one its index through a context.
 */
export const PlTimelineItem = /* @__PURE__ */ React.forwardRef<HTMLLIElement, PlTimelineItemProps>(
  function PlTimelineItem(
    { title, meta, bullet, status, color, connector = 'solid', className, children, ...props },
    ref
  ) {
    const timeline = React.useContext(TimelineContext);
    const { index, last } = React.useContext(TimelineItemContext);

    // A bare item outside a timeline still renders — it is just one step with
    // nothing before or after it. The defaults are the timeline's own.
    const size = timeline?.size ?? 'md';
    const density = timeline?.density ?? 'default';
    const orientation = timeline?.orientation ?? 'vertical';
    const family = color ?? timeline?.color ?? 'primary';
    const active = timeline?.active ?? null;

    const resolved: PlTimelineStatus =
      status ??
      (active === null
        ? 'upcoming'
        : index < active
          ? 'complete'
          : index === active
            ? 'current'
            : 'upcoming');

    const horizontal = orientation === 'horizontal';
    // The last item's line would run off the end of the sequence into nothing.
    const drawsConnector = connector !== 'none' && !last;

    const bulletBox = (
      <span
        aria-hidden="true"
        className={cx(
          'relative z-10 flex shrink-0 items-center justify-center rounded-full',
          // The label inside the bullet is sized off the bullet rather than off
          // the page's own text, so a number in an `xs` bullet is not the same
          // 8px it would be in an `xl` one.
          'size-(--p-bullet) text-[calc(var(--p-bullet)*0.5)] leading-none font-semibold tabular-nums',
          bulletStatusClasses[resolved],
          transitionClasses,
          iconClasses
        )}
      >
        {bullet}
      </span>
    );

    /*
     * The line, drawn as one border edge on an absolutely positioned box rather
     * than as a filled `<div>`, so `dashed` and `dotted` are the browser's own
     * dashes and land on the device pixel grid the way every other edge in the
     * library does.
     *
     * It starts at the far edge of the bullet and runs to the edge of the item,
     * which is where the next bullet begins — so the arithmetic is the bullet
     * size, and that is the whole reason it is a custom property.
     */
    const connectorLine = drawsConnector ? (
      <span
        aria-hidden="true"
        className={cx(
          'pointer-events-none absolute',
          // Half the bullet, less half the line, so the 2px rule is centred on
          // the bullet rather than starting at its centre.
          horizontal
            ? 'top-[calc(var(--p-bullet)/2_-_1px)] end-0 start-(--p-bullet) border-t-2'
            : 'top-(--p-bullet) bottom-0 start-[calc(var(--p-bullet)/2_-_1px)] border-s-2',
          borderStyleClasses[connector],
          connectorColorClasses[resolved],
          transitionClasses
        )}
      />
    ) : null;

    const body = (
      <div className={cx('flex min-w-0 flex-col gap-0.5', horizontal ? 'mt-2' : '')}>
        {hasContent(title) || hasContent(meta) ? (
          <div className="flex flex-wrap items-baseline gap-x-2">
            {hasContent(title) ? (
              <span
                className={cx(
                  'font-semibold',
                  sheetTitleClasses[size],
                  titleStatusClasses[resolved],
                  transitionClasses
                )}
              >
                {title}
              </span>
            ) : null}
            {hasContent(meta) ? (
              <span className={cx('text-(--plass-muted-fg)', metaTextClasses[size])}>{meta}</span>
            ) : null}
          </div>
        ) : null}

        {hasContent(children) ? (
          <div className={cx('text-(--plass-muted-fg)', sheetBodyClasses[size])}>{children}</div>
        ) : null}
      </div>
    );

    return (
      <li
        ref={ref}
        aria-current={resolved === 'current' ? 'step' : undefined}
        data-status={resolved}
        className={cx(
          'relative',
          horizontal
            ? cx('flex min-w-0 flex-1 flex-col', last ? '' : itemGapXClasses[density][size])
            : cx('flex', bulletGapClasses[size], last ? '' : itemGapClasses[density][size]),
          className
        )}
        style={
          {
            '--p-bullet': bulletSizeValues[size],
            ...surfaceSlots(family, 0),
            // A container's slots leave the sheet undyed, which is right for the
            // ground a bullet sits on — but a bullet *is* the thing being
            // coloured, so the two fills it needs are put back.
            '--p-fill': `var(--plass-${family}-fill)`,
            '--p-on-solid': `var(--plass-${family}-on-solid)`
          } as React.CSSProperties
        }
        {...props}
      >
        {connectorLine}
        {bulletBox}
        {body}
      </li>
    );
  }
);

/**
 * A sequence of steps, in the order they happen in.
 *
 * There is no Base UI primitive under this and there should not be: a timeline
 * has no selection, no roving focus and no keyboard contract — it is a list, and
 * reaching for a composite primitive to draw one would hand every consumer's
 * record of events the semantics of a widget.
 *
 * It is an `<ol>` for the reason it exists at all: the order *is* the content. A
 * screen reader announcing "list of 5 items" over an unordered list would be
 * describing something else.
 *
 * The children are numbered here rather than by a prop on each item, so `active`
 * has something to count against and inserting a step in the middle does not
 * mean renumbering the ones after it.
 */
export const PlTimeline = /* @__PURE__ */ React.forwardRef<HTMLOListElement, PlTimelineProps>(
  function PlTimeline(
    {
      active,
      size = 'md',
      color = 'primary',
      density = 'default',
      orientation = 'vertical',
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    // `toArray` is what drops the `null`s and `false`s a conditional step leaves
    // behind, so `active={2}` counts the steps that are actually on the page.
    const items = React.Children.toArray(children);
    const count = items.length;

    const context = React.useMemo<TimelineContextValue>(
      () => ({
        size,
        density,
        orientation,
        color,
        active: active ?? null
      }),
      [size, density, orientation, color, active]
    );

    const element = useRender({
      render: render ?? <ol />,
      ref,
      props: {
        // Tailwind's reset takes the markers off every `<ol>`, and Safari takes
        // the list semantics off with them. Saying `role="list"` out loud is the
        // one-line fix, and it costs nothing when the reset is not there.
        role: 'list',
        className: cx('flex', orientation === 'horizontal' ? 'flex-row' : 'flex-col', className),
        style: { ...surfaceSlots(color, 0), ...style },
        children: items.map((item, index) => (
          <TimelineItemContext.Provider key={index} value={{ index, last: index === count - 1 }}>
            {item}
          </TimelineItemContext.Provider>
        )),
        ...props
      }
    });

    return <TimelineContext.Provider value={context}>{element}</TimelineContext.Provider>;
  }
);
