'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { Field } from '@base-ui/react/field';
import { Input } from '@base-ui/react/input';
import { Spinner } from '../../internal/icons.js';
import { hotKeyHandler } from '../../internal/keys.js';
import {
  controlHeightClasses,
  controlTextLeadingClasses,
  cx,
  disabledClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
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
  PlassSize,
  PlassStyleProps
} from '../../types.js';

/** How the multiline control may be resized by the user. Ignored when single line. */
export type PlTextFieldResize = 'none' | 'vertical' | 'horizontal' | 'both';

/**
 * Native `<input>` attributes, minus the three that collide with the shared
 * vocabulary: `color` and `size` are Plass props here, and `onChange` is widened
 * below so the same handler types against a `<textarea>` in multiline mode.
 */
type NativeControlProps = Omit<
  React.ComponentPropsWithoutRef<'input'>,
  'color' | 'size' | 'onChange' | 'children'
>;

export interface PlTextFieldProps extends PlassStyleProps, NativeControlProps {
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
   * sheet, not a key resting on it, and the one place in the library where a
   * shadow points *inward*.
   * @default 0
   */
  elevation?: PlassElevation;
  /**
   * Renders a `<textarea>` instead of an `<input>`. Everything else — sizing,
   * density, variants, states — stays identical, so switching a field to
   * multiline never changes how it sits in a form.
   * @default false
   */
  multiline?: boolean;
  /** Visible rows in multiline mode. One row is exactly the single-line height. */
  rows?: number;
  /**
   * Which way the user may drag the multiline control. Horizontal resizing
   * breaks a form's column, so only the vertical axis is on by default.
   * @default 'vertical'
   */
  resize?: PlTextFieldResize;
  /**
   * Label above the control, wired to it by Base UI's Field. There is no
   * floating variant on purpose: a floating label needs a `transform` on the
   * thing being typed into, and a label that moves under the caret is the one
   * effect this library rules out on a control.
   */
  label?: React.ReactNode;
  /** Helper text below the control. */
  description?: React.ReactNode;
  /** Error message below the control. Its presence also turns the field invalid. */
  error?: React.ReactNode;
  /**
   * Forces the invalid state without a message — for when an external form
   * library owns the validity. Defaults to whether `error` has content.
   */
  invalid?: boolean;
  /** Content placed before the control. Sized in `em`, so it tracks the text. */
  startIcon?: React.ReactNode;
  /** Content placed after the control. */
  endIcon?: React.ReactNode;
  /**
   * Shows a spinner in place of `endIcon` and marks the field busy. Typing is
   * deliberately still allowed — a field is usually loading *because of* what
   * was typed into it.
   */
  loading?: boolean;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  onChange?: React.ChangeEventHandler<HTMLInputElement | HTMLTextAreaElement>;
}

/**
 * Type scale and radius, shared by both modes. The line height is explicit here
 * rather than `leading-none` as on PlButton, because in multiline mode it is what
 * decides the height of a row — and it has to agree with the single-line
 * heights below or a one-row textarea would not line up with an input.
 */
const sizeClasses: Record<PlassSize, string> = {
  xs: `${gapClasses.xs} ${radiusClasses.xs} ${controlTextLeadingClasses.xs}`,
  sm: `${gapClasses.sm} ${radiusClasses.sm} ${controlTextLeadingClasses.sm}`,
  md: `${gapClasses.md} ${radiusClasses.md} ${controlTextLeadingClasses.md}`,
  lg: `${gapClasses.lg} ${radiusClasses.lg} ${controlTextLeadingClasses.lg}`,
  xl: `${gapClasses.xl} ${radiusClasses.xl} ${controlTextLeadingClasses.xl}`
};

/**
 * Multiline cannot use a fixed height — `rows` decides it. Instead the vertical
 * padding is `(height - border - line-height) / 2`, which makes a one-row
 * textarea exactly as tall as the single-line field of the same size. The
 * `min-h-*` catches the variants that carry no border.
 *
 * These are keyed by `size` and never by `density`: density is horizontal
 * padding only, and letting it touch this would make the same `rows` produce
 * two different heights.
 */
const multilineClasses: Record<PlassSize, string> = {
  xs: 'min-h-6 py-[3px]',
  sm: 'min-h-8 py-[6px]',
  md: 'min-h-10 py-[9px]',
  lg: 'min-h-12 py-[11px]',
  xl: 'min-h-14 py-[13px]'
};

const resizeClasses: Record<PlTextFieldResize, string> = {
  none: 'resize-none',
  vertical: 'resize-y',
  horizontal: 'resize-x',
  both: 'resize'
};

const shellBaseClasses = /* @__PURE__ */ [
  // `group` so the adornments can answer the control's focus; `cursor-text`
  // because the whole shell behaves as the field, padding included.
  'group relative flex w-full cursor-text',
  '[-webkit-tap-highlight-color:transparent]',
  transitionClasses,
  // The ring belongs to the shell, not to the control inside it, so it traces
  // the glass edge rather than a rectangle floating inside it.
  focusWithinRingClasses,
  iconClasses
].join(' ');

