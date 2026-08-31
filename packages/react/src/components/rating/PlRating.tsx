'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { StarIcon, StarOutlineIcon } from '../../internal/icons.js';
import {
  controlSlots,
  cx,
  focusWithinRingClasses,
  gapClasses,
  iconSizeClasses,
  radiusClasses,
  srOnlyClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassSize } from '../../types.js';

export interface PlRatingProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'defaultValue' | 'onChange'
> {
  /** How much is rated. Use with `onValueChange` for a controlled rating. */
  value?: number;
  /** Where an uncontrolled rating starts. @default 0 */
  defaultValue?: number;
  /** Called with the new score. `0` is what a cleared rating reports. */
  onValueChange?: (value: number) => void;
  /** How many stars there are, and therefore the highest score. @default 5 */
  count?: number;
  /**
   * The smallest step that can be *chosen*, as a fraction of one star — `0.5`
   * gives half stars, `1` whole ones. Anything outside `0 < precision <= 1`
   * falls back to `1`.
   *
   * It bounds what a reader can pick and nothing else: a `value` of `4.3` is
   * drawn as four stars and a third at every precision, because an average is
   * not a choice and rounding it to the nearest half would be reporting a
   * different number from the one the component was handed.
   * @default 1
   */
  precision?: number;
  /** The glyph a filled star is drawn with. */
  icon?: React.ReactNode;
  /** And the one an empty star is drawn with. Has to be the same shape. */
  emptyIcon?: React.ReactNode;
  /** Choosing the score that is already chosen clears it back to `0`. @default true */
  clearable?: boolean;
  /**
   * Shows the score without letting it be changed — a product's average, a
   * rating somebody else left.
   *
   * This is the one `readOnly` in the library that does **not** drain the
   * saturation, because it is not a control being held still: there are no
   * inputs at all, and what is left is a picture of a number. A row of grey
   * stars would say the score itself was unavailable.
   * @default false
   */
  readOnly?: boolean;
  /** Unavailable. The light goes out of the whole row. */
  disabled?: boolean;
  /** Identifies the value when a form is submitted. */
  name?: string;
  /** A form will not submit until a star has been chosen. */
  required?: boolean;
  /** Height of one star, on the standalone-glyph ladder. @default 'md' */
  size?: PlassSize;
  /**
   * Semantic colour role.
   *
   * `warning` by default — the amber a star is expected to be — rather than the
   * `primary` everything else takes. It is the one place in the library where a
   * component's default colour is chosen by what the object *is* instead of by
   * what it means.
   * @default 'warning'
   */
  color?: PlassColor;
  /** Names the whole control. @default 'Rating' */
  label?: string;
  /**
   * What one star, and the whole control once it is read only, is called.
   * @default `{value} out of {count}`
   */
  valueLabel?: (value: number, count: number) => string;
}

/**
 * The box one copy of the glyph is drawn in. Both copies get exactly this, or
 * the clipped one would not line up with the outline underneath it.
 */
const starClasses = 'flex items-center justify-center';

/** The default accessible name of a score. */
function defaultValueLabel(value: number, count: number): string {
  return value <= 0 ? 'No rating' : `${value} out of ${count}`;
}

/**
 * A score out of five, as a row of stars.
 *
 * Underneath an interactive rating is a radio group of real `<input>`s, one per
 * choosable score, each visually hidden under the fraction of a star it stands
 * for. That is the whole accessibility argument: a rating *is* "exactly one of
 * these", so it gets one tab stop for the row, arrow keys within it,
 * `aria-checked` on the one that is taken, and a value in a form submission —
 * none of which a row of `<button>`s or a `<div>` with a click handler would
 * have.
 *
 * The fraction is drawn by laying the filled star over the empty one and
 * clipping it to a percentage of the width. Nothing is transformed and no glyph
 * is scaled, so a half star is the left half of exactly the star beside it —
 * which is also the no-transform rule holding on a component whose whole job is
 * a partial shape. The clip runs from the inline start, so it fills from the
 * right under RTL without anything being told to.
 *
 * `readOnly` is a different component in the same clothes: no inputs, no radio
 * group, and one `role="img"` carrying the score as a sentence. A star display
 * that kept twenty focusable radios would be twenty tab stops on a page that
 * was only reporting a number.
 */
