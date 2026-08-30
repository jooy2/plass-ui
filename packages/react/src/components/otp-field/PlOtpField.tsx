'use client';

import * as React from 'react';
import { Field } from '@base-ui/react/field';
import { OTPField } from '@base-ui/react/otp-field';
import {
  cx,
  disabledClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  hasContent,
  metaTextClasses,
  stackGapClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassColor,
  PlassDensity,
  PlassElevation,
  PlassSize,
  PlassStyleProps
} from '../../types.js';

/**
 * What may be typed into a slot.
 *
 * `numeric` is the default because that is what a texted code is, and it is
 * also what puts a number pad in front of a phone. `any` accepts whatever the
 * keyboard produces — for a licence key with punctuation in it.
 */
export type PlOtpCharset = 'numeric' | 'alpha' | 'alphanumeric' | 'any';

/** How many slots a code may have. Two is the shortest thing worth splitting. */
const MIN_LENGTH = 2;
const MAX_LENGTH = 12;

export interface PlOtpFieldProps
  extends
    PlassStyleProps,
    Omit<
      React.ComponentPropsWithoutRef<'div'>,
      'color' | 'defaultValue' | 'onChange' | 'children'
    > {
  /** Drop shadow depth. `0` is the default — a field is cut into the sheet. */
  elevation?: PlassElevation;
  /**
   * How many characters the code has. Clamped to 2–12: a single box is a
   * `PlTextField`, and past twelve the row stops fitting a phone.
   * @default 6
   */
  length?: number;
  /**
   * What may be typed. Anything rejected is dropped rather than shown, and
   * `onValueInvalid` reports it.
   * @default 'numeric'
   */
  charset?: PlOtpCharset;
  /** Hides the characters, the way a password field does. @default false */
  mask?: boolean;
  /**
   * Splits the row every `groupSize` slots with a separator. `3` on a six-digit
   * code gives the familiar two blocks of three.
   */
  groupSize?: number;
  /** What is drawn between two groups. @default '–' */
  separator?: React.ReactNode;
  /** The code. Use with `onValueChange` for a controlled field. */
  value?: string;
  /** What it starts as, for an uncontrolled one. */
  defaultValue?: string;
  onValueChange?: (value: string) => void;
  /** Fires once every slot is filled — the moment to verify the code. */
  onComplete?: (value: string) => void;
  /** Fires when typed or pasted text held characters the charset rejects. */
  onValueInvalid?: (value: string) => void;
  /** Submits the owning form as soon as the code is complete. @default false */
  autoSubmit?: boolean;
  /** Label above the row, wired to the slots by Base UI's Field. */
  label?: React.ReactNode;
  /** Helper text below the row. */
  description?: React.ReactNode;
  /** Error message below the row. Its presence also turns the field invalid. */
  error?: React.ReactNode;
  /**
   * Forces the invalid state without a message — for when a form library owns
   * the validity. Defaults to whether `error` has content.
   */
  invalid?: boolean;
  /** Identifies the field when a form is submitted. */
  name?: string;
  /** The form must have a complete code before it submits. @default false */
  required?: boolean;
  /** Unavailable. Every slot stops answering. */
  disabled?: boolean;
  /** Readable and copyable, but not typeable. @default false */
  readOnly?: boolean;
  /** Puts the caret in the first slot on mount. @default false */
  autoFocus?: boolean;
}

/**
 * A slot's box.
 *
 * Its own ladder rather than `controlHeightClasses`, for the reason a tick box
 * has one: a slot is not a control in a row of controls, it is a character
 * standing on its own, and an `md` slot the height of an `md` `PlButton` would
 * be too small to read a code out of across a desk. Every step is taller than it
 * is wide, which is what makes a row of them read as places for one character
 * each rather than as a row of tiny fields.
 */
const slotSizeClasses: Record<PlassSize, string> = {
  xs: 'h-7 w-6',
  sm: 'h-8 w-7',
  md: 'h-10 w-8',
  lg: 'h-12 w-10',
  xl: 'h-14 w-12'
};

/**
 * And its own radius, for the reason a tick box has one.
 *
 * `radiusClasses` is a percentage of a *control's height*, which is a cut corner
 * on something wide and a lozenge on something nearly square: `md` is 12px, and
 * a 12px corner on a 32px-wide box is most of the way to a pill. These are
 * ~22% of the slot's width instead, which is the same amount of cut on this
 * shape — a sheet with the corners taken off, never a pill.
 */
const slotRadiusClasses: Record<PlassSize, string> = {
  xs: 'rounded-[0.3125rem]',
  sm: 'rounded-[0.375rem]',
  md: 'rounded-[0.4375rem]',
  lg: 'rounded-[0.5625rem]',
  xl: 'rounded-[0.6875rem]'
};

/**
 * And its own type scale, two steps up the control ladder. A verification code
 * is read out loud off a phone and typed with the other hand; it is the one
 * piece of text in a form that should be bigger than the label above it.
 */
const slotTextClasses: Record<PlassSize, string> = {
  xs: 'text-[0.8125rem]',
  sm: 'text-[0.9375rem]',
  md: 'text-[1.0625rem]',
  lg: 'text-[1.25rem]',
  xl: 'text-[1.5rem]'
};

/**
 * Between the slots, and the only thing `density` touches here — spacing, never
 * the box and never the type scale, exactly as everywhere else in the library.
 */
const slotGapClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'gap-1', sm: 'gap-1', md: 'gap-1.5', lg: 'gap-2', xl: 'gap-2.5' },
  compact: { xs: 'gap-0.5', sm: 'gap-0.5', md: 'gap-1', lg: 'gap-1', xl: 'gap-1.5' }
};

