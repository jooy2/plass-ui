import * as React from 'react';
import { CloseIcon } from '../../internal/icons.js';
import {
  controlHeightClasses,
  controlSlots,
  controlTextClasses,
  disabledClasses,
  focusRingClasses,
  gapClasses,
  glassClasses,
  hasContent,
  iconClasses,
  paddingXClasses,
  radiusClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassElevation, PlassSize, PlassStyleProps, PlassVariant } from '../../types.js';

export interface PlChipProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'span'>, 'color'> {
  /**
   * Drop shadow depth. `0` is the default — a chip is a token sitting *on*
   * something else, so it is raised even less often than a `PlButton`.
   * @default 0
   */
  elevation?: PlassElevation;
  /** Content placed before the label — an icon, a status dot, an avatar. */
  startIcon?: React.ReactNode;
  /** Content placed after the label, before any `count`. */
  endIcon?: React.ReactNode;
  /**
   * A number set into the end of the chip. Drawn on its own small plate, so
   * "Errors 12" reads as one token with a count rather than as two words.
   */
  count?: React.ReactNode;
  /**
   * Called when the chip's delete affordance is pressed. Passing it is what
   * makes the affordance appear.
   */
  onDelete?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  /**
   * Accessible name of the delete button. Never drawn.
   * @default 'Remove'
   */
  deleteLabel?: string;
  /**
   * Marks the chip as chosen — a filter that is on.
   *
   * It moves the chip one step up the ladder its own variant already sits on,
   * rather than changing the colour family, so a row of chips stays one row of
   * chips.
   * @default false
   */
  selected?: boolean;
  /** Unavailable. The light goes out, the same way it does everywhere else. */
  disabled?: boolean;
  children?: React.ReactNode;
}

/**
 * A chip sits one step down the control ladder from everything else: a `md` chip
 * is a `sm` control — 32px, not 40px.
 *
 * This is the whole size difference between a chip and a button, and it is
 * deliberate. A chip is a token *inside* a row of content, not a control the row
 * lines up against; at full control height a `glass` chip and a `glass` button
 * are the same object, and a screen full of them says nothing about which one
 * can be pressed.
 *
 * Shifting the index rather than inventing a second set of numbers keeps a chip
 * inside the same five-step vocabulary, and keeps `xs` from falling off the
 * bottom of it.
 */
const chipScale: Record<PlassSize, PlassSize> = {
  xs: 'xs',
  sm: 'xs',
  md: 'sm',
  lg: 'md',
  xl: 'lg'
};

/**
 * The three materials. A chip **is** the thing being coloured — a tag names one
 * particular thing — so unlike a `PlCard` its sheet takes the tint.
 *
 * `glass` is the default rather than `solid`: a filter bar is a row of chips,
 * and a row of gradient keys is a row in which nothing is the primary action
 * because everything is.
 */
