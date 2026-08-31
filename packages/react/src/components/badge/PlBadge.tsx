'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import {
  controlSlots,
  glassClasses,
  hasContent,
  srOnlyClasses,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassCorner,
  PlassDensity,
  PlassElevation,
  PlassSize,
  PlassStyleProps,
  PlassVariant
} from '../../types.js';

/**
 * The shape of the thing underneath, which is what decides how far the marker
 * tucks in.
 */
export type PlBadgeOverlap = 'square' | 'circle';

export interface PlBadgeProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'span'>, 'color' | 'content'> {
  /**
   * What the badge says — usually a count, sometimes a word.
   *
   * Omit it and the badge draws a dot instead, which is the honest thing when
   * there is something to report but nothing to count.
   */
  content?: React.ReactNode;
  /**
   * Caps a numeric `content` and adds a `+`. Only applies when the content is
   * actually a number: a badge cannot know how to truncate a word.
   * @default 99
   */
  max?: number;
  /**
   * Draws the marker as a dot even when there is content, keeping the content
   * for screen readers only. For the corner that has to stay quiet.
   * @default false
   */
  dot?: boolean;
  /**
   * Whether a `content` of `0` is shown. Off by default — zero unread messages
   * is not news, and a badge that never goes away stops meaning anything.
   * @default false
   */
  showZero?: boolean;
  /**
   * Hides the marker without unmounting the anchor. The badge keeps its place in
   * the DOM, so showing it again does not relayout what it sits on.
   * @default false
   */
  invisible?: boolean;
  /**
   * Which corner of the anchor it sits on.
   * @default 'top-end'
   */
  placement?: PlassCorner;
  /**
   * The shape of the thing underneath, which is what decides how far the marker
   * tucks in: a circle's corner is further from its centre than a square's, so a
   * badge that looks right on an avatar hangs off an icon button.
   * @default 'square'
   */
  overlap?: PlBadgeOverlap;
  /**
   * Drop shadow depth. `0` is the default — a marker lies on the thing it is
   * marking rather than floating above it.
   * @default 0
   */
  elevation?: PlassElevation;
  /**
   * What a screen reader hears instead of the raw content. `content={3}` on a
   * bell is "3" to a reader and means nothing; `label="3 unread notifications"`
   * is the sentence.
   */
  label?: string;
  /**
   * What the badge is pinned to. Without it the badge is a standalone marker
   * that lays out inline, which is what a status pill in a table cell is.
   */
  children?: React.ReactNode;
}

/**
 * A badge is smaller than anything else in the library, so it has a ladder of
 * its own rather than a step off `controlHeightClasses`.
 *
 * A control's height is the number a *row* lines up on; a badge lines up on
 * nothing — it hangs off the corner of something else. `md` is 18px, which is
 * the smallest a two-digit number stays legible at.
 */
const badgeHeightClasses: Record<PlassSize, string> = {
  xs: 'h-3.5 min-w-3.5',
  sm: 'h-4 min-w-4',
  md: 'h-4.5 min-w-4.5',
  lg: 'h-5 min-w-5',
  xl: 'h-6 min-w-6'
};

/** The dot: the same ladder with the digits taken out, so it goes square. */
const dotSizeClasses: Record<PlassSize, string> = {
  xs: 'size-1.5',
  sm: 'size-2',
  md: 'size-2.5',
  lg: 'size-2.5',
  xl: 'size-3'
};

const badgeTextClasses: Record<PlassSize, string> = {
  xs: 'text-[0.5625rem]',
  sm: 'text-[0.625rem]',
  md: 'text-[0.6875rem]',
  lg: 'text-[0.75rem]',
  xl: 'text-[0.8125rem]'
};

/** Horizontal breathing room around the digits. `density` is what halves it. */
const badgePaddingClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'px-1', sm: 'px-1', md: 'px-1.5', lg: 'px-1.5', xl: 'px-2' },
  compact: { xs: 'px-0.5', sm: 'px-0.5', md: 'px-1', lg: 'px-1', xl: 'px-1.5' }
};

