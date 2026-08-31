'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import {
  controlSlots,
  controlTextClasses,
  cx,
  focusRingClasses,
  gapClasses,
  glassClasses,
  hasContent,
  iconClasses,
  iconSizeClasses,
  metaTextClasses,
  paddingXClasses,
  sheetBodyClasses,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassDensity,
  PlassElevation,
  PlassPosition,
  PlassSize,
  PlassStyleProps,
  PlassVariant
} from '../../types.js';

export interface PlPillProps
  extends
    PlassStyleProps,
    Omit<
      React.ComponentPropsWithoutRef<'div'>,
      // `title` is the tooltip attribute on every element; here it is the pill's
      // headline, and a `ReactNode` rather than a string.
      'color' | 'onClick' | 'title'
    > {
  /**
   * Drop shadow depth. `2` here, against the `0` almost everything else takes.
   *
   * That is not an inconsistency: a pill is defined by **not** being part of the
   * page. Every other surface in the library rests on the page and earns its
   * separation from the glass edge, so a shadow is opt-in. This one hovers over
   * whatever is underneath it, and a lozenge lying flat on the content it is
   * floating over reads as a mistake — the same argument
   * `PlFloatingBottomNavigation` makes for its own `2`.
   * @default 2
   */
  elevation?: PlassElevation;
  /**
   * The leading slot — a glyph, an avatar, a status dot, a photo.
   *
   * It is given a square box of its own and clipped to a circle, so an `<img>`
   * lands in it as readily as an icon does: the image fills the box and is
   * cropped rather than letterboxed, which is what a 20px portrait wants.
   */
  startIcon?: React.ReactNode;
  /** The trailing slot. Outside the pressable area, so it can be a control. */
  endIcon?: React.ReactNode;
  /**
   * The headline in the middle — what the pill is currently about.
   *
   * A prop rather than something to compose, for the reason `PlCard`'s title is
   * one: the arrangement is fixed and what a caller wants to decide is what goes
   * in each slot. Almost every pill is a line of text and an optional second
   * line under it, and spelling that as children means every caller inventing
   * their own centring and type scale.
   */
  title?: React.ReactNode;
  /** The second line, under the title. One step down and quieter. */
  description?: React.ReactNode;
  /**
   * The second half, revealed when `expanded`.
   *
   * The pill grows downward into it rather than swapping to a different shape:
   * one object saying more.
   */
  details?: React.ReactNode;
  /** Whether `details` is showing. @default false */
  expanded?: boolean;
  /**
   * How it sits in the page's scroll. `fixed` pins it against the viewport and
   * centres it horizontally, which is the arrangement this shape exists for.
   * @default 'static'
   */
  position?: PlassPosition;
  /** Which edge it is held against when `position` is not `static`. @default 'top' */
  side?: 'top' | 'bottom';
  /** Passing it makes the middle a real button. */
  onClick?: React.MouseEventHandler<HTMLButtonElement>;
  /**
   * Anything the middle needs that `title` and `description` cannot say — a
   * pair of small readouts, a live counter. Rendered under them, in the same
   * centred column.
   */
  children?: React.ReactNode;
}

/**
 * The three materials, said the way a *control* says them — the surface takes
 * the tint, as on a `PlButton` and a `PlChip`, because a pill is the thing being
 * coloured rather than a sheet holding somebody else's content.
 */
