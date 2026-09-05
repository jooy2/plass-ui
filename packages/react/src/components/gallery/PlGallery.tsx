'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { dealColumns, ratioOf } from '../../internal/gallery.js';
import { responsiveSlots, withBaseline } from '../../internal/responsive.js';
import { usePlBreakpointValue } from '../../hooks/usePlBreakpoint.js';
import {
  cx,
  focusRingClasses,
  hasContent,
  metaTextClasses,
  radiusClasses,
  surfaceSlots,
  toLength,
  transitionClasses
} from '../../internal/styles.js';
import { PlImage } from '../image/PlImage.js';
import type { PlassColor, PlassResponsive, PlassSize } from '../../types.js';

/**
 * How the tiles are arranged.
 *
 * Four, and they answer four different questions rather than being four looks.
 * `grid` is a contact sheet: every tile the same shape, whatever shape the
 * files are. `masonry` keeps each picture's own proportion and stacks the
 * columns. `justified` keeps the proportions *and* fills every row to the edge,
 * scaling each row to a common height — the arrangement a photograph library
 * uses, and the only one where no tile is cropped and no space is left over.
 * `quilted` is a grid whose tiles may take more than one cell, for a set where
 * some pictures matter more than others.
 */
export type PlGalleryLayout = 'grid' | 'masonry' | 'justified' | 'quilted';

/** What a tile does when the pointer is on it. */
export type PlGalleryHover = 'none' | 'lift' | 'dim' | 'zoom';

/** Where a tile's words go. */
export type PlGalleryCaption = 'none' | 'below' | 'overlay' | 'hover';

/** One picture in the set. */
export interface PlGalleryItem {
  /** Where the picture is. */
  src: string;
  /** What the picture says. Required, for the reason `PlImage` requires it. */
  alt: string;
  /** A stable identity. Defaults to `src`. */
  id?: string;
  /** The first line of the caption. */
  title?: React.ReactNode;
  /** The second, one step down the scale and muted. */
  description?: React.ReactNode;
  /**
   * A larger file for the viewer, when the tile is a thumbnail. Falls back to
   * `src`, so a set that has only one size of each picture needs nothing here.
   */
  full?: string;
  /**
   * The picture's own proportion, as a number or a CSS ratio.
   *
   * `masonry` and `justified` are laid out from this, and both are laid out
   * *before* anything has loaded — which is the whole reason it is data rather
   * than a measurement. A set without it falls back to the gallery's own
   * `ratio`, and comes out as a grid of squares in a masonry's clothing.
   */
  ratio?: number | string;
  /** How many columns the tile takes in `quilted`. @default 1 */
  cols?: number;
  /** How many rows the tile takes in `quilted`. @default 1 */
  rows?: number;
}

/** The parts of a gallery a `className` does not reach. */
export interface PlGalleryClassNames {
  /** One tile's `<li>`. */
  item?: string;
  /** The picture inside it. */
  image?: string;
  /** The box the two lines of words sit in. */
  caption?: string;
  /** The first of them. */
  title?: string;
  /** The second. */
  description?: string;
}

export interface PlGalleryProps extends Omit<
  React.ComponentPropsWithoutRef<'ul'>,
  'children' | 'onSelect'
