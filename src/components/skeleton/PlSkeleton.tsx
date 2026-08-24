import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { controlHeightClasses, controlSquareClasses, surfaceSlots } from '../../internal/styles';
import type { PlassColor, PlassSize } from '../../types';

/**
 * What the placeholder is standing in for.
 *
 * - `line` — a run of text. Sized off the type scale, so a `md` line is exactly
 *   as tall as the `md` type it will be replaced by.
 * - `rect` — a block: an image, a chart, a card, a map.
 * - `circle` — an avatar, or anything else round.
 */
export type PlSkeletonShape = 'line' | 'rect' | 'circle';

export interface PlSkeletonProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /** @default 'line' */
  shape?: PlSkeletonShape;
  /**
   * How many lines to draw, for `shape="line"`. The last one is drawn short, the
   * way the last line of a paragraph is, so a block of them reads as prose
   * rather than as a barcode. Ignored by the other two shapes.
   * @default 1
   */
  lines?: number;
  /**
   * The scale of the thing being stood in for: the type scale for a `line`, the
   * diameter for a `circle`, the default block height for a `rect`.
   * @default 'md'
   */
  size?: PlassSize;
  /**
   * Colour family. `secondary` by default, and it is worth leaving there: a
   * placeholder that carries a semantic colour is saying something about content
   * that has not arrived yet.
   * @default 'secondary'
   */
  color?: PlassColor;
  /** An explicit width. Numbers are pixels. */
  width?: number | string;
  /** An explicit height. Numbers are pixels. */
  height?: number | string;
  /**
   * The travelling highlight. Turn it off for a page holding dozens of them, or
   * where the wait is expected to be long enough that motion becomes noise.
   *
   * A reduced-motion preference already replaces the sweep with a colour pulse
   * without being asked, so this is not the accessibility switch.
   * @default true
   */
  animated?: boolean;
  /**
   * What a screen reader is told, if anything.
   *
   * Unset — the default — the placeholder is `aria-hidden`, because a dozen
   * boxes each announcing themselves is worse than silence. Give the *one*
   * skeleton that stands for the whole region a label and it becomes a live
   * `status` instead.
   */
  label?: string;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
}

/**
 * A line's height is the type scale itself — the same lengths
 * `sheetBodyClasses` sets as a font size — so a placeholder occupies the em box
 * of the text that replaces it. The leading around it is `lineGapClasses`, and
 * the two together add up to that ladder's line box.
 */
const lineHeightClasses: Record<PlassSize, string> = {
  xs: 'h-[0.6875rem]',
  sm: 'h-[0.75rem]',
  md: 'h-[0.8125rem]',
  lg: 'h-[0.9375rem]',
  xl: 'h-[1.0625rem]'
};

/** The leading: the body ladder's line box less the bar drawn in it. */
const lineGapClasses: Record<PlassSize, string> = {
  xs: 'gap-[0.3125rem]',
  sm: 'gap-[0.375rem]',
  md: 'gap-[0.5625rem]',
  lg: 'gap-[0.5625rem]',
  xl: 'gap-[0.6875rem]'
};

/**
 * A bar's corner, at ~45% of its own height — held just short of the 50% that
 * would make it a capsule.
 *
 * Not `radiusClasses`, which is ~30% of a *control's* height: 12px on a 13px bar
 * is a capsule and a half. Not `tickRadiusClasses` either, which is sized
 * against a box rather than against a run of text.
 */
const barRadiusClasses: Record<PlassSize, string> = {
  xs: 'rounded-[0.3125rem]',
  sm: 'rounded-[0.3125rem]',
  md: 'rounded-[0.375rem]',
  lg: 'rounded-[0.4375rem]',
  xl: 'rounded-[0.5rem]'
};

/**
 * What a `rect` is as tall as when nothing says otherwise: a thumbnail. Anything
 * else wants `height`, and most uses of this shape pass one.
 */
const blockHeightClasses: Record<PlassSize, string> = {
  xs: 'h-12',
  sm: 'h-16',
  md: 'h-20',
  lg: 'h-28',
  xl: 'h-36'
};

