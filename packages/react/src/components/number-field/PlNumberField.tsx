'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { NumberField as BaseUINumberField } from '@base-ui/react/number-field';
import { Field } from '@base-ui/react/field';
import { MinusIcon, PlusIcon } from '../../internal/icons.js';
import { hotKeyHandler } from '../../internal/keys.js';
import {
  controlHeightClasses,
  controlTextLeadingClasses,
  cx,
  disabledClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  focusRingClasses,
  focusWithinRingClasses,
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  stackGapClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassColor,
  PlassElevation,
  PlassFieldClassNames,
  PlassHotKeys,
  PlassStyleProps
} from '../../types.js';

/**
 * Where the two steppers sit.
 *
 * - `end` — both at the trailing edge, the way a spinner has always looked.
 * - `split` — minus at the start, plus at the end, with the number between them.
 *   For a quantity that is nudged rather than typed.
 * - `none` — no buttons. The field is still a number field: the arrow keys, the
 *   clamping and the formatting all stay.
 *
 * There is deliberately no stacked pair of half-height chevrons. At `xs` each
 * arrow would be under three pixels tall, and a target that small is a target
 * nobody hits.
 */
export type PlNumberFieldSteppers = 'end' | 'split' | 'none';

export interface PlNumberFieldProps
  extends
    PlassStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'children'> {
  /** Classes on the parts a `className` does not reach. */
  classNames?: PlassFieldClassNames;
  /**
   * Chords this field answers to, in the vocabulary `PlHotKeys` draws.
   *
   * `{ 'Mod+Enter': save, Escape: cancel }` — the same string a `PlHotKeys`
   * beside the field would print, so the cap and the binding cannot drift. A
   * chord that matches is **consumed**: the handler runs and the key reaches
   * neither the control's own behaviour nor the form around it.
   */
  hotKeys?: PlassHotKeys;
  /**
   * Drop shadow depth. `0` is the default — a field is a well cut into the
   * sheet, not a key resting on it.
   * @default 0
   */
  elevation?: PlassElevation;
  /** The number. Use with `onValueChange` for a controlled field. */
  value?: number | null;
  /** The initial number, for an uncontrolled field. */
  defaultValue?: number;
  /** Called on every change — typing, stepping, the wheel. */
  onValueChange?: (value: number | null) => void;
  /**
   * Called when the value settles: on blur after typing, on pointer release
   * after a press, and together with `onValueChange` for the keyboard.
   */
  onValueCommitted?: (value: number | null) => void;
  /** The bottom of the range. Stepping stops here. */
  min?: number;
  /** The top of the range. */
  max?: number;
  /**
   * How far one step goes. `'any'` turns step validation off.
   * @default 1
   */
  step?: number | 'any';
  /**
   * The step taken while Shift is held.
   * @default 10
   */
  largeStep?: number;
  /**
   * The step taken while Alt is held.
   * @default 0.1
   */
  smallStep?: number;
  /**
   * Whether stepping snaps to multiples of the step.
   * @default false
   */
  snapOnStep?: boolean;
  /**
   * Whether the wheel changes the value while the field is focused and hovered.
   * Off by default: a page that scrolls under the pointer and a field that
   * changes under it are the same gesture, and only one of them was meant.
   * @default false
   */
  allowWheelScrub?: boolean;
  /**
   * How the number is written — currency, percent, decimal places. Passed
   * straight to `Intl.NumberFormat`, so the field shows `$1,240.00` and still
   * reports `1240`.
   */
  format?: Intl.NumberFormatOptions;
  /** Which locale the number is written and parsed in. Defaults to the runtime's. */
  locale?: Intl.LocalesArgument;
  /**
   * Where the steppers sit, or `none` for a field without them.
   * @default 'end'
   */
  steppers?: PlNumberFieldSteppers;
  /**
   * Accessible name of the increment button. Never drawn.
   * @default 'Increase'
   */
  incrementLabel?: string;
  /**
   * Accessible name of the decrement button. Never drawn.
   * @default 'Decrease'
   */
  decrementLabel?: string;
  /**
   * Label above the control, wired to it by Base UI's Field. There is no
   * floating variant on purpose: floating labels need a `transform`.
   */
  label?: React.ReactNode;
  /** Helper text below the control. */
  description?: React.ReactNode;
  /** Error message below the control. Its presence also turns the field invalid. */
  error?: React.ReactNode;
  /** Forces the invalid state without a message. Defaults to `!!error`. */
  invalid?: boolean;
  /** Content placed before the number — a currency mark, a unit, an icon. */
  startIcon?: React.ReactNode;
  /** Content placed after the number, before the steppers. */
  endIcon?: React.ReactNode;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  /** Unavailable. */
  disabled?: boolean;
  /** The number is shown but cannot be changed. */
  readOnly?: boolean;
  /** Whether a value must be entered before the form is submitted. */
  required?: boolean;
  /** Identifies the field when a form is submitted. */
  name?: string;
  /** Placeholder shown while the field is empty. */
  placeholder?: string;
  id?: string;
}

