'use client';

import * as React from 'react';
import { Select as BaseUISelect } from '@base-ui/react/select';
import { Field } from '@base-ui/react/field';
import { CheckIcon, ChevronIcon } from '../../internal/icons.js';
import { WidthSizer } from '../../internal/sizer.js';
import {
  controlHeightClasses,
  controlTextLeadingClasses,
  disabledClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  focusWithinRingClasses,
  gapClasses,
  glassClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  stackGapClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassElevation, PlassStyleProps } from '../../types.js';

/**
 * What a select's value may be.
 *
 * Deliberately not generic over arbitrary objects. A select is a form control,
 * its value is what a form submits, and every escape from that — object values,
 * custom equality, a stringifier for the trigger — buys flexibility by making
 * the common case harder to write. Keep the identifier here and look the object
 * up on the other side.
 */
export type PlSelectValue = string | number;

export interface PlSelectOption {
  /** Submitted, and what `value` / `onValueChange` speak in. */
  value: PlSelectValue;
  /** Shown in the list and in the trigger. Defaults to the value itself. */
  label?: React.ReactNode;
  /** Unavailable, but still listed — the option exists, it just cannot be picked. */
  disabled?: boolean;
}

export interface PlSelectProps
  extends
    PlassStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'children'> {
  /**
   * The options, as data. There is no `<PlSelect.Option>` to compose: what a
   * caller has is almost always an array already, and the list has to be
   * available to the trigger before the popup has ever been opened.
   */
  items: readonly PlSelectOption[];
  /** The chosen value. Use with `onValueChange` for a controlled select. */
  value?: PlSelectValue | null;
  /** The initially chosen value, for an uncontrolled select. */
  defaultValue?: PlSelectValue | null;
  onValueChange?: (value: PlSelectValue | null) => void;
  /** Shown in the trigger while nothing is chosen. */
  placeholder?: React.ReactNode;
  /**
   * Drop shadow depth of the *trigger*. `0`, like a PlTextField: a field is cut
   * into the sheet rather than resting on it. The popup has its own, fixed at
   * `3` — it genuinely floats above the page, which is the one case elevation
   * is for.
   * @default 0
   */
  elevation?: PlassElevation;
  /** Label above the trigger, wired to it by Base UI's Field. */
  label?: React.ReactNode;
  /** Helper text below the trigger. */
  description?: React.ReactNode;
  /** Error message below. Its presence also turns the select invalid. */
  error?: React.ReactNode;
  /** Forces the invalid state without a message. Defaults to whether `error` has content. */
  invalid?: boolean;
  /** Content placed before the value. Sized in `em`, so it tracks the text. */
  startIcon?: React.ReactNode;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  /** Unavailable. */
  disabled?: boolean;
  /** The value is shown but cannot be changed. */
  readOnly?: boolean;
  /** Whether a value must be chosen before the form is submitted. */
  required?: boolean;
  /** Identifies the field when a form is submitted. */
  name?: string;
  id?: string;
}

/** The trigger is a PlTextField's shell, to the pixel. */
const triggerBaseClasses = /* @__PURE__ */ [
  'group relative flex w-full cursor-pointer items-center select-none',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  focusWithinRingClasses,
  iconClasses
].join(' ');

/**
 * The popup is the one surface in the library that is *supposed* to float, so
 * unlike everything else it carries a shadow by default — at level 3.
 *
 * It is the glass at its most opaque, because it has a page under it rather
 * than a sheet: a 62%-translucent pane over arbitrary body copy is a pane you
 * read the body copy through.
 *
 * Every `--p-*` it reads is set on the popup itself rather than inherited from
 * the Field around it. A portalled popup renders at the end of `<body>`, so it
 * is outside the element the slots were declared on, and a `var()` with nothing
 * to resolve to is not a fallback — `border-color` collapses to `currentColor`
 * (a black hairline) and `background-color` to transparent.
 */
const popupClasses = /* @__PURE__ */ [
  glassClasses,
  'max-h-[min(20rem,var(--available-height))] overflow-y-auto overscroll-contain',
  'min-w-[var(--anchor-width)] border bg-(--plass-glass-press) p-1',
  '[border-color:var(--plass-glass-line)]',
  '[box-shadow:var(--plass-shadow-3),var(--plass-gloss-glass)]',
  '[outline:none]'
].join(' ');

const itemClasses = /* @__PURE__ */ [
  'relative flex cursor-pointer items-center gap-2 select-none',
  'rounded-(--plass-radius-xs) py-1.5 pe-2 ps-7',
  transitionClasses,
  // `data-highlighted` rather than `:hover`: it is also what the arrow keys
  // move, so the mouse and the keyboard light the same row.
  'data-[highlighted]:bg-(--p-soft-hover) data-[highlighted]:text-(--p-accent)',
  'data-[selected]:font-semibold data-[selected]:text-(--p-accent)',
  'data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50',
  '[outline:none]'
].join(' ');

/**
 * One value chosen from a list of them.
 *
 * The trigger is a PlTextField's shell wearing a chevron, on purpose: a form
 * where the select is a different height, radius or material from the fields
 * around it is a form that looks assembled rather than designed. That is why
 * `fieldRestClasses` lives in `internal/styles` and not in either component.
 *
 * Base UI owns everything hard about this — the popup's positioning and
 * flipping, the focus trap, typeahead, the hidden input that makes it submit —
 * and the work here is the surface it all wears.
 */