/** `charset` is the library's word; Base UI's is `validationType`. */
const validationTypes: Record<PlOtpCharset, 'numeric' | 'alpha' | 'alphanumeric' | 'none'> = {
  numeric: 'numeric',
  alpha: 'alpha',
  alphanumeric: 'alphanumeric',
  any: 'none'
};

/**
 * A row of one-character slots: a PIN, a texted verification code, an invite
 * key.
 *
 * Base UI owns everything that makes this harder than it looks — one hidden
 * value behind however many inputs, paste spread across the slots from wherever
 * the caret was, backspace stepping back a box, a click landing on the first
 * empty slot rather than the one under the pointer, and the autofill hook that
 * lets a phone offer the code straight from the message.
 *
 * What is here is the ladder a slot is drawn on and the field shell it shares
 * with `PlTextField` and `PlSelect` — a slot is a field-shaped box, and a form
 * holding both should not look like two form kits stacked on each other.
 */
export const PlOtpField = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlOtpFieldProps>(
  function PlOtpField(
    {
      variant = 'glass',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      length = 6,
      charset = 'numeric',
      mask = false,
      groupSize,
      separator = '–',
      value,
      defaultValue,
      onValueChange,
      onComplete,
      onValueInvalid,
      autoSubmit = false,
      label,
      description,
      error,
      invalid,
      name,
      required = false,
      disabled = false,
      readOnly = false,
      autoFocus = false,
      className,
      style,
      ...props
    },
    ref
  ) {
    const slots = Math.min(MAX_LENGTH, Math.max(MIN_LENGTH, Math.round(length)));
    const hasError = hasContent(error);
    const isInvalid = invalid ?? hasError;
    // Invalid re-points the whole slot family at `danger`, exactly as on
    // PlTextField, so the edge, the ring, the caret and the message all turn over
    // together and no state needs tokens of its own.
    const family: PlassColor = isInvalid ? 'danger' : color;

    const slotClassNames = cx(
      // `font-family` rather than the `font` shorthand: the shorthand would take
      // the inherited font *size* with it and undo the ladder set on the next
      // line.
      'text-center font-medium [font-family:inherit]',
      slotSizeClasses[size],
      slotTextClasses[size],
      slotRadiusClasses[size],
      transitionClasses,
      'caret-(--p-accent) selection:bg-(--p-soft-press)',
      // `focus` rather than `focus-visible`: a slot is put in focus by clicking it
      // as often as by typing into it, and the ring is the only thing saying which
      // character the next keystroke lands on.
      'focus:[outline:2px_solid_var(--p-ring)] focus:[outline-offset:0px]',
      'focus:[transition-duration:0ms]',
      // An if/else rather than stacked variants: two Tailwind classes of equal
      // specificity resolve by their order in the generated stylesheet.
      disabled
        ? disabledClasses[variant]
        : readOnly
          ? fieldReadOnlyClasses[variant]
          : fieldRestClasses[variant]
    );

    const separatorEvery = groupSize && groupSize > 0 ? Math.round(groupSize) : 0;

    return (
      <Field.Root
        disabled={disabled}
        invalid={isInvalid}
        className={cx('inline-flex flex-col align-top', stackGapClasses[size], className)}
        style={{ ...surfaceSlots(family, elevation), ...style }}
      >
        {hasContent(label) ? (
          <Field.Label
            className={cx(
              metaTextClasses[size],
              'font-medium',
              disabled ? 'text-(--plass-muted-fg)' : 'text-(--plass-fg)'
            )}
          >
            {label}
          </Field.Label>
        ) : null}

        <OTPField.Root
          ref={ref}
          length={slots}
          validationType={validationTypes[charset]}
          mask={mask}
          name={name}
          required={required}
          disabled={disabled}
          readOnly={readOnly}
          autoSubmit={autoSubmit}
          value={value}
          defaultValue={defaultValue}
          onValueChange={(next) => onValueChange?.(next)}
          onValueComplete={(next) => onComplete?.(next)}
          onValueInvalid={(next) => onValueInvalid?.(next)}
          className={cx('flex items-center', slotGapClasses[density][size])}
          {...props}
        >
          {Array.from({ length: slots }, (_, index) => (
            <React.Fragment key={index}>
              {/*
              `aria-hidden` and a plain span rather than a `role="separator"`:
              the dash is punctuation inside one value, not a break between two
              things, and a reader that announces it once per group is reading
              out the shape of the box instead of the code in it.
            */}
              {separatorEvery > 0 && index > 0 && index % separatorEvery === 0 ? (
                <span
                  aria-hidden="true"
                  className={cx(
                    'select-none px-0.5 text-(--plass-muted-fg)',
                    slotTextClasses[size]
                  )}
                >
                  {separator}
                </span>
              ) : null}
              <OTPField.Input className={slotClassNames} autoFocus={autoFocus && index === 0} />
            </React.Fragment>
          ))}
        </OTPField.Root>

        {hasContent(description) ? (
          <Field.Description className={cx(metaTextClasses[size], 'text-(--plass-muted-fg)')}>
            {description}
          </Field.Description>
        ) : null}

        {/* Two branches rather than one, because Base UI's own message is what
            the second is for. With a caller's `error` the box is theirs and
            `match` shows it unconditionally; without one it is left to render
            whatever made the field invalid — the browser's constraint message,
            or a `PlForm`'s `errors` entry for this field's `name`. Passing
            `children` in that case would overwrite the message with nothing,
            and a field that goes red with nothing said is one a reader has to
            guess at. */}
        {hasError ? (
          <Field.Error match className={cx(metaTextClasses[size], 'text-(--p-accent)')}>
            {error}
          </Field.Error>
        ) : (
          <Field.Error className={cx(metaTextClasses[size], 'text-(--p-accent)')} />
        )}
      </Field.Root>
    );
  }
);