> {
  /** The pictures, in the order they are drawn. */
  items: readonly PlGalleryItem[];
  /** How the tiles are arranged. @default 'grid' */
  layout?: PlGalleryLayout;
  /**
   * How many tiles across, per breakpoint. Read by `grid`, `masonry` and
   * `quilted`; `justified` decides for itself, row by row.
   * @default { xs: 2, sm: 3, lg: 4 }
   */
  columns?: PlassResponsive<number>;
  /**
   * The space between tiles — a step of the size ladder, a number in pixels, or
   * a CSS length.
   * @default 'md'
   */
  gap?: PlassSize | number | string;
  /**
   * The shape of a tile in `grid`, and what an item with no `ratio` of its own
   * falls back to everywhere else.
   * @default 1
   */
  ratio?: number | string;
  /**
   * How tall a row aims to be in `justified`, and how tall one cell is in
   * `quilted`. Rows come out near it rather than on it, because the last thing
   * a justified row does is scale to the width it actually has.
   * @default 220
   */
  rowHeight?: number;
  /** Rounds the tiles. @default true */
  rounded?: boolean;
  /**
   * Where a tile's `title` and `description` go. `below` puts them under the
   * picture, `overlay` writes them across the foot of it, and `hover` is
   * `overlay` that arrives with the pointer.
   * @default 'none'
   */
  caption?: PlGalleryCaption;
  /**
   * What a tile does under the pointer.
   *
   * `lift` and `dim` are depth and colour, which is how everything else in the
   * library answers a pointer. `zoom` is the one that scales, and it is the
   * exception the design language names: what moves is a photograph inside a
   * frame that stays exactly where it was, with no text on it to resample.
   * @default 'lift'
   */
  hover?: PlGalleryHover;
  /**
   * Opens the picture full size when a tile is chosen, with the rest of the set
   * an arrow key away.
   *
   * The viewer is fetched on demand, so a gallery that does not offer one does
   * not carry it.
   * @default false
   */
  preview?: boolean;
  /** Called when a tile is chosen, whether or not there is a viewer. */
  onItemSelect?: (item: PlGalleryItem, index: number) => void;
  /** The list's accessible name. @default 'Gallery' */
  label?: string;
  /**
   * How a tile and the viewer's counter say where in the set they are.
   * @default (index, total) => `${index} of ${total}`
   */
  itemLabel?: (index: number, total: number) => string;
  /** What is drawn when `items` is empty. Nothing at all by default. */
  empty?: React.ReactNode;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** Class names for the parts behind the root. */
  classNames?: PlGalleryClassNames;
}

/**
 * The viewer, fetched only if somebody turns `preview` on.
 *
 * It is a whole overlay and the chrome around it, which is more than the
 * gallery that opens it — `PlImage` makes the same bargain with the same prop
 * and for the same reason: a wall of thumbnails is the common case and a
 * lightbox is not, so the chunk arrives after the first paint on the pages that
 * want one.
 */
const PlGalleryViewer = /* @__PURE__ */ React.lazy(() =>
  import('./PlGalleryViewer.js').then((module) => ({ default: module.PlGalleryViewer }))
);

/** The default, which is also the shape most photograph grids end up. */
const defaultColumns: PlassResponsive<number> = { xs: 2, sm: 3, lg: 4 };

/**
 * The gap ladder, as lengths rather than as classes.
 *
 * A gallery's gap reaches four different layouts — a grid's `gap`, a column
 * stack's, a flex row's, and the arithmetic a justified row does against it —
 * so it has to be a value and not a `gap-4`.
 */
const gapValues: Record<PlassSize, string> = {
  xs: '0.25rem',
  sm: '0.375rem',
  md: '0.5rem',
  lg: '0.75rem',
  xl: '1rem'
};

/**
 * What a tile does under the pointer, as the classes that say it.
 *
 * `dim` and `zoom` are on the picture and `lift` is on the frame, which is why
 * this is two tables rather than one.
 */
const frameHoverClasses: Record<PlGalleryHover, string> = {
  none: '',
  lift: 'group-hover/tile:[box-shadow:var(--plass-shadow-2)] group-focus-visible/tile:[box-shadow:var(--plass-shadow-2)]',
  dim: '',
  zoom: ''
};

const pictureHoverClasses: Record<PlGalleryHover, string> = {
  none: '',
  lift: '',
  dim: 'group-hover/tile:[&_img]:[filter:brightness(0.82)] group-focus-visible/tile:[&_img]:[filter:brightness(0.82)]',
  zoom: 'group-hover/tile:[&_img]:scale-106 group-focus-visible/tile:[&_img]:scale-106'
};

/** The wash a caption is written on, so the words survive a pale photograph. */
const captionScrimClasses =
  '[background:linear-gradient(to_top,color-mix(in_oklab,#000_72%,transparent),transparent)]';

