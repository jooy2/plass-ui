'use client';

import * as React from 'react';
import { PreviewCard } from '@base-ui/react/preview-card';
import { useDefaults } from '../../internal/defaults.js';
import {
  cx,
  glassClasses,
  hasContent,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceSlots
} from '../../internal/styles.js';
import type { PlassAlign, PlassSide, PlassSize, PlassStyleProps } from '../../types.js';

/**
 * A hover card takes `size`, `color` and `density` and stops there, for
 * `PlPopover`'s reasons: a popup that was asked for has already answered what
 * `variant` asks, and a surface that genuinely floats is fixed at the top of the
 * elevation ladder.
 */
export interface PlHoverCardProps
  extends
    Pick<PlassStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title' | 'children'> {
  /**
   * What the card previews. Exactly one element, which must accept a ref and
   * spread props — every Plass component does, and so does a bare `<a>`.
   *
   * Usually a link. A hover card is a look ahead at what is behind something,
   * and the thing it is ahead of is nearly always somewhere you can go.
   */
  trigger: React.ReactElement;
  /** The heading, rendered as the element that names the card. */
  title?: React.ReactNode;
  /** A line under the title. */
  description?: React.ReactNode;
  /** The body. */
  children?: React.ReactNode;
  /**
   * Which edge of the trigger it appears on. Flips to the opposite side when
   * there is no room.
   * @default 'bottom'
   */
  side?: PlassSide;
  /** Where it sits along that edge. @default 'center' */
  align?: PlassAlign;
  /** Distance from the trigger, in pixels. @default 8 */
  sideOffset?: number;
  /** Shift along that edge, in pixels. @default 0 */
  alignOffset?: number;
  /**
   * How long the pointer has to rest on the trigger before it opens, in
   * milliseconds.
   *
   * Long by default, and that is the whole difference between a helpful preview
   * and a page that flinches. A card that opens the moment a pointer crosses a
   * link opens on every link a reader passes on the way to somewhere else.
   * @default 600
   */
  delay?: number;
  /**
   * How long it waits after the pointer leaves, in milliseconds.
   *
   * Not zero, and it cannot be: the gap between the trigger and the card is
   * pointer-free, so a card that closed instantly could never be reached.
   * @default 300
   */
  closeDelay?: number;
  /** Draws the little wedge pointing at the trigger. @default false */
  arrow?: boolean;
  /** Whether the card is open. Use with `onOpenChange` for a controlled one. */
  open?: boolean;
  /** Whether it starts open, for an uncontrolled one. */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * A hard cap on the card's width, overriding the one `size` implies. Numbers
   * are pixels.
   */
  width?: number | string;
}

/**
 * How wide the card is allowed to get, per `size`.
 *
 * One rung wider than a `PlPopover`'s at every step. A popover is a detail
 * beside a control; a hover card is a preview of a whole thing, and a preview
 * squeezed to the width of a hint is a preview nobody reads.
 */
const maxWidthClasses: Record<PlassSize, string> = {
  xs: 'max-w-64',
  sm: 'max-w-72',
  md: 'max-w-sm',
  lg: 'max-w-md',
  xl: 'max-w-lg'
};