/**
 * The shell, the read-only treatment and the disabled treatment are the ones
 * `internal/styles` defines for every field-shaped control — a Select's trigger
 * is drawn on exactly the same box, and the two have to be indistinguishable.
 */
const restClasses = fieldRestClasses;
const readOnlyClasses = fieldReadOnlyClasses;

export const PlTextField = /* @__PURE__ */ React.forwardRef<
  HTMLInputElement | HTMLTextAreaElement,
  PlTextFieldProps
>(function PlTextField(
  {
    variant = 'glass',
    size: sizeProp,
    color: colorProp,
    density: densityProp,
    elevation = 0,
    multiline = false,
    rows = 3,
    resize = 'vertical',
    label,
    description,
    error,
    invalid,
    startIcon,
    endIcon,
    loading = false,
    fullWidth = false,
    readOnly = false,
    disabled = false,
    type = 'text',
    hotKeys,
    onKeyDown,
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
  const density = densityProp ?? defaults.density ?? 'default';

  const hasError = hasContent(error);
  const isInvalid = invalid ?? hasError;
  // Invalid re-points the whole slot family at `danger`, so the edge, the ring,
  // the caret and the message all turn over together and no state needs its own
  // set of tokens.
  const family: PlassColor = isInvalid ? 'danger' : color;

  const controlRef = React.useRef<HTMLElement | null>(null);
  const setControlRef = React.useCallback(
    (node: HTMLElement | null) => {
      controlRef.current = node;
      if (typeof ref === 'function') {
        ref(node as HTMLInputElement | HTMLTextAreaElement | null);
      } else if (ref) {
        ref.current = node as HTMLInputElement | HTMLTextAreaElement | null;
      }
    },
    [ref]
  );

  const shellClasses = [
    shellBaseClasses,
    sizeClasses[size],
    multiline
      ? `${multilineClasses[size]} items-start`
      : `${controlHeightClasses[size]} items-center`,
    paddingXClasses[density][size],
    // An if/else rather than stacked `data-*` variants: two Tailwind variants
    // of equal specificity resolve by their order in the generated stylesheet.
    disabled ? disabledClasses[variant] : readOnly ? readOnlyClasses[variant] : restClasses[variant]
  ]
    .filter(Boolean)
    .join(' ');

  const controlClasses = [
    'min-w-0 flex-1 bg-transparent [font:inherit] text-inherit',
    // Not `outline-none`: that utility zeroes `--tw-outline-style`, and the
    // shell's focus ring is drawn with the same variable family. The shorthand
    // takes the outline off this element and leaves the ring alone.
    '[outline:none]',
    'placeholder:text-(--plass-muted-fg)',
    'caret-(--p-accent) selection:bg-(--p-soft-press)',
    'disabled:cursor-not-allowed',
    multiline ? `block ${resizeClasses[resize]}` : 'self-stretch'
  ].join(' ');

  // `1lh` keeps an adornment centred on the first line rather than on the whole
  // box, which is the only way it stays put when the control grows to 5 rows.
  const adornmentClasses =
    'inline-flex h-[1lh] shrink-0 items-center text-(--plass-muted-fg) transition-[color] duration-(--plass-duration) group-focus-within:text-(--p-accent)';

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
    >
      {label ? (
        <Field.Label
          className={cx(
            metaTextClasses[size],
            'font-semibold',
            disabled ? 'text-(--plass-muted-fg)' : 'text-(--plass-fg)',
            classNames?.label
          )}
        >
          {label}
        </Field.Label>
      ) : null}

      <span
        className={cx(shellClasses, classNames?.control)}
        onPointerDown={(event) => {
          // Clicking the shell's own padding should put the caret in the field,
          // the way clicking anywhere inside a native input does. Only when the
          // shell itself was hit — a click on the control or on an adornment is
          // left alone so text selection still works.
          if (event.target === event.currentTarget && !disabled) {
            event.preventDefault();
            controlRef.current?.focus();
          }
        }}
      >
        {startIcon ? <span className={adornmentClasses}>{startIcon}</span> : null}

        <Input
          ref={setControlRef}
          className={controlClasses}
          disabled={disabled}
          readOnly={readOnly}
          aria-busy={loading || undefined}
          data-loading={loading || undefined}
          // On the control rather than on the shell: a chord is answered by the
          // thing that has the focus, and `hotKeys` on a wrapper would fire for
          // a key pressed on the label beside it.
          onKeyDown={hotKeyHandler(hotKeys, onKeyDown)}
          {...(multiline ? { render: <textarea rows={rows} /> } : { type })}
          {...props}
        />

        {loading ? (
          <span className={adornmentClasses}>
            <Spinner />
          </span>
        ) : endIcon ? (
          <span className={adornmentClasses}>{endIcon}</span>
        ) : null}
      </span>

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
});