/** A block's corner is the sheet ladder, because a block stands for a sheet. */
const blockRadiusClasses: Record<PlassSize, string> = {
  xs: 'rounded-(--plass-radius-xs)',
  sm: 'rounded-(--plass-radius-sm)',
  md: 'rounded-(--plass-radius-md)',
  lg: 'rounded-(--plass-radius-lg)',
  xl: 'rounded-(--plass-radius-xl)'
};

/**
 * The surface, and it is deliberately **not** glass.
 *
 * Every other sheet in the library is translucent over a blurred backdrop,
 * because it is a thing sitting on the page. A skeleton is the opposite: it is
 * the shape of something that is not there yet, so it is a flat tint and nothing
 * else — no blur, no hairline, no gloss, no shadow. It also keeps a page of
 * thirty placeholders from asking for thirty backdrop filters.
 */
const fillClasses = 'relative overflow-hidden bg-(--p-soft-hover)';

/** Pixels for a bare number, and whatever was written for a string. */
function length(value: number | string | undefined): string | undefined {
  if (value === undefined) {
    return undefined;
  }

  return typeof value === 'number' ? `${value}px` : value;
}

/**
 * The shape of something that has not loaded yet.
 *
 * It reserves the space the real thing will take, which is the whole job: a card
 * that grows by 200px when its image arrives has moved everything below it while
 * somebody was reading. A spinner cannot do that.
 *
 * The three shapes are the three things a layout is made of — a run of text, a
 * block and a circle — and each is sized off the ladder the real component uses,
 * so a `md` line is as tall as `md` type and a `md` circle is exactly a
 * `PlAvatar` at `md`.
 */
export const PlSkeleton = React.forwardRef<HTMLDivElement, PlSkeletonProps>(function PlSkeleton(
  {
    shape = 'line',
    lines = 1,
    size = 'md',
    color = 'secondary',
    width,
    height,
    animated = true,
    label,
    render,
    className,
    style,
    ...props
  },
  ref
) {
  // The sweep lives in `styles.css` rather than in an arbitrary variant for the
  // reason `.plass-glow` does: a keyframe is not a Tailwind variant, so there is
  // nothing to express one with.
  const sweep = animated ? 'plass-skeleton' : '';

  const shapeClasses =
    shape === 'circle'
      ? `shrink-0 rounded-full ${controlHeightClasses[size]} ${controlSquareClasses[size]}`
      : shape === 'rect'
        ? `w-full ${blockRadiusClasses[size]} ${height === undefined ? blockHeightClasses[size] : ''}`
        : `w-full ${barRadiusClasses[size]} ${lineHeightClasses[size]}`;

  // Unlabelled it is scenery and says nothing; labelled it is the one element
  // that reports the wait for the region around it.
  const announce = label
    ? ({ role: 'status', 'aria-busy': true, 'aria-label': label } as const)
    : ({ 'aria-hidden': true } as const);

  // A run of lines is a stack of bars rather than one box, so the gaps between
  // them are real gaps: text has leading, and a striped gradient would not
  // survive a caller putting the block in a flex row. The root then holds only
  // the stacking, which is why it drops the fill and the sweep.
  const stacked = shape === 'line' && lines > 1;

  return useRender({
    render,
    ref,
    props: {
      className: (stacked
        ? ['flex w-full flex-col', lineGapClasses[size], className ?? '']
        : [fillClasses, sweep, shapeClasses, className ?? '']
      )
        .filter(Boolean)
        .join(' '),
      style: {
        ...surfaceSlots(color, 0),
        width: length(width),
        height: length(height),
        ...style
      },
      ...announce,
      ...(stacked
        ? {
            children: Array.from({ length: lines }, (_, index) => (
              <div
                key={index}
                className={[
                  fillClasses,
                  sweep,
                  barRadiusClasses[size],
                  lineHeightClasses[size],
                  // The last line of a paragraph does not reach the margin.
                  index === lines - 1 ? 'w-3/5' : 'w-full'
                ]
                  .filter(Boolean)
                  .join(' ')}
              />
            ))
          }
        : null),
      ...props
    }
  });
});