/**
 * A badge sits well below the radius ladder — at 18px tall, `--plass-radius-xs`
 * (8px) is already most of the way to a pill, and a badge *is* the one thing in
 * the library allowed to be one.
 *
 * That is not a hole in the design language, it is the exception the language
 * names. A Plass corner is a moulded fillet on a *surface*, and a badge is not a
 * surface: it is a mark laid on one — which is also why it is the only component
 * that overlaps its neighbour.
 */
const badgeRadiusClasses = 'rounded-full';

/**
 * How far the marker is pulled out of the corner, per size.
 *
 * A negative margin rather than the `translate(50%,-50%)` every other library
 * reaches for, because the house rule against `transform` is absolute and worth
 * more than the two lines it costs here. The offsets are half the marker's own
 * height, so the vertical overhang is exactly half — and horizontally a wide
 * `99+` tucks in a little further than half, which is what you want anyway.
 */
const cornerOffsets: Record<PlassSize, { badge: string; dot: string }> = {
  xs: { badge: '-mt-1.5 -mb-1.5 -ms-1.5 -me-1.5', dot: '-mt-0.5 -mb-0.5 -ms-0.5 -me-0.5' },
  sm: { badge: '-mt-2 -mb-2 -ms-2 -me-2', dot: '-mt-1 -mb-1 -ms-1 -me-1' },
  md: { badge: '-mt-2 -mb-2 -ms-2 -me-2', dot: '-mt-1 -mb-1 -ms-1 -me-1' },
  lg: { badge: '-mt-2.5 -mb-2.5 -ms-2.5 -me-2.5', dot: '-mt-1 -mb-1 -ms-1 -me-1' },
  xl: { badge: '-mt-3 -mb-3 -ms-3 -me-3', dot: '-mt-1.5 -mb-1.5 -ms-1.5 -me-1.5' }
};

/**
 * Which two edges the marker is pinned to. Logical properties throughout, so the
 * corner flips with the writing direction rather than staying stuck on the right.
 */
const placementClasses: Record<PlassCorner, string> = {
  'top-start': 'top-0 start-0',
  'top-end': 'top-0 end-0',
  'bottom-start': 'bottom-0 start-0',
  'bottom-end': 'bottom-0 end-0'
};

/**
 * The extra inset a round anchor needs. A circle's corner is `r·(1 − 1/√2)` —
 * about 15% of its diameter — inside the bounding box the badge is positioned
 * against, so without this the marker floats off an avatar with a gap under it.
 */
const circleInsetClasses: Record<PlassCorner, string> = {
  'top-start': 'mt-[7%] ms-[7%]',
  'top-end': 'mt-[7%] me-[7%]',
  'bottom-start': 'mb-[7%] ms-[7%]',
  'bottom-end': 'mb-[7%] me-[7%]'
};

/**
 * The three materials, said the way a *control* says them: the marker is the
 * thing being coloured, so its sheet takes the tint.
 *
 * `solid` carries the gradient and the tinted lift and no gloss line, exactly as
 * a filled `PlButton` does. `ghost` is the one to reach for on a busy surface —
 * a soft tinted mark that reports without shouting.
 */
const variantClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'text-(--p-on-solid) [background-image:var(--p-fill)]',
    '[box-shadow:var(--p-elev),var(--p-lift)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    glassClasses,
    'border text-(--p-accent) bg-(--plass-glass)',
    '[border-color:var(--plass-border)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: 'text-(--p-accent) bg-(--p-soft-press)'
};

/** `99+`, but only for a value a `+` means anything on. */
function capContent(content: React.ReactNode, max: number): React.ReactNode {
  return typeof content === 'number' && content > max ? `${max}+` : content;
}

