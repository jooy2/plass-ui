import * as React from 'react';
import { Tooltip as BaseUITooltip } from '@base-ui/react/tooltip';
import {
  glassClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  surfaceSlots
} from '../../internal/styles.js';
import type { PlassAlign, PlassSide, PlassSize, PlassStyleProps } from '../../types.js';

export interface PlTooltipProps
  extends
    Pick<PlassStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'content' | 'children'> {
  /**
   * What the tooltip says.
   *
   * A short phrase. A tooltip is not a container — it cannot be reached by a
   * pointer on a touch screen, it disappears the moment attention moves, and
   * anything inside it that could be clicked cannot be. Content that needs
   * either of those belongs in a sheet that stays put.
   */
  content: React.ReactNode;
  /**
   * The element the tooltip hangs off. Exactly one element, which must accept a
   * ref and spread props — every Plass component does.
   */
  children: React.ReactElement;
  /**
   * Which edge of the trigger it appears on. May flip to the opposite side when
   * there is no room, which is Base UI's doing and is the right behaviour.
   * @default 'top'
   */
  side?: PlassSide;
  /**
   * Where it sits along that edge.
   * @default 'center'
   */
  align?: PlassAlign;
  /**
   * Distance from the trigger, in pixels.
   * @default 6
   */
  sideOffset?: number;
  /**
   * How long the pointer has to rest before it opens, in milliseconds.
   * @default 600
   */
  delay?: number;
  /**
   * How long it waits before closing once the pointer leaves.
   * @default 0
   */
  closeDelay?: number;
  /**
   * Draws the little wedge pointing at the trigger.
   * @default true
   */
  arrow?: boolean;
  /** Whether the tooltip is open. Use with `onOpenChange` for a controlled one. */
  open?: boolean;
  /** Whether it starts open, for an uncontrolled one. */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * Stops the tooltip from opening at all, without disabling the trigger. For
   * the tooltip that only exists while a label is truncated.
   * @default false
   */
  disabled?: boolean;
}

/**
 * Shares one delay across a group of tooltips: once any of them has opened, its
 * neighbours open instantly, and the wait comes back after a pause.
 *
 * Worth wrapping a toolbar in. Without it, moving along a row of icon buttons
 * means waiting out the full delay at every stop, which is what makes tooltips
 * feel like they are fighting the pointer.
 */
export const PlTooltipProvider = BaseUITooltip.Provider;

export type PlTooltipProviderProps = React.ComponentProps<typeof BaseUITooltip.Provider>;

/**
 * The plate, and it is the same floating sheet a `PlSelect`'s popup is: the
 * glass at its most opaque, a white hairline round it, shadow 3 under it.
 *
 * Not a filled key, which is what most libraries draw a tooltip as. A tooltip is
 * a note *about* something rather than a thing to press, and the library already
 * has one answer for a surface that floats over arbitrary content — inventing a
 * second would put two kinds of floating sheet on the same screen.
 *
 * `--plass-glass-press` is what makes that safe: at its most opaque the sheet is
 * dense enough to read a line of text off, which the 62% pane is not.
 */
const popupClasses = [
  glassClasses,
  'max-w-64 border text-(--plass-fg) bg-(--plass-glass-press)',
  '[border-color:var(--plass-glass-line)]',
  '[box-shadow:var(--plass-shadow-3),var(--plass-gloss-glass)]',
  '[outline:none]',
  // Opacity only, and fast: a tooltip that slides in has moved its own text
  // while the reader was already looking at it.
  '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0',
  // Base UI sets this while the pointer is moving between grouped tooltips.
  // Fading in a tooltip that is meant to appear instantly is worse than not
  // fading at all — it reads as lag.
  'data-[instant]:[transition-duration:0ms]'
].join(' ');

/** A row's vertical padding, against the horizontal track `paddingXClasses` sets. */
const paddingYClasses: Record<PlassSize, string> = {
  xs: 'py-0.5',
  sm: 'py-0.5',
  md: 'py-1',
  lg: 'py-1.5',
  xl: 'py-2'
};

/** The wedge, at roughly a third of the plate's corner radius per step. */
const arrowSizes: Record<PlassSize, number> = {
  xs: 6,
  sm: 7,
  md: 8,
  lg: 9,
  xl: 10
};