/** The shell is a `PlTextField`'s, to the pixel — see `fieldRestClasses`. */
const shellBaseClasses = /* @__PURE__ */ [
  'group relative flex w-full cursor-text items-center',
  '[-webkit-tap-highlight-color:transparent]',
  transitionClasses,
  'focus-within:[transition-duration:0ms]',
  focusWithinRingClasses,
  iconClasses
].join(' ');

/**
 * A stepper. Square, tracking the text rather than the control, so the same
 * button works at every step of the scale without a table of its own.
 *
 * No `transform` on it, the same rule every control in the library keeps: what
 * moves under the finger is the tint, not the button.
 */
const stepperClasses = /* @__PURE__ */ [
  'inline-flex size-[1.7em] shrink-0 cursor-pointer items-center justify-center',
  'rounded-(--plass-radius-xs) text-(--plass-muted-fg) select-none',
  '[&_svg]:size-[0.9em] [&_svg]:shrink-0',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  '[transition:background-color_var(--plass-duration)_var(--plass-ease),color_var(--plass-duration)_var(--plass-ease),opacity_var(--plass-duration)_var(--plass-ease)]',
  'active:[transition-duration:0ms]',
  'hover:bg-(--p-soft) hover:text-(--p-accent)',
  'active:bg-(--p-soft-press)',
  focusRingClasses,
  // A stepper that has run into `min` goes out like everything else that is
  // unavailable here: the page shows through it.
  'disabled:cursor-not-allowed disabled:bg-transparent disabled:opacity-40'
].join(' ');

/**
 * A field that only holds a number.
 *
 * The shell is a `PlTextField`'s, to the pixel, because a form where the
 * quantity box is a different height or radius from the boxes around it is a
 * form that looks assembled rather than designed. What is added on top is a real
 * numeric control: arrow keys and the steppers move by `step` (Shift for
 * `largeStep`, Alt for `smallStep`), the value clamps to `min`/`max`, and
 * `format` writes it as currency or a percentage while `value` stays a plain
 * number.
 *
 * Base UI owns the hard parts — parsing what was typed against the locale,
 * clamping, the press-and-hold repeat on the steppers, and the hidden input that
 * submits with a form.
 */