const restClasses: Record<PlassVariant, string> = {
  solid:
    'text-(--p-on-solid) [background-image:var(--p-fill)] [box-shadow:var(--p-elev),var(--p-lift)]',
  glass: /* @__PURE__ */ [
    glassClasses,
    'border text-(--p-accent) bg-(--plass-glass)',
    '[border-color:var(--plass-glass-line)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: `${glassClasses} text-(--p-accent) bg-(--p-soft)`
};

const hoverClasses: Record<PlassVariant, string> = {
  solid: 'hover:brightness-105 active:brightness-95',
  glass:
    'hover:bg-(--plass-glass-hover) hover:[border-color:var(--p-line)] active:bg-(--plass-glass-press)',
  ghost: 'hover:bg-(--p-soft-hover) active:bg-(--p-soft-press)'
};

/**
 * The row's floor, as a minimum rather than as a height.
 *
 * The numbers are `controlHeightClasses`' — a collapsed pill lines up with a
 * `PlButton` of the same `size` beside it — but a pill carrying a description is
 * two lines tall and a fixed height would clip the second.
 */
const rowMinHeightClasses: Record<PlassSize, string> = {
  xs: 'min-h-5.5',
  sm: 'min-h-6.5',
  md: 'min-h-8',
  lg: 'min-h-10',
  xl: 'min-h-12'
};

/**
 * Exactly half the row's minimum height at every step — 22, 26, 32, 40 and 48px
 * — so a collapsed pill is a true stadium.
 *
 * Written as a length rather than as `rounded-full`, and the difference only
 * shows once the pill grows: `rounded-full` on a box that has taken a second
 * line, or opened its `details`, is a corner half its new height, and a corner
 * that big eats the first two words of every line. Pinning the radius to the
 * *row* is what lets the lozenge grow into a rounded rectangle with the same
 * corner it always had.
 */
const pillRadiusClasses: Record<PlassSize, string> = {
  xs: 'rounded-[0.6875rem]',
  sm: 'rounded-[0.8125rem]',
  md: 'rounded-[1rem]',
  lg: 'rounded-[1.25rem]',
  xl: 'rounded-[1.5rem]'
};

/**
 * The air either side of the middle, and the thing that makes this shape read as
 * the lozenge it is rather than as a wide `PlChip`.
 *
 * Roughly double the control padding at every step. The leading glyph and the
 * trailing slot are the pill's furniture; what it is *about* is the column
 * between them, and giving that column noticeably more room than either
 * neighbour is what puts the eye there first. `density` halves it, exactly as it
 * does everywhere else.
 */
const centerPaddingClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'px-3', sm: 'px-4', md: 'px-5', lg: 'px-6', xl: 'px-8' },
  compact: { xs: 'px-1.5', sm: 'px-2', md: 'px-2.5', lg: 'px-3', xl: 'px-4' }
};

/**
 * The leading box: a square the size of a standalone glyph, clipped round.
 *
 * `iconSizeClasses` rather than a ladder of its own, because that table already
 * answers the same question — how big is a glyph that is not riding on a label —
 * and the leading slot of a pill is exactly that.
 */
const mediaClasses =
  'flex shrink-0 items-center justify-center overflow-hidden rounded-full [&_img]:size-full [&_img]:object-cover';

/**
 * The description under the title.
 *
 * Mixed toward transparent rather than pointed at `--plass-muted-fg`: the middle
 * of a pill sits on the colour family's own fill as often as on a bare surface,
 * and a fixed grey that reads as secondary on white reads as dirt on `primary`.
 * Taking the ink that is already there and letting some of the surface through
 * is the one form of "one step quieter" that holds on all three materials.
 */
const descriptionClasses = '[color:color-mix(in_oklab,currentColor_72%,transparent)]';

/** Where a pinned pill hangs, and how far in from the edge. */
const positionClasses: Record<PlassPosition, Record<'top' | 'bottom', string>> = {
  static: { top: '', bottom: '' },
  sticky: { top: 'sticky top-3 z-20', bottom: 'sticky bottom-3 z-20' },
  fixed: {
    // Centred by stretching the box across the viewport and letting `mx-auto`
    // shrink it back, not by translating it half its own width. The house rule
    // against transforming a surface holds here too, and `auto` margins are
    // direction-agnostic, so the lozenge stays centred under RTL.
    top: 'fixed inset-x-0 top-3 z-30 mx-auto w-fit',
    bottom: 'fixed inset-x-0 bottom-3 z-30 mx-auto w-fit'
  }
};

/**
 * A floating lozenge holding a small amount of live information.
 *
 * The shape is a **stadium**, which the house radius rule otherwise forbids:
 * every control is held just short of the 50% that would make it a pill, because
 * the flat run along its top and bottom edge is what still reads as a sheet with
 * the corners cut off it. This is the exception the rule is drawn against, and
 * it works for the same reason the rule does — this is not a sheet lying on the
 * page. It is an object hovering over one, and an object hovering over the page
 * should not look as though it was cut from the same material.
 *
 * `details` is revealed by animating a measured height, exactly as a
 * `PlAccordion` panel is: nothing is transformed and no text is resampled, the
 * pill is simply a window that opens. The measurement is a `ResizeObserver`
 * rather than a hardcoded height, so a details area whose content changes —
 * which is what live information does — grows with it.
 */
