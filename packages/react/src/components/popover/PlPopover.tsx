'use client';

import * as React from 'react';
import { Popover as BaseUIPopover } from '@base-ui/react/popover';
import { CloseIcon } from '../../internal/icons.js';
import {
  cx,
  focusRingClasses,
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
 * A popover takes `size`, `color` and `density` and stops there.
 *
 * There is no `variant`, for `PlMenu`'s reason: the three materials answer "how
 * much does this surface assert itself against the page", and a popup that had
 * to be asked for has already answered it. There is no `elevation` either — a
 * popover genuinely floats, which is the one case the ladder exists for, so it
 * is fixed at its top rung.
 */
export interface PlPopoverProps
  extends
    Pick<PlassStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title' | 'children'> {
  /**
   * The element the popup hangs off and that opens it. Exactly one element,
   * which must accept a ref and spread props — every Plass component does.
   *
   * Optional: a controlled popover anchored from elsewhere needs none, though it
   * then has nothing to position against and will sit against the viewport.
   */
  trigger?: React.ReactElement;
  /** The heading, rendered as the element that names the popup. */
  title?: React.ReactNode;
  /** A line under the title, and the popup's accessible description. */
  description?: React.ReactNode;
  /** The body. */
  children?: React.ReactNode;
  /**
   * Which edge of the trigger it appears on. Flips to the opposite side when
   * there is no room, which is Base UI's doing and is the right behaviour.
   * @default 'bottom'
   */
  side?: PlassSide;
  /** Where it sits along that edge. @default 'center' */
  align?: PlassAlign;
  /** Distance from the trigger, in pixels. @default 6 */
  sideOffset?: number;
  /** Shift along that edge, in pixels. @default 0 */
  alignOffset?: number;
  /**
   * Draws the little wedge pointing at the trigger.
   *
   * Off by default, unlike on a `PlTooltip`. A tooltip is a filled plate and its
   * wedge is the same solid colour; this surface is translucent over a blurred
   * backdrop, and a wedge sticking out past the popup's own box cannot carry
   * that backdrop with it. Turn it on where the trigger is far enough away that
   * the popup needs to say what it belongs to.
   * @default false
   */
  arrow?: boolean;
  /** Whether the popover is open. Use with `onOpenChange` for a controlled one. */
  open?: boolean;
  /** Whether it starts open, for an uncontrolled one. */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * Whether the page behind is taken away. `false` — the default — leaves the
   * page scrollable and clickable, which is what separates a popover from a
   * `PlModal`: it is a detail beside the page, not instead of it.
   * `'trap-focus'` holds focus inside without locking the scroll.
   * @default false
   */
  modal?: boolean | 'trap-focus';
  /**
   * Whether pressing Escape or clicking outside closes the popup. Turn it off
   * only for a popup with its own way out, because there will be no other.
   * @default true
   */
  dismissible?: boolean;
  /** Shows the × in the corner. @default false */
  showClose?: boolean;
  /** Accessible name of the × button. Never drawn. @default 'Close' */
  closeLabel?: string;
  /**
   * A hard cap on the popup's width, overriding the one `size` implies. Numbers
   * are pixels. For the popover whose content decides its width — a form, a
   * single line of help — rather than for tuning the scale, which is `size`.
   */
  width?: number | string;
}

export type PlPopoverCloseProps = React.ComponentPropsWithoutRef<typeof BaseUIPopover.Close>;

/**
 * How wide the popup is allowed to get, per `size` — the same axis `PlModal`
 * folds its width into, one rung narrower at every step because a popover is a
 * detail beside a control rather than a sheet in the middle of the page.
 */
const maxWidthClasses: Record<PlassSize, string> = {
  xs: 'max-w-56',
  sm: 'max-w-64',
  md: 'max-w-80',
  lg: 'max-w-96',
  xl: 'max-w-lg'
};

/**
 * The sheet. The same frosted panel a `PlSelect` popup and a `PlModal` draw, and
 * for the same reason it carries the top of the shadow ladder: it is one of the
 * few surfaces in the library that is genuinely meant to float.
 */
