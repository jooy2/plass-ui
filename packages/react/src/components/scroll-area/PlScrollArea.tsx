'use client';

import * as React from 'react';
import { ScrollArea } from '@base-ui/react/scroll-area';
import { useDefaults } from '../../internal/defaults.js';
import { cx, focusRingInsetClasses, radiusClasses, toLength } from '../../internal/styles.js';
import type { PlassOrientation, PlassSize } from '../../types.js';

/**
 * Which axes may scroll.
 *
 * `PlassOrientation` plus a third value rather than the shared type widened,
 * because "both" is meaningless everywhere else it is used — a `PlDivider`, a
 * `PlButtonGroup` and a `PlSlider` each run one way — and widening it there to
 * say it here would be a fourth value nobody can answer.
 */
export type PlScrollAreaAxis = PlassOrientation | 'both';

/** Classes for the parts a `className` does not reach. */
export interface PlScrollAreaClassNames {
  /** The scrolling element itself — the one that takes the focus and the keys. */
  viewport?: string;
  /** The lane a scrollbar runs in. */
  scrollbar?: string;
  /** The bar inside it. */
  thumb?: string;
}

export interface PlScrollAreaProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * Which axes may scroll.
   * @default 'vertical'
   */
  orientation?: PlScrollAreaAxis;
  /**
   * A fixed height. A number is pixels; a string is any CSS length.
   *
   * **A vertical scroll area has to be bounded by something**, or there is
   * nothing for the content to overflow and the box simply grows. This is that
   * something, and it is a prop rather than a `className` because it is the one
   * measurement without which the component does nothing at all.
   */
  height?: number | string;
  /** The height it stops growing at, for a box that should shrink to short content. */
  maxHeight?: number | string;
  /** The same two for a horizontal area. */
  width?: number | string;
  maxWidth?: number | string;
  /**
   * When the scrollbars are drawn.
   *
   * - `auto` — while the pointer is over the box or the content is moving, and
   *   never otherwise. The default, and what a reader is used to on a Mac.
   * - `always` — kept at full strength. For a panel whose whole point is that
   *   there is more below, where a bar that appears on hover is a signal
   *   nobody standing back from the screen ever sees.
   *
   * Either way the lane is **overlaid**, so turning it on does not reflow the
   * content underneath.
   * @default 'auto'
   */
  scrollbars?: 'auto' | 'always';
  /**
   * A name for the region.
   *
   * Worth giving, and the reason is not obvious: a scrollable box **is a tab
   * stop** when there is nothing focusable inside it, because a keyboard reader
   * has to be able to scroll it. A tab stop with no name is announced as
   * nothing at all, so a name is what turns it from a mystery landing point
   * into "Release notes, region".
   */
  label?: string;
  /** Thickness of the scrollbars and the corner the box is cut to. @default 'md' */
  size?: PlassSize;
  /** Classes on the parts a `className` does not reach. */
  classNames?: PlScrollAreaClassNames;
  /** What scrolls. */
  children?: React.ReactNode;
}

/**
 * How wide a lane is, thumb and its inset together.
 *
 * Its own ladder rather than a fraction of the control heights: a scrollbar is
 * furniture beside the content, not a control that has to line up with a field
 * in the same row.
 */
const laneClasses: Record<PlassSize, string> = {
  xs: 'w-2 data-[orientation=horizontal]:h-2 data-[orientation=horizontal]:w-auto',
  sm: 'w-2.5 data-[orientation=horizontal]:h-2.5 data-[orientation=horizontal]:w-auto',
  md: 'w-3 data-[orientation=horizontal]:h-3 data-[orientation=horizontal]:w-auto',
  lg: 'w-3.5 data-[orientation=horizontal]:h-3.5 data-[orientation=horizontal]:w-auto',
  xl: 'w-4 data-[orientation=horizontal]:h-4 data-[orientation=horizontal]:w-auto'
};