/** The sheet: the same frosted panel a `PlPopover` draws, at the same rung. */
const popupClasses = /* @__PURE__ */ [
  glassClasses,
  'relative flex flex-col',
  'border text-(--plass-fg) bg-(--plass-glass-press)',
  '[border-color:var(--plass-glass-line)]',
  '[box-shadow:var(--plass-shadow-3),var(--plass-gloss-glass)]',
  '[outline:none]',
  // Opacity only, as everywhere else a surface full of text arrives: a popup
  // that slides in drags its own words across the screen.
  '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

/** The wedge, at roughly a third of the sheet's corner radius per step. */
const arrowSizes: Record<PlassSize, number> = {
  xs: 8,
  sm: 9,
  md: 10,
  lg: 11,
  xl: 12
};

/**
 * A preview of what is behind a link, shown when the pointer rests on it.
 *
 * The three floating surfaces are told apart by **what opens them and what you
 * can do once they are open**, not by how they look:
 *
 * - A [PlTooltip](./tooltip) names the thing under the pointer. One phrase, and
 *   nothing inside it can be reached.
 * - A **hover card** previews what is behind it. It opens on its own, it can be
 *   entered with the pointer, and it holds a title, a picture, a figure.
 * - A [PlPopover](./popover) was asked for. It stays until it is dismissed, and
 *   it can be typed into.
 *
 * **Nothing may live only in here.** A card that opens on hover does not open
 * for a finger, so a link, a button or a fact that exists nowhere else on the
 * page is a link, a button or a fact that half the readers never get. Everything
 * in it is a preview of something already reachable — which is what makes it
 * safe to have at all.
 *
 * The delays are the component. `delay` is long so the card does not fire at
 * every link a pointer crosses on the way somewhere else, and `closeDelay` is
 * not zero because the gap between the trigger and the card has no pointer in
 * it — a card that closed the moment the pointer left could never be reached.
 *
 * Base UI owns the anchoring, the flip at the window edge, the two delays, the
 * dismissal and the `aria-describedby` wiring. What is left here is the surface.
 */
export function PlHoverCard({
  size: sizeProp,
  color: colorProp,
  density: densityProp,
  trigger,
  title,
  description,
  children,
  side = 'bottom',
  align = 'center',
  sideOffset = 8,
  alignOffset = 0,
  delay = 600,
  closeDelay = 300,
  arrow = false,
  open,
  defaultOpen,
  onOpenChange,
  width,
  className,
  style,
  ...props
}: PlHoverCardProps) {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';

  const arrowSize = arrowSizes[size];
  const hasHeader = hasContent(title) || hasContent(description);

  return (
    <PreviewCard.Root
      open={open}
      defaultOpen={defaultOpen}
      onOpenChange={(next) => onOpenChange?.(next)}
    >
      <PreviewCard.Trigger delay={delay} closeDelay={closeDelay} render={trigger} />

      <PreviewCard.Portal>
        {/* `plass-portal` is a hook, not a style: a portalled popup leaves the
            subtree a host may have scoped its CSS reset to. */}
        <PreviewCard.Positioner
          className="plass-portal z-(--plass-z-portal) [outline:none]"
          side={side}
          align={align}
          sideOffset={sideOffset}
          alignOffset={alignOffset}
        >
          <PreviewCard.Popup
            className={cx(
              popupClasses,
              radiusClasses[size],
              sheetBodyClasses[size],
              sheetSectionGapClasses[size],
              sheetPaddingXClasses[density][size],
              sheetPaddingYClasses[density][size],
              width === undefined ? maxWidthClasses[size] : '',
              className
            )}
            style={{
              ...surfaceSlots(color, 3),
              ...(width === undefined
                ? null
                : { maxWidth: typeof width === 'number' ? `${width}px` : width }),
              ...style
            }}
            {...props}
          >
            {arrow ? (
              <PreviewCard.Arrow
                // Base UI positions the wedge and reports which side it ended up
                // on. It is drawn pointing down once and turned to match — a
                // rotation of a glyph, which is the one allowance the
                // no-transform rule makes.
                className={cx(
                  'data-[side=top]:bottom-[-1px]',
                  'data-[side=bottom]:top-[-1px] data-[side=bottom]:rotate-180',
                  'data-[side=left]:right-[-1px] data-[side=left]:-rotate-90',
                  'data-[side=right]:left-[-1px] data-[side=right]:rotate-90'
                )}
              >
                <svg
                  width={arrowSize}
                  height={arrowSize / 2}
                  viewBox="0 0 10 5"
                  aria-hidden="true"
                  className="block"
                >
                  <path d="M0 0h10L5 5z" fill="var(--plass-glass-press)" />
                  {/* Only the two slanted sides, so the wedge continues the
                      sheet's hairline instead of drawing a line across the edge
                      it is growing out of. */}
                  <path
                    d="M0 0 5 5 10 0"
                    fill="none"
                    stroke="var(--plass-glass-line)"
                    strokeWidth="1"
                    vectorEffect="non-scaling-stroke"
                  />
                </svg>
              </PreviewCard.Arrow>
            ) : null}

            {hasHeader ? (
              <div className={cx('flex min-w-0 flex-col', sheetHeaderGapClasses[size])}>
                {hasContent(title) ? (
                  <div className={cx('m-0 font-semibold', sheetTitleClasses[size])}>{title}</div>
                ) : null}
                {hasContent(description) ? (
                  <div className={cx('m-0 text-(--plass-muted-fg)', metaTextClasses[size])}>
                    {description}
                  </div>
                ) : null}
              </div>
            ) : null}

            {hasContent(children) ? <div className="min-w-0">{children}</div> : null}
          </PreviewCard.Popup>
        </PreviewCard.Positioner>
      </PreviewCard.Portal>
    </PreviewCard.Root>
  );
}