export const PlRating = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlRatingProps>(
  function PlRating(
    {
      value: valueProp,
      defaultValue = 0,
      onValueChange,
      count = 5,
      precision = 1,
      icon,
      emptyIcon,
      clearable = true,
      readOnly = false,
      disabled = false,
      name: nameProp,
      required = false,
      size: sizeProp,
      color: colorProp,
      label = 'Rating',
      valueLabel = defaultValueLabel,
      className,
      style,
      onPointerLeave,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'warning';

    const generatedName = React.useId();
    const name = nameProp ?? generatedName;

    const [uncontrolled, setUncontrolled] = React.useState(defaultValue);
    const controlled = valueProp !== undefined;
    const value = controlled ? valueProp : uncontrolled;

    // What the pointer is currently promising, which is not the value until it is
    // clicked. `null` is "the pointer is not on the row", not "zero stars".
    const [hovered, setHovered] = React.useState<number | null>(null);

    const stars = Math.max(1, Math.floor(count));
    const step = precision > 0 && precision <= 1 ? precision : 1;
    const stepsPerStar = Math.round(1 / step);

    const shown = Math.max(0, Math.min(stars, hovered ?? value));

    const change = (next: number) => {
      if (!controlled) {
        setUncontrolled(next);
      }

      onValueChange?.(next);
    };

    const marks = Array.from({ length: stars }, (_, index) => {
      // How much of *this* star is filled, from 0 to 1.
      const fill = Math.max(0, Math.min(1, shown - index));

      return (
        <span
          key={index}
          className={cx(
            'relative inline-flex shrink-0',
            iconSizeClasses[size],
            radiusClasses.xs,
            readOnly || disabled ? '' : focusWithinRingClasses
          )}
        >
          <span className={cx(starClasses, iconSizeClasses[size], 'text-(--p-empty)')}>
            {emptyIcon ?? <StarOutlineIcon />}
          </span>

          {/*
           * The filled copy, clipped to the fraction. `inset-inline-start` and a
           * width, rather than a `clip-path` with a percentage in it, because the
           * inner star has to keep its own full width or the glyph would be
           * squashed into the visible part instead of cropped by it.
           */}
          <span
            aria-hidden="true"
            className="pointer-events-none absolute inset-y-0 start-0 overflow-hidden"
            style={{ width: `${fill * 100}%` }}
          >
            <span
              className={cx(
                starClasses,
                iconSizeClasses[size],
                'text-(--p-accent)',
                transitionClasses
              )}
            >
              {icon ?? <StarIcon />}
            </span>
          </span>

          {readOnly
            ? null
            : Array.from({ length: stepsPerStar }, (_, part) => {
                const score = Number((index + (part + 1) * step).toFixed(4));

                return (
                  <label
                    key={score}
                    className={cx(
                      'absolute inset-y-0',
                      disabled ? 'cursor-not-allowed' : 'cursor-pointer'
                    )}
                    style={{
                      insetInlineStart: `${(part * 100) / stepsPerStar}%`,
                      width: `${100 / stepsPerStar}%`
                    }}
                    onPointerEnter={() => {
                      if (!disabled) {
                        setHovered(score);
                      }
                    }}
                  >
                    <input
                      type="radio"
                      className={srOnlyClasses}
                      name={name}
                      value={score}
                      checked={value === score}
                      disabled={disabled}
                      required={required}
                      aria-label={valueLabel(score, stars)}
                      onChange={() => change(score)}
                      // Clearing cannot ride on `change`: clicking a radio that is
                      // already checked fires a click and no change at all, and
                      // that click is exactly the gesture being listened for.
                      onClick={() => {
                        if (clearable && value === score) {
                          change(0);
                        }
                      }}
                    />
                  </label>
                );
              })}
        </span>
      );
    });

    const classNames = cx(
      'inline-flex items-center align-middle',
      gapClasses[size],
      // The house treatment, not a grey token: the light goes out of the row and
      // the page shows through it, which is what unavailable looks like
      // everywhere else in the library.
      disabled ? 'cursor-not-allowed opacity-50 saturate-[0.35]' : '',
      className
    );

    const styles = {
      ...controlSlots(color, 0, 'solid'),
      // An empty star is not a disabled one and not a hairline: it is the ghost of
      // the star beside it, so it takes the muted ink at enough strength to read
      // as a shape and not enough to compete with the ones that are filled.
      '--p-empty': 'color-mix(in oklab, var(--plass-muted-fg) 40%, transparent)',
      ...style
    } as React.CSSProperties;

    if (readOnly) {
      return (
        <div
          ref={ref}
          role="img"
          aria-label={valueLabel(Math.max(0, Math.min(stars, value)), stars)}
          className={classNames}
          style={styles}
          onPointerLeave={onPointerLeave}
          {...props}
        >
          {marks}
        </div>
      );
    }

    return (
      <div
        ref={ref}
        role="radiogroup"
        aria-label={label}
        aria-disabled={disabled || undefined}
        aria-required={required || undefined}
        className={classNames}
        style={styles}
        onPointerLeave={(event) => {
          setHovered(null);
          onPointerLeave?.(event);
        }}
        {...props}
      >
        {marks}
      </div>
    );
  }
);