/**
 * A set of pictures, arranged.
 *
 * The four layouts are the component: everything else — the captions, the
 * pointer treatment, the viewer — is the same in all of them, and choosing
 * between a contact sheet, a masonry, a justified library and a quilt is one
 * prop rather than four components.
 *
 * **None of them measures anything.** A tile's shape comes from the item's own
 * `ratio`, which means the whole arrangement is right in the first frame the
 * browser paints and does not move again as the files arrive — the same bargain
 * `PlImage`'s `ratio` makes one level up, and the reason a gallery of forty
 * photographs does not reflow forty times.
 */
export const PlGallery = /* @__PURE__ */ React.forwardRef<HTMLUListElement, PlGalleryProps>(
  function PlGallery(
    {
      items,
      layout = 'grid',
      columns,
      gap = 'md',
      ratio = 1,
      rowHeight = 220,
      rounded = true,
      caption = 'none',
      hover = 'lift',
      preview = false,
      onItemSelect,
      label,
      itemLabel,
      empty,
      size: sizeProp,
      color: colorProp,
      className,
      classNames,
      style,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';

    const labels = useLabels();
    const name = label ?? labels.gallery;
    const where = itemLabel ?? ((index: number, total: number) => `${index} of ${total}`);

    const [openAt, setOpenAt] = React.useState<number | null>(null);

    const lanes = withBaseline(columns ?? defaultColumns, 2);
    // The one number a layout has to know in JavaScript, and only `masonry`
    // does: the columns it deals into. Every other layout reads the same value
    // out of the cascade without React hearing about the resize.
    const laneCount = Math.max(1, usePlBreakpointValue(lanes) ?? 2);

    const space =
      typeof gap === 'string' && gap in gapValues
        ? gapValues[gap as PlassSize]
        : (toLength(gap as number | string) ?? gapValues.md);
    const radius = rounded ? radiusClasses[size] : '';
    const fallbackRatio = ratioOf(ratio, 1);

    const choose = (index: number) => {
      onItemSelect?.(items[index], index);

      if (preview) {
        setOpenAt(index);
      }
    };

    const tile = (item: PlGalleryItem, index: number, tileStyle: React.CSSProperties) => {
      const words = hasContent(item.title) || hasContent(item.description);
      const shown = caption !== 'none' && words;
      const over = caption === 'overlay' || caption === 'hover';

      const picture = (
        <PlImage
          src={item.src}
          alt={item.alt}
          // A contact sheet is a contact sheet: in `grid` every tile takes the
          // gallery's own `ratio` whatever shape the file is, which is the whole
          // difference between it and a masonry. `quilted` takes neither,
          // because the cell it spans has already decided.
          ratio={layout === 'grid' ? ratio : layout === 'quilted' ? 'auto' : (item.ratio ?? ratio)}
          fit="cover"
          rounded={false}
          size={size}
          color={color}
          className={cx('size-full', classNames?.image)}
        />
      );

      const legend = !shown ? null : (
        <div
          className={cx(
            'min-w-0',
            over
              ? cx(
                  'pointer-events-none absolute inset-x-0 bottom-0 flex flex-col gap-0.5 p-2.5 text-white',
                  captionScrimClasses,
                  caption === 'hover'
                    ? cx(
                        'opacity-0 group-hover/tile:opacity-100 group-focus-visible/tile:opacity-100',
                        '[transition:opacity_var(--plass-duration)_var(--plass-ease)]'
                      )
                    : ''
                )
              : 'flex flex-col gap-0.5 pt-1.5',
            classNames?.caption
          )}
        >
          {hasContent(item.title) ? (
            <span
              className={cx(
                'truncate font-medium',
                metaTextClasses[size],
                over ? '' : 'text-(--plass-fg)',
                classNames?.title
              )}
            >
              {item.title}
            </span>
          ) : null}

          {hasContent(item.description) ? (
            <span
              className={cx(
                'truncate',
                metaTextClasses[size],
                over ? 'text-white/80' : 'text-(--plass-muted-fg)',
                classNames?.description
              )}
            >
              {item.description}
            </span>
          ) : null}
        </div>
      );

      // The frame the picture is clipped to, and the only thing a `zoom` is
      // allowed to move inside.
      const framed = (
        <span
          className={cx(
            'relative block overflow-hidden',
            radius,
            layout === 'quilted' || layout === 'justified' ? 'size-full' : '',
            '[transition:box-shadow_var(--plass-duration)_var(--plass-ease)]',
            frameHoverClasses[hover],
            pictureHoverClasses[hover],
            '[&_img]:[transition:opacity_var(--plass-duration)_var(--plass-ease),filter_var(--plass-duration)_var(--plass-ease),scale_var(--plass-duration)_var(--plass-ease)]'
          )}
        >
          {picture}
          {over ? legend : null}
        </span>
      );

      const body =
        over || !shown ? (
          framed
        ) : (
          <>
            {framed}
            {legend}
          </>
        );

      return (
        <li
          key={item.id ?? item.src}
          className={cx(
            'group/tile relative m-0 min-w-0 list-none',
            layout === 'justified' ? 'flex flex-col' : '',
            classNames?.item
          )}
          style={tileStyle}
        >
          {preview || onItemSelect ? (
            <button
              type="button"
              // The picture's own words, plus where it sits: a reader tabbing a
              // wall of thumbnails is told which one of how many they are on.
              aria-label={`${item.alt} — ${where(index + 1, items.length)}`}
              className={cx(
                'block w-full bg-transparent p-0 text-start',
                preview ? 'cursor-zoom-in' : 'cursor-pointer',
                focusRingClasses,
                transitionClasses,
                radius,
                layout === 'justified' ? 'flex-1' : ''
              )}
              onClick={() => choose(index)}
            >
              {body}
            </button>
          ) : (
            body
          )}
        </li>
      );
    };

    let children: React.ReactNode;

    if (layout === 'masonry') {
      const ratios = items.map((item) => ratioOf(item.ratio, fallbackRatio));

      children = dealColumns(ratios, laneCount).map((lane, index) => (
        <li
          key={index}
          // A lane is a list item holding a list, rather than a `<div>` between
          // the `<ul>` and its `<li>`s, which is markup a screen reader reads as
          // a list with nothing in it.
          className="m-0 flex min-w-0 flex-1 list-none flex-col"
          style={{ gap: space }}
        >
          <ul className="m-0 flex list-none flex-col p-0" style={{ gap: space }}>
            {lane.map((at) => tile(items[at], at, {}))}
          </ul>
        </li>
      ));
    } else if (layout === 'justified') {
      children = items.map((item, index) => {
        const each = ratioOf(item.ratio, fallbackRatio);

        return tile(item, index, {
          // Grown in proportion to the picture's own width, from a basis in the
          // same proportion — which is what makes every tile in a row come out
          // the same height once the row has been stretched to the edge.
          flexGrow: each,
          flexBasis: `${each * rowHeight}px`,
          maxWidth: '100%'
        });
      });
    } else {
      children = items.map((item, index) =>
        tile(
          item,
          index,
          layout === 'quilted'
            ? {
                gridColumn: `span ${Math.max(1, Math.round(item.cols ?? 1))}`,
                gridRow: `span ${Math.max(1, Math.round(item.rows ?? 1))}`
              }
            : {}
        )
      );
    }

    if (items.length === 0 && hasContent(empty)) {
      return <>{empty}</>;
    }

    return (
      <>
        <ul
          ref={ref}
          role="list"
          aria-label={name}
          className={cx(
            'plass-gallery m-0 list-none p-0',
            layout === 'justified' ? 'flex flex-wrap' : '',
            layout === 'masonry' ? 'flex items-start' : '',
            layout === 'grid' ? 'plass-gallery-grid grid' : '',
            layout === 'quilted' ? 'plass-gallery-quilted grid' : '',
            className
          )}
          style={{
            gap: space,
            ...surfaceSlots(color, 0),
            ...responsiveSlots('cols', lanes, (value) => String(Math.max(1, Math.round(value)))),
            ...(layout === 'quilted'
              ? { gridAutoRows: `${rowHeight}px`, gridAutoFlow: 'dense' }
              : null),
            ...style
          }}
          {...props}
        >
          {children}
        </ul>

        {preview ? (
          <React.Suspense fallback={null}>
            <PlGalleryViewer
              items={items}
              index={openAt}
              onIndexChange={setOpenAt}
              size={size}
              color={color}
              label={name}
              itemLabel={where}
            />
          </React.Suspense>
        ) : null}
      </>
    );
  }
);