export const PlSelect = /* @__PURE__ */ React.forwardRef<HTMLButtonElement, PlSelectProps>(
  function PlSelect(
    {
      variant = 'glass',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      items,
      value,
      defaultValue,
      onValueChange,
      placeholder,
      label,
      description,
      error,
      invalid,
      startIcon,
      fullWidth = false,
      disabled = false,
      readOnly = false,
      required = false,
      name,
      id,
      className,
      style,
      ...props
    },
    ref
  ) {
    const hasError = hasContent(error);
    const isInvalid = invalid ?? hasError;
    // Invalid re-points the whole slot family at `danger`, so the edge, the ring
    // and the message all turn over together.
    const family: PlassColor = isInvalid ? 'danger' : color;

    // Base UI reads this to render the chosen option's *label* in the trigger
    // rather than its raw value, which is the only way `<Select.Value>` can show
    // "Seoul" for `value="kr-11"` before the popup has ever been mounted.
    const baseItems = React.useMemo(
      () => items.map((item) => ({ label: item.label ?? String(item.value), value: item.value })),
      [items]
    );

    // Holds the trigger open at the width of the longest thing it could say, so
    // choosing a shorter option does not shrink the field out from under the
    // pointer that chose it.
    const sizerSamples = React.useMemo(
      () => [
        ...items.map((item) => item.label ?? String(item.value)),
        ...(hasContent(placeholder) ? [placeholder] : [])
      ],
      [items, placeholder]
    );

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
            className={[
              metaTextClasses[size],
              'font-semibold',
              disabled ? 'text-(--plass-muted-fg)' : 'text-(--plass-fg)'
            ].join(' ')}
          >
            {label}
          </Field.Label>
        ) : null}

        <BaseUISelect.Root
          id={id}
          name={name}
          items={baseItems}
          value={value}
          defaultValue={defaultValue}
          onValueChange={(next) => onValueChange?.(next as PlSelectValue | null)}
          disabled={disabled}
          readOnly={readOnly}
          required={required}
        >
          <BaseUISelect.Trigger
            ref={ref}
            className={[
              triggerBaseClasses,
              controlHeightClasses[size],
              controlTextLeadingClasses[size],
              radiusClasses[size],
              gapClasses[size],
              paddingXClasses[density][size],
              // An if/else rather than stacked variants: two Tailwind classes of
              // equal specificity resolve by their order in the generated sheet.
              disabled
                ? disabledClasses[variant]
                : readOnly
                  ? `${fieldReadOnlyClasses[variant]} cursor-default`
                  : fieldRestClasses[variant]
            ].join(' ')}
          >
            {startIcon ? (
              <span className="flex h-[1lh] shrink-0 items-center text-(--plass-muted-fg)">
                {startIcon}
              </span>
            ) : null}

            {/* The value, and under it every label it could hold. `min-w-0` on the
              column is what keeps the whole thing shrinkable when a narrow
              container asks it to be. */}
            <span className="flex min-w-0 flex-1 flex-col">
              <BaseUISelect.Value
                className={[
                  'w-full truncate text-start',
                  // The placeholder is muted the same way a PlTextField's is, so
                  // an empty select and an empty field read as equally empty.
                  'data-[placeholder]:text-(--plass-muted-fg)'
                ].join(' ')}
                placeholder={placeholder}
              />
              <WidthSizer samples={sizerSamples} />
            </span>

            <BaseUISelect.Icon
              className={[
                'flex h-[1lh] shrink-0 items-center text-(--plass-muted-fg)',
                // The chevron is the one thing here that may turn: it is a glyph,
                // not a label, and nothing about it resamples.
                '[transition:rotate_var(--plass-duration)_var(--plass-ease)]',
                'data-[popup-open]:rotate-180'
              ].join(' ')}
            >
              <ChevronIcon />
            </BaseUISelect.Icon>
          </BaseUISelect.Trigger>

          <BaseUISelect.Portal>
            {/* `plass-portal` is a hook, not a style: a portalled popup leaves the
              subtree its host may have scoped a CSS reset to, and this is what
              such a host can hang the same reset off. */}
            <BaseUISelect.Positioner
              className="plass-portal z-50 [outline:none]"
              sideOffset={6}
              alignItemWithTrigger={false}
            >
              <BaseUISelect.Popup
                className={`${popupClasses} ${radiusClasses[size]} ${controlTextLeadingClasses[size]}`}
                style={surfaceSlots(family, 3)}
              >
                {items.map((item) => (
                  <BaseUISelect.Item
                    key={String(item.value)}
                    value={item.value}
                    disabled={item.disabled}
                    className={itemClasses}
                  >
                    <BaseUISelect.ItemIndicator className="absolute start-1.5 flex size-4 items-center justify-center">
                      <CheckIcon />
                    </BaseUISelect.ItemIndicator>
                    <BaseUISelect.ItemText className="truncate">
                      {item.label ?? String(item.value)}
                    </BaseUISelect.ItemText>
                  </BaseUISelect.Item>
                ))}
              </BaseUISelect.Popup>
            </BaseUISelect.Positioner>
          </BaseUISelect.Portal>
        </BaseUISelect.Root>

        {description ? (
          <Field.Description className={`${metaTextClasses[size]} text-(--plass-muted-fg)`}>
            {description}
          </Field.Description>
        ) : null}

        {hasError ? (
          <Field.Error match className={`${metaTextClasses[size]} text-(--p-accent)`}>
            {error}
          </Field.Error>
        ) : null}
      </Field.Root>
    );
  }
);