export function PlNumberField({
  variant = 'glass',
  size: sizeProp,
  color: colorProp,
  density: densityProp,
  elevation = 0,
  value,
  defaultValue,
  onValueChange,
  onValueCommitted,
  min,
  max,
  step,
  largeStep,
  smallStep,
  snapOnStep,
  allowWheelScrub = false,
  format,
  locale: localeProp,
  steppers = 'end',
  incrementLabel: incrementLabelProp,
  decrementLabel: decrementLabelProp,
  label,
  description,
  error,
  invalid,
  startIcon,
  endIcon,
  fullWidth = false,
  disabled = false,
  readOnly = false,
  required = false,
  name,
  placeholder,
  id,
  className,
  hotKeys,
  classNames,
  style,
  ...props
}: PlNumberFieldProps) {
  const defaults = useDefaults();
  const labels = useLabels();
  const incrementLabel = incrementLabelProp ?? labels.increase;
  const decrementLabel = decrementLabelProp ?? labels.decrease;
  const locale = localeProp ?? defaults.locale;
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';

  const hasError = hasContent(error);
  const isInvalid = invalid ?? hasError;
  // Invalid re-points the whole slot family at `danger`, so the edge, the ring,
  // the caret and the message all turn over together.
  const family: PlassColor = isInvalid ? 'danger' : color;

  // The steppers bring their own padding; stacking the shell's on top of them
  // would leave the buttons floating in the middle of a gap. The shell keeps the
  // padding on whichever side has no button.
  const padX = paddingXClasses[density][size];
  const insetClasses: Record<PlNumberFieldSteppers, string> = {
    end: `${padX} pe-1`,
    split: 'px-1',
    none: padX
  };

  const decrement = (
    <BaseUINumberField.Decrement aria-label={decrementLabel} className={stepperClasses}>
      <MinusIcon />
    </BaseUINumberField.Decrement>
  );

  const increment = (
    <BaseUINumberField.Increment aria-label={incrementLabel} className={stepperClasses}>
      <PlusIcon />
    </BaseUINumberField.Increment>
  );

  const showSteppers = steppers !== 'none' && !readOnly;

  return (
    <Field.Root
      disabled={disabled}
      invalid={isInvalid}
      className={[
        'flex-col align-top',
        stackGapClasses[size],
        fullWidth ? 'flex w-full' : 'inline-flex',
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      style={{ ...surfaceSlots(family, elevation), ...style }}
      {...props}
    >
      {label ? (
        <Field.Label
          className={cx(
            metaTextClasses[size],
            'font-medium text-(--plass-fg)',
            disabled ? 'opacity-50' : '',
            classNames?.label
          )}
        >
          {label}
        </Field.Label>
      ) : null}

      {/* `contents` so the Group below is a direct child of the Field's column —
          the Root is a grouping element, not a box in the layout. */}
      <BaseUINumberField.Root
        id={id}
        name={name}
        className="contents"
        value={value}
        defaultValue={defaultValue}
        onValueChange={(next) => onValueChange?.(next)}
        onValueCommitted={(next) => onValueCommitted?.(next)}
        min={min}
        max={max}
        step={step}
        largeStep={largeStep}
        smallStep={smallStep}
        snapOnStep={snapOnStep}
        allowWheelScrub={allowWheelScrub}
        format={format}
        locale={locale}
        disabled={disabled}
        readOnly={readOnly}
        required={required}
      >
        <BaseUINumberField.Group
          className={[
            shellBaseClasses,
            controlHeightClasses[size],
            controlTextLeadingClasses[size],
            radiusClasses[size],
            gapClasses[size],
            showSteppers ? insetClasses[steppers] : padX,
            // An if/else rather than stacked variants: two Tailwind classes of
            // equal specificity resolve by their order in the generated sheet.
            disabled
              ? disabledClasses[variant]
              : readOnly
                ? fieldReadOnlyClasses[variant]
                : fieldRestClasses[variant],
            classNames?.control
          ]
            .filter(Boolean)
            .join(' ')}
        >
          {showSteppers && steppers === 'split' ? decrement : null}

          {startIcon ? (
            <span className="flex h-[1lh] shrink-0 items-center text-(--plass-muted-fg)">
              {startIcon}
            </span>
          ) : null}

          <BaseUINumberField.Input
            placeholder={placeholder}
            // On the input rather than on the stack `...props` lands on: a chord
            // is answered by the thing that has the focus.
            onKeyDown={hotKeyHandler(hotKeys, undefined)}
            className={[
              'min-w-0 flex-1 self-stretch bg-transparent [font:inherit] text-inherit',
              // Not `outline-none`: that utility zeroes `--tw-outline-style`, and
              // the shell's focus ring is drawn from the same family.
              '[outline:none]',
              'tabular-nums',
              // Split steppers put the number between the two buttons, so it
              // belongs in the middle rather than against an edge.
              steppers === 'split' && showSteppers ? 'text-center' : '',
              'placeholder:text-(--plass-muted-fg)',
              'caret-(--p-accent) selection:bg-(--p-soft-press)',
              'disabled:cursor-not-allowed'
            ]
              .filter(Boolean)
              .join(' ')}
          />

          {endIcon ? (
            <span className="flex h-[1lh] shrink-0 items-center text-(--plass-muted-fg)">
              {endIcon}
            </span>
          ) : null}

          {showSteppers && steppers === 'end' ? (
            <span className="flex shrink-0 items-center gap-0.5">
              {decrement}
              {increment}
            </span>
          ) : null}
          {showSteppers && steppers === 'split' ? increment : null}
        </BaseUINumberField.Group>
      </BaseUINumberField.Root>

      {description ? (
        <Field.Description
          className={cx(metaTextClasses[size], 'text-(--plass-muted-fg)', classNames?.description)}
        >
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
        <Field.Error
          match
          className={cx(metaTextClasses[size], 'text-(--p-accent)', classNames?.error)}
        >
          {error}
        </Field.Error>
      ) : (
        <Field.Error
          className={cx(metaTextClasses[size], 'text-(--p-accent)', classNames?.error)}
        />
      )}
    </Field.Root>
  );
}