export const PlPill = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlPillProps>(function PlPill(
  {
    variant = 'solid',
    size: sizeProp,
    color: colorProp,
    density: densityProp,
    elevation = 2,
    startIcon,
    endIcon,
    title,
    description,
    details,
    expanded = false,
    position = 'static',
    side = 'top',
    className,
    style,
    children,
    onClick,
    ...props
  },
  ref
) {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'secondary';
  const density = densityProp ?? defaults.density ?? 'default';

  const detailsRef = React.useRef<HTMLDivElement>(null);
  const [detailsHeight, setDetailsHeight] = React.useState(0);

  React.useEffect(() => {
    const element = detailsRef.current;

    if (!element || typeof ResizeObserver === 'undefined') {
      return;
    }

    const observer = new ResizeObserver(() => setDetailsHeight(element.scrollHeight));

    observer.observe(element);
    setDetailsHeight(element.scrollHeight);

    return () => observer.disconnect();
  }, [details]);

  const interactive = Boolean(onClick);
  const padX = paddingXClasses[density][size];

  const row = (
    <>
      {hasContent(startIcon) ? (
        <span className={cx(mediaClasses, iconSizeClasses[size])}>{startIcon}</span>
      ) : null}

      {/* The middle. Centred in its own column rather than run on from the
            glyph, and padded well clear of both neighbours — the pill is a frame
            and this is what is in it. */}
      {hasContent(title) || hasContent(description) || hasContent(children) ? (
        <span
          className={cx(
            'flex min-w-0 flex-1 flex-col items-center justify-center text-center',
            centerPaddingClasses[density][size]
          )}
        >
          {hasContent(title) ? <span className="max-w-full truncate">{title}</span> : null}
          {hasContent(description) ? (
            <span
              className={cx(
                'max-w-full truncate font-normal',
                metaTextClasses[size],
                descriptionClasses
              )}
            >
              {description}
            </span>
          ) : null}
          {children}
        </span>
      ) : null}
    </>
  );

  return (
    <div
      ref={ref}
      className={cx(
        'inline-flex max-w-full flex-col overflow-hidden align-middle',
        pillRadiusClasses[size],
        'font-medium whitespace-nowrap select-none',
        controlTextClasses[size],
        restClasses[variant],
        transitionClasses,
        iconClasses,
        interactive ? `plass-glow ${hoverClasses[variant]}` : '',
        positionClasses[position][side],
        className
      )}
      style={{ ...controlSlots(color, elevation, variant), ...style }}
      {...props}
    >
      <div
        className={cx(
          // `min-h` rather than a fixed height: one line keeps the stadium the
          // radius ladder is cut for, and a title with a description under it
          // grows into a rounded rectangle instead of being clipped. `py-1`
          // costs nothing in the one-line case — the minimum is taller than
          // the line plus the padding — and is what keeps two lines off the
          // edges.
          'flex shrink-0 items-center py-1',
          rowMinHeightClasses[size],
          gapClasses[size],
          // With a pressable middle the padding belongs to the button, so its
          // hit area covers the whole row rather than just the words.
          interactive ? 'ps-0' : padX,
          hasContent(endIcon) ? 'pe-1' : interactive ? 'pe-0' : ''
        )}
      >
        {interactive ? (
          // A real `<button>` inside the shell rather than a handler on the
          // shell itself, and `endIcon` deliberately outside it — the same
          // shape `PlChip` uses, and for the same two reasons: a `<div>`
          // carrying a click handler is invisible to a keyboard, and a
          // `<button>` holding the control somebody put in `endIcon` is markup
          // the browser rewrites on parse.
          <button
            type="button"
            className={cx(
              'flex min-w-0 flex-1 cursor-pointer items-center justify-center self-stretch',
              // `inherit`, so the focus ring traces the lozenge's own corners
              // rather than drawing a second, squarer rectangle inside them.
              'rounded-[inherit]',
              gapClasses[size],
              padX,
              focusRingClasses
            )}
            onClick={onClick}
          >
            {row}
          </button>
        ) : (
          row
        )}

        {hasContent(endIcon) ? (
          <span className="flex h-[1lh] shrink-0 items-center">{endIcon}</span>
        ) : null}
      </div>

      {hasContent(details) ? (
        <div
          className={cx(
            'overflow-hidden',
            '[transition:height_var(--plass-duration-slow)_var(--plass-ease)]',
            'motion-reduce:[transition-duration:0ms]'
          )}
          style={{ height: expanded ? detailsHeight : 0 }}
          // `inert` rather than `aria-hidden`: a collapsed panel is a
          // zero-height box that its content is still perfectly focusable
          // inside, and `aria-hidden` alone would leave a keyboard reader
          // tabbing into something their screen reader has been told does not
          // exist.
          inert={!expanded}
        >
          <div
            ref={detailsRef}
            className={cx('whitespace-normal pb-2', padX, sheetBodyClasses[size])}
          >
            {details}
          </div>
        </div>
      ) : null}
    </div>
  );
});