const restClasses: Record<PlassVariant, string> = {
  solid: 'text-(--p-on-solid) [background-image:var(--p-fill)] [box-shadow:var(--p-elev)]',
  glass: [
    glassClasses,
    'border text-(--p-accent) bg-(--plass-glass)',
    '[border-color:var(--plass-glass-line)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: 'text-(--p-accent) bg-(--p-soft)'
};

/**
 * Chosen is one step further up the ladder the chip is already on — the sheet
 * holds more light. Deliberately not a different colour family: a filter that is
 * on is still the same filter.
 *
 * `solid` has no opacity ladder to climb, because a gradient fill is the fill.
 * So it answers the other way the design language allows: it casts its own
 * colour onto the sheet under it. A chosen key lifts; an unchosen one lies flat.
 */
const selectedClasses: Record<PlassVariant, string> = {
  solid: '[box-shadow:var(--p-elev),var(--p-lift)]',
  glass: 'bg-(--plass-glass-press) [border-color:var(--p-line-hover)]',
  ghost: 'bg-(--p-soft-press)'
};

/**
 * Only a chip that can be pressed answers the pointer, and it answers the way
 * every other control does: `brightness()` on the gradient, a step up the
 * opacity ladder on the other two.
 */
const hoverClasses: Record<PlassVariant, string> = {
  solid: 'hover:brightness-105 active:brightness-95',
  glass:
    'hover:bg-(--plass-glass-hover) hover:[border-color:var(--p-line)] active:bg-(--plass-glass-press)',
  ghost: 'hover:bg-(--p-soft-hover) active:bg-(--p-soft-press)'
};

const baseClasses = [
  // `items-center`, not `items-stretch`: everything in a chip — the icon, the
  // label, the count plate, the × — is centred on one line. The pressable label
  // asks for the height it needs with `self-stretch` instead, so making the
  // shell stretch to suit it would knock every other child off the centre line.
  'relative inline-flex max-w-full shrink-0 items-center select-none',
  'align-middle leading-none font-medium whitespace-nowrap',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  iconClasses
].join(' ');

/**
 * The label, when the chip is pressable, is its own `<button>` inside the shell
 * rather than the shell itself.
 *
 * That looks like indirection and is not: a chip can carry a delete affordance,
 * which has to be a button too, and a `<button>` inside a `<button>` is invalid
 * HTML that browsers un-nest on parse. Keeping the shell a `<span>` is what lets
 * "activate this chip" and "remove this chip" both be real, focusable buttons.
 *
 * `self-stretch` so its hit area is the full height of the chip rather than the
 * height of the words, and `rounded-[inherit]` so the focus ring traces the
 * shell's corners rather than drawing a second, squarer rectangle inside them.
 */
const labelButtonClasses = [
  'flex min-w-0 flex-1 cursor-pointer items-center justify-center self-stretch rounded-[inherit]',
  focusRingClasses
].join(' ');

/** The ×, kept quiet until it is wanted. */
const removeButtonClasses = [
  'ms-0.5 inline-flex shrink-0 items-center justify-center rounded-full',
  'size-[1.15em] cursor-pointer opacity-70',
  '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
  'hover:opacity-100 focus-visible:opacity-100',
  focusRingClasses,
  'disabled:cursor-not-allowed'
].join(' ');

/**
 * A compact token: a tag, a filter, a status, an entity plucked out of a list.
 *
 * The shell is always a `<span>`. What changes is what is inside it: a plain run
 * of content, or — when `onClick` is given — a real `<button>` wrapping that
 * content, plus a second button for `onDelete`. Both are reachable by keyboard,
 * and neither is nested inside the other.
 *
 * An inert `<span>` carrying a click handler is the single most common way a
 * component library loses its keyboard users, and a `<button>` inside a
 * `<button>` is the most common way it invents a chip that Chrome silently
 * rewrites. This shape is what avoids both.
 */
export const PlChip = React.forwardRef<HTMLSpanElement, PlChipProps>(function PlChip(
  {
    variant = 'glass',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    startIcon,
    endIcon,
    count,
    onDelete,
    deleteLabel = 'Remove',
    selected = false,
    disabled = false,
    className,
    style,
    children,
    onClick,
    ...props
  },
  ref
) {
  const interactive = Boolean(onClick) && !disabled;
  const step = chipScale[size];
  const padX = paddingXClasses[density][step];

  const shellClasses = [
    baseClasses,
    controlHeightClasses[step],
    controlTextClasses[step],
    gapClasses[step],
    radiusClasses[step],
    // An if/else rather than stacked variants: two Tailwind classes of equal
    // specificity resolve by their order in the generated stylesheet.
    disabled ? disabledClasses[variant] : restClasses[variant],
    !disabled && selected ? selectedClasses[variant] : '',
    interactive ? hoverClasses[variant] : '',
    // With a pressable label the padding belongs to the button, so its hit area
    // covers the whole chip rather than just the words.
    interactive ? 'ps-0' : padX,
    // The delete button brings its own padding; stacking the chip's on top of it
    // would leave the × floating in the middle of a gap.
    onDelete ? 'pe-1' : interactive ? 'pe-0' : '',
    className ?? ''
  ]
    .filter(Boolean)
    .join(' ');

  const label = (
    <>
      {startIcon}
      {hasContent(children) ? <span className="min-w-0 truncate">{children}</span> : null}
      {endIcon}
      {hasContent(count) ? (
        <span
          className={[
            'ms-0.5 inline-flex shrink-0 items-center justify-center rounded-full px-1.5 py-px',
            'text-[0.85em] leading-none font-semibold tabular-nums',
            // On a filled chip the plate is light let through the fill; on a
            // tinted or a bare one it is the accent showing under the words.
            variant === 'solid'
              ? 'bg-(--plass-glow-on-fill) text-(--p-on-solid)'
              : 'bg-(--p-soft-press) text-(--p-accent)'
          ].join(' ')}
        >
          {count}
        </span>
      ) : null}
    </>
  );

  return (
    <span
      ref={ref}
      className={shellClasses}
      style={{ ...controlSlots(color, elevation, variant), ...style }}
      aria-disabled={disabled && !interactive ? true : undefined}
      {...props}
    >
      {interactive ? (
        <button
          type="button"
          aria-pressed={selected}
          className={`${labelButtonClasses} ${gapClasses[step]} ${padX}`}
          onClick={onClick as React.MouseEventHandler<HTMLButtonElement>}
        >
          {label}
        </button>
      ) : (
        label
      )}

      {onDelete ? (
        <button
          type="button"
          aria-label={deleteLabel}
          disabled={disabled}
          className={removeButtonClasses}
          onClick={onDelete}
        >
          <CloseIcon />
        </button>
      ) : null}
    </span>
  );
});