const popupClasses = /* @__PURE__ */ [
  glassClasses,
  'relative flex flex-col',
  'border text-(--plass-fg) bg-(--plass-glass-press)',
  '[border-color:var(--plass-glass-line)]',
  '[box-shadow:var(--plass-shadow-3),var(--plass-gloss-glass)]',
  '[outline:none]',
  // Opacity only. A popup that scales or slides in drags its own text across the
  // screen for the length of the transition, which is the one thing the house
  // style is against — and unlike a control, this one is full of text.
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

/** The × in the corner, the same one a `PlModal` draws. */
const closeButtonClasses = /* @__PURE__ */ [
  'flex size-[1.6em] shrink-0 cursor-pointer items-center justify-center',
  'rounded-full text-(--plass-muted-fg)',
  '[&_svg]:size-[1.1em] [&_svg]:shrink-0',
  '[transition:background-color_var(--plass-duration)_var(--plass-ease),color_var(--plass-duration)_var(--plass-ease)]',
  'hover:bg-(--p-soft) hover:text-(--plass-fg)',
  focusRingClasses
].join(' ');

/**
 * Closes the popover it is inside.
 *
 * Exported for `PlModalClose`'s reason: an uncontrolled popover has no `setOpen`
 * for its Cancel button to call, and making every popover controlled is a piece
 * of state per popover that exists only to answer a button.
 *
 * `render` is Base UI's own escape hatch, so a real Plass button dismisses:
 * `<PlPopoverClose render={<PlButton variant="ghost">Cancel</PlButton>} />`.
 */
export const PlPopoverClose = BaseUIPopover.Close;

/**
 * A sheet that opens beside the thing that opened it.
 *
 * The difference from a `PlTooltip` is that this one can be **reached**: it
 * stays up until it is dismissed, it can be entered with the pointer or the
 * keyboard, and what is inside it can be clicked and typed into. The difference
 * from a `PlModal` is that it does not take the page — it is anchored to a
 * control, and the page behind goes on working.
 *
 * Base UI owns everything hard about it: the anchoring and the flip at the
 * window edge, the click-outside and Escape, returning focus to the trigger, and
 * the `aria-labelledby` / `aria-describedby` wiring. What is left here is the
 * surface, the width ladder and the header.
 */
export function PlPopover({
  size = 'md',
  color = 'primary',
  density = 'default',
  trigger,
  title,
  description,
  children,
  side = 'bottom',
  align = 'center',
  sideOffset = 6,
  alignOffset = 0,
  arrow = false,
  open,
  defaultOpen,
  onOpenChange,
  modal = false,
  dismissible = true,
  showClose = false,
  closeLabel = 'Close',
  width,
  className,
  style,
  ...props
}: PlPopoverProps) {
  const insetX = sheetPaddingXClasses[density][size];
  const insetY = sheetPaddingYClasses[density][size];
  const arrowSize = arrowSizes[size];

  const hasHeader = hasContent(title) || hasContent(description);

  return (
    <BaseUIPopover.Root
      open={open}
      defaultOpen={defaultOpen}
      modal={modal}
      onOpenChange={(next, details) => {
        // Base UI has no `disablePointerDismissal` on a popover, so both ways
        // out are cancelled here by the reason the change arrives with. An
        // imperative close and a `PlPopoverClose` press still get through, which
        // is what keeps `dismissible={false}` from being a trap.
        if (
          !dismissible &&
          !next &&
          (details.reason === 'escape-key' ||
            details.reason === 'outside-press' ||
            details.reason === 'focus-out')
        ) {
          details.cancel();

          return;
        }

        onOpenChange?.(next);
      }}
    >
      {trigger ? <BaseUIPopover.Trigger render={trigger} /> : null}

      <BaseUIPopover.Portal>
        {/* `plass-portal` is a hook, not a style: a portalled popup leaves the
            subtree a host may have scoped its CSS reset to. */}
        <BaseUIPopover.Positioner
          className="plass-portal z-(--plass-z-portal) [outline:none]"
          side={side}
          align={align}
          sideOffset={sideOffset}
          alignOffset={alignOffset}
        >
          <BaseUIPopover.Popup
            className={cx(
              popupClasses,
              radiusClasses[size],
              sheetBodyClasses[size],
              sheetSectionGapClasses[size],
              insetX,
              insetY,
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
              <BaseUIPopover.Arrow
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
              </BaseUIPopover.Arrow>
            ) : null}

            {hasHeader || showClose ? (
              <div className="flex shrink-0 items-start gap-3">
                <div className={cx('flex min-w-0 flex-1 flex-col', sheetHeaderGapClasses[size])}>
                  {hasContent(title) ? (
                    <BaseUIPopover.Title
                      className={cx('m-0 font-semibold', sheetTitleClasses[size])}
                    >
                      {title}
                    </BaseUIPopover.Title>
                  ) : null}
                  {hasContent(description) ? (
                    <BaseUIPopover.Description
                      className={cx('m-0 text-(--plass-muted-fg)', metaTextClasses[size])}
                    >
                      {description}
                    </BaseUIPopover.Description>
                  ) : null}
                </div>

                {showClose ? (
                  <BaseUIPopover.Close aria-label={closeLabel} className={closeButtonClasses}>
                    <CloseIcon />
                  </BaseUIPopover.Close>
                ) : null}
              </div>
            ) : null}

            {hasContent(children) ? <div className="min-w-0">{children}</div> : null}
          </BaseUIPopover.Popup>
        </BaseUIPopover.Positioner>
      </BaseUIPopover.Portal>
    </BaseUIPopover.Root>
  );
}