/**
 * A small mark in the corner of something else: unread mail on an inbox icon, a
 * status dot on an avatar, a count on a tab.
 *
 * The shell is a `<span>` that wraps the anchor and does nothing but establish a
 * positioning context — no width, no padding, `align-middle` — so a badged icon
 * button still measures and lines up exactly like a bare one. With no children
 * the marker lays out inline instead, which is what a standalone status pill is.
 *
 * There is no Base UI primitive under this, and there should not be: a badge has
 * no interaction, no state and no keyboard contract. It is a mark. Wiring it to a
 * widget primitive would hand every decorative dot a role it cannot honour.
 *
 * What it does owe a screen reader is a sentence rather than a number, which is
 * what `label` is for — `content={3}` beside a bell reads out as "3".
 */
export const PlBadge = /* @__PURE__ */ React.forwardRef<HTMLSpanElement, PlBadgeProps>(
  function PlBadge(
    {
      variant = 'solid',
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      elevation = 0,
      content,
      max = 99,
      dot = false,
      showZero = false,
      invisible = false,
      placement = 'top-end',
      overlap = 'square',
      label,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';
    const density = densityProp ?? defaults.density ?? 'default';

    const anchored = hasContent(children);
    // `0` is content, and `hasContent` would agree — this is the one place the
    // library asks a second question, because a count of nothing is not news.
    const empty = !hasContent(content) || (content === 0 && !showZero);
    const asDot = dot || empty;
    const hidden = invisible || (empty && !dot);

    const markerClasses = [
      'pointer-events-none z-10 inline-flex shrink-0 items-center justify-center',
      'font-semibold tabular-nums whitespace-nowrap',
      badgeRadiusClasses,
      transitionClasses,
      variantClasses[variant],
      asDot
        ? dotSizeClasses[size]
        : [
            badgeHeightClasses[size],
            badgeTextClasses[size],
            badgePaddingClasses[density][size]
          ].join(' '),
      anchored ? `absolute ${placementClasses[placement]}` : 'relative align-middle',
      anchored ? (asDot ? cornerOffsets[size].dot : cornerOffsets[size].badge) : '',
      anchored && overlap === 'circle' ? circleInsetClasses[placement] : '',
      // Visibility, not opacity: a half-faded badge is a badge you have to squint
      // at to find out whether it is there. The marker keeps its box either way,
      // so nothing around it moves when it comes back.
      hidden ? 'invisible' : '',
      className ?? ''
    ]
      .filter(Boolean)
      .join(' ');

    const capped = capContent(content, max);

    const marker = (
      <span
        ref={ref}
        className={markerClasses}
        style={{ ...controlSlots(color, elevation, variant), ...style }}
        // A hidden badge says nothing, and a marker whose whole meaning is already
        // in `label` would otherwise be read twice — once as "3", once as the
        // sentence. Everything else is left to speak for itself.
        aria-hidden={hidden ? true : undefined}
        {...props}
      >
        {/* Four cases, one element. A plain badge shows its count. A badge with a
          `label` shows the count and reads the sentence instead. A dot shows
          nothing and reads whichever of the two it was given — the count is
          still in the DOM, just clipped, so a quiet corner is not a silent one.
          A hidden badge holds none of it: a marker that is not there has nothing
          to say, and text left behind in a clipped box is text a search on the
          page still finds. */}
        {hidden ? null : (
          <>
            {asDot || label ? <span className={srOnlyClasses}>{label ?? capped}</span> : null}
            {asDot ? null : <span aria-hidden={label ? true : undefined}>{capped}</span>}
          </>
        )}
      </span>
    );

    if (!anchored) {
      return marker;
    }

    // `inline-flex` rather than `inline-block`: the shell has to be exactly as
    // wide and as tall as what it wraps, or a badged icon button stops lining up
    // with the bare one beside it.
    return (
      <span className="relative inline-flex shrink-0 align-middle">
        {children}
        {marker}
      </span>
    );
  }
);