/**
 * A short label that appears when the pointer rests on something.
 *
 * The whole component is a wrapper:
 * `<PlTooltip content="Copy"><PlButton …/></PlTooltip>`. Base UI's Trigger
 * merges itself onto the child rather than rendering a box of its own, so the
 * tooltip adds no element to the layout and the child stays whatever it was — a
 * button, a chip, a truncated cell.
 *
 * Base UI owns the parts that are genuinely hard: the delay and the group
 * timeout, opening on focus but not on a focus that came from a click, closing
 * on Escape, and keeping the popup off the edges of the window.
 *
 * The one thing it deliberately leaves open is the part that makes a tooltip
 * mean anything to a screen reader — `role="tooltip"` on the plate and an
 * `aria-describedby` pointing at it from the trigger — because a popup can be
 * many things and only the caller knows which. Here it is always a tooltip, so
 * this component wires both, and drops the reference while it is closed rather
 * than pointing at an element that is not in the document.
 */
export function PlTooltip({
  content,
  children,
  size = 'sm',
  // A tooltip is a note about something else, never the thing itself, so the
  // neutral family is the honest default. A red tooltip on a delete button would
  // be saying something the tooltip does not know.
  color = 'secondary',
  density = 'default',
  side = 'top',
  align = 'center',
  sideOffset = 6,
  delay,
  closeDelay,
  arrow = true,
  open,
  defaultOpen,
  onOpenChange,
  disabled = false,
  className,
  style,
  ...props
}: PlTooltipProps) {
  const arrowSize = arrowSizes[size];
  const popupId = React.useId();

  // Mirrored rather than owned: `open` still drives a controlled tooltip and
  // Base UI still drives an uncontrolled one. This copy exists only so the
  // trigger knows whether the plate it describes is on the page yet.
  const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen ?? false);
  const isOpen = open ?? uncontrolledOpen;

  return (
    <BaseUITooltip.Root
      open={open}
      defaultOpen={defaultOpen}
      onOpenChange={(next) => {
        setUncontrolledOpen(next);
        onOpenChange?.(next);
      }}
    >
      <BaseUITooltip.Trigger
        render={children}
        delay={delay}
        closeDelay={closeDelay}
        disabled={disabled}
        aria-describedby={isOpen ? popupId : undefined}
      />

      <BaseUITooltip.Portal>
        {/* `plass-portal` is a hook, not a style: a portalled popup leaves the
            subtree a host may have scoped its CSS reset to. */}
        <BaseUITooltip.Positioner
          className="plass-portal z-50 [outline:none]"
          side={side}
          align={align}
          sideOffset={sideOffset}
        >
          <BaseUITooltip.Popup
            id={popupId}
            role="tooltip"
            className={[
              popupClasses,
              radiusClasses[size],
              paddingXClasses[density][size],
              paddingYClasses[size],
              metaTextClasses[size],
              className ?? ''
            ]
              .filter(Boolean)
              .join(' ')}
            style={{ ...surfaceSlots(color, 3), ...style }}
            {...props}
          >
            {arrow ? (
              <BaseUITooltip.Arrow
                // Base UI positions the arrow and reports which side it ended up
                // on. The wedge is drawn pointing down and turned to match — a
                // rotation of a glyph, which is the same allowance the chevron
                // takes. Nothing with text in it moves.
                className={[
                  'data-[side=top]:bottom-[-1px]',
                  'data-[side=bottom]:top-[-1px] data-[side=bottom]:rotate-180',
                  'data-[side=left]:right-[-1px] data-[side=left]:-rotate-90',
                  'data-[side=right]:left-[-1px] data-[side=right]:rotate-90'
                ].join(' ')}
              >
                {/* The wedge is drawn twice: the hairline first, then the fill
                    over it a pixel down. A single filled triangle would leave
                    the plate's own edge running straight across the base of the
                    arrow, which is a sheet with a notch rather than a sheet with
                    a point. */}
                <svg
                  width={arrowSize}
                  height={arrowSize / 2}
                  viewBox="0 0 10 5"
                  aria-hidden="true"
                  className="block"
                >
                  <path d="M0 0h10L5 5z" fill="var(--plass-glass-line)" />
                  <path
                    d="M0 0h10L5 5z"
                    fill="var(--plass-glass-press)"
                    transform="translate(0 -1)"
                  />
                </svg>
              </BaseUITooltip.Arrow>
            ) : null}
            {content}
          </BaseUITooltip.Popup>
        </BaseUITooltip.Positioner>
      </BaseUITooltip.Portal>
    </BaseUITooltip.Root>
  );
}