/** The inset that turns a lane into a thumb: two pixels either side, at every step. */
const LANE_INSET = 'p-[0.125rem]';

/**
 * A bounded box that scrolls, with the library's own scrollbar in it.
 *
 * The reason to reach for it over `overflow: auto` is the **bar**. A platform
 * scrollbar is either an overlay that vanishes the moment the content stops
 * moving, or fifteen pixels of permanent grey furniture, and neither of them
 * belongs beside a translucent sheet. This one is the library's own material:
 * the thumb is `--plass-track`, the same neutral ink a slider's rail and a
 * progress groove are cut in, and the lane is overlaid so drawing it costs the
 * content no width.
 *
 * It is **not** a [PlScrollZone](./scroll-zone), which is the other answer to
 * the same fact. A scroll zone is a strip that runs off the end of its box: it
 * takes the scrollbar away entirely, fades the end that still has something
 * behind it and adds a pair of buttons. That is right for a row of tabs or
 * chips, where a bar under one line of labels is heavier than the labels. This
 * is right for a panel of content, where the bar is the honest signal and where
 * a reader wants to know **how far through** they are, which a fade cannot say.
 *
 * There is no fade here for that reason: two signals for one fact, one of which
 * is measured and one of which is not, is one more than the box needs.
 *
 * Base UI owns the behaviour — the overlay measurement, the thumb's size and
 * position, the drag, and making the viewport a tab stop exactly while there is
 * something to scroll.
 */
export const PlScrollArea = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlScrollAreaProps>(
  function PlScrollArea(
    {
      orientation = 'vertical',
      height,
      maxHeight,
      width,
      maxWidth,
      scrollbars = 'auto',
      label,
      size: sizeProp,
      classNames,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';

    const vertical = orientation !== 'horizontal';
    const horizontal = orientation !== 'vertical';

    const lane = cx(
      'flex touch-none select-none',
      LANE_INSET,
      laneClasses[size],
      // The lane fades rather than unmounting, so a bar that appears under the
      // pointer does not arrive as a jump. `always` is the same lane held open.
      '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
      scrollbars === 'always'
        ? 'opacity-100'
        : 'opacity-0 data-[hovering]:opacity-100 data-[scrolling]:opacity-100',
      classNames?.scrollbar
    );

    return (
      <ScrollArea.Root
        ref={ref}
        className={cx('plass-scroll-area relative overflow-hidden', radiusClasses[size], className)}
        style={{
          height: toLength(height),
          maxHeight: toLength(maxHeight),
          width: toLength(width),
          maxWidth: toLength(maxWidth),
          ...style
        }}
        {...props}
      >
        <ScrollArea.Viewport
          // `region` only when there is a name for it. An unnamed region is a
          // landmark a screen reader lists as "region" and nothing else, which
          // is worse than no landmark at all.
          role={label ? 'region' : undefined}
          aria-label={label}
          className={cx(
            'size-full overscroll-contain',
            radiusClasses[size],
            focusRingInsetClasses,
            classNames?.viewport
          )}
        >
          <ScrollArea.Content>{children}</ScrollArea.Content>
        </ScrollArea.Viewport>

        {vertical ? (
          <ScrollArea.Scrollbar orientation="vertical" className={lane}>
            <ScrollArea.Thumb
              className={cx('flex-1 rounded-full bg-(--plass-track)', classNames?.thumb)}
            />
          </ScrollArea.Scrollbar>
        ) : null}

        {horizontal ? (
          <ScrollArea.Scrollbar orientation="horizontal" className={lane}>
            <ScrollArea.Thumb
              className={cx('flex-1 rounded-full bg-(--plass-track)', classNames?.thumb)}
            />
          </ScrollArea.Scrollbar>
        ) : null}

        {/* Only where two lanes can meet. One lane has no corner to fill. */}
        {vertical && horizontal ? <ScrollArea.Corner /> : null}
      </ScrollArea.Root>
    );
  }
);
