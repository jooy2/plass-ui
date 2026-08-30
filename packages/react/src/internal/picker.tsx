import * as React from 'react';
import { Field } from '@base-ui/react/field';
import { Popover } from '@base-ui/react/popover';
import { CloseIcon } from './icons.js';
import { WidthSizer } from './sizer.js';
import {
  chipRemoveClasses,
  controlHeightClasses,
  controlTextLeadingClasses,
  cx,
  disabledClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  focusWithinRingClasses,
  gapClasses,
  glassClasses,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  stackGapClasses,
  surfaceSlots,
  transitionClasses
} from './styles.js';
import type { PlassPickerLabels } from './calendar.js';
import type {
  PlassColor,
  PlassElevation,
  PlassFieldClassNames,
  PlassSize,
  PlassStyleProps
} from '../types.js';

/**
 * The shell all four pickers wear: a field-shaped trigger with a popup hanging
 * off it.
 *
 * It is here rather than in one of the components for the reason the calendar
 * is: four components need it, and none of them should have to import another.
 * What it draws is deliberately not new — the trigger is `fieldRestClasses`,
 * the same box a `PlTextField` and a `PlSelect`'s trigger are drawn on, to the
 * pixel. A form where the date field is a different height, radius or material
 * from the text field beside it is a form that looks assembled rather than
 * designed.
 *
 * The one thing the pickers do *not* offer is typing a date into the trigger.
 * Parsing a date out of free text is locale-dependent in a way that cannot be
 * done honestly without a date library, and a field that understands `27/7/26`
 * in one browser and not the next is worse than one that never claimed to. So
 * the trigger is a button, exactly as a select's is, and the calendar is where
 * the answer comes from.
 */

/* ---------------------------------------------------------------------------
 * Colour
 * ------------------------------------------------------------------------- */

/**
 * The popup's slots: a container's undyed sheet with the *control* fill added
 * back on top.
 *
 * Neither generator in `internal/styles` says this on its own, and the reason is
 * that a picker's popup is both things at once. It is a container — it holds a
 * grid of forty-two days, and dyeing the sheet under them would put every one of
 * them on a background it was not chosen against — and it also holds the one
 * filled token in the library that has to be found without being read, which is
 * the day you picked. So the sheet stays clear glass and the family arrives in
 * the two fill slots the chosen cell reads.
 */
export function popupSlots(color: PlassColor, elevation: PlassElevation): React.CSSProperties {
  return {
    ...surfaceSlots(color, elevation),
    '--p-fill': `var(--plass-${color}-fill)`,
    '--p-on-solid': `var(--plass-${color}-on-solid)`
  } as React.CSSProperties;
}

/* ---------------------------------------------------------------------------
 * Surfaces
 * ------------------------------------------------------------------------- */

/** The trigger's box. A `PlTextField`'s shell, unchanged. */
const triggerShellClasses = /* @__PURE__ */ [
  'group relative flex w-full items-center select-none',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  focusWithinRingClasses,
  iconClasses
].join(' ');

/**
 * The popup. Like every floating surface in the library it carries a shadow by
 * default, at level 3 — as far as the ladder goes without hovering — because it
 * is genuinely off the page rather than merely on top of it.
 */
export const pickerPopupClasses = /* @__PURE__ */ [
  glassClasses,
  'border text-(--plass-fg) bg-(--plass-glass-press)',
  '[border-color:var(--plass-glass-line)]',
  '[box-shadow:var(--plass-shadow-3),var(--plass-gloss-glass)]',
  '[outline:none]',
  // Opacity only. A calendar that slid into place would move the cell the
  // pointer was already reaching for.
  '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

/** The popup's own padding, one track tighter than a control's. */
export const popupPaddingClasses: Record<PlassSize, string> = {
  xs: 'p-1.5',
  sm: 'p-2',
  md: 'p-2.5',
  lg: 'p-3',
  xl: 'p-3.5'
};

/* ---------------------------------------------------------------------------
 * The shell
 * ------------------------------------------------------------------------- */

export interface PlassPickerShellProps
  extends
    PlassStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'children' | 'defaultValue'> {
  /**
   * Drop shadow depth of the *trigger*. `0`, like a `PlTextField`: a field is
   * cut into the sheet rather than resting on it. The popup has its own, fixed
   * at `3` — it genuinely floats above the page.
   * @default 0
   */
  elevation?: PlassElevation;
  /** Label above the trigger. */
  label?: React.ReactNode;
  /** Helper text below it. */
  description?: React.ReactNode;
  /** Error message below. Its presence also turns the control invalid. */
  error?: React.ReactNode;
  /** Forces the invalid state without a message. Defaults to whether `error` has content. */
  invalid?: boolean;
  /** The glyph before the value — a calendar or a clock. */
  startIcon?: React.ReactNode;
  /** Classes on the parts a `className` does not reach. */
  classNames?: PlassFieldClassNames;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  /** Unavailable. */
  disabled?: boolean;
  /** The value is shown but cannot be changed, and the popup does not open. */
  readOnly?: boolean;
  /** Whether a value must be chosen before the form is submitted. */
  required?: boolean;
  id?: string;
}

interface InternalShellProps extends PlassPickerShellProps {
  /** What the trigger reads. A placeholder when `empty`. */
  display: React.ReactNode;
  /**
   * Every string the display could hold, so the trigger stops changing width
   * with its value. `displaySamples` in `internal/date` produces them and
   * `WidthSizer` is what lays them out.
   */
  samples?: string[];
  /** Nothing has been chosen yet, so the display is muted. */
  empty: boolean;
  /** Offers the × that empties the control. */
  clearable?: boolean;
  onClear: () => void;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  labels: PlassPickerLabels;
  /** `<input type="hidden">` rows, so the control submits with a form. */
  hiddenValues?: Array<{ name: string; value: string }>;
  children: React.ReactNode;
  triggerRef?: React.Ref<HTMLButtonElement>;
}

/**
 * A trigger, a label, the two lines of text under it, and a popup.
 *
 * Everything about it that is visible is a decision already made elsewhere: the
 * shell classes, the read-only and disabled treatments, the label's type scale
 * and the way `invalid` re-points the whole colour family at `danger` so the
 * edge, the ring and the message turn over together.
 */
export function PickerShell({
  variant = 'glass',
  size = 'md',
  color = 'primary',
  density = 'default',
  elevation = 0,
  label,
  description,
  error,
  invalid,
  startIcon,
  fullWidth = false,
  disabled = false,
  readOnly = false,
  required = false,
  id,
  className,
  classNames,
  style,
  display,
  samples,
  empty,
  clearable = false,
  onClear,
  open,
  onOpenChange,
  labels,
  hiddenValues,
  children,
  triggerRef,
  ...props
}: InternalShellProps) {
  const generatedId = React.useId();
  const triggerId = id ?? `${generatedId}-trigger`;
  const labelId = `${generatedId}-label`;
  const descriptionId = `${generatedId}-description`;
  const errorId = `${generatedId}-error`;

  const hasError = error !== undefined && error !== null && error !== false && error !== '';
  const isInvalid = invalid ?? hasError;
  const family: PlassColor = isInvalid ? 'danger' : color;
  const inert = disabled || readOnly;

  const describedBy =
    [description ? descriptionId : null, hasError ? errorId : null].filter(Boolean).join(' ') ||
    undefined;

  return (
    <Field.Root
      disabled={disabled}
      invalid={isInvalid}
      className={cx(
        'flex-col align-top',
        stackGapClasses[size],
        fullWidth ? 'flex w-full' : 'inline-flex',
        className
      )}
      style={{ ...surfaceSlots(family, elevation), ...style }}
      {...props}
    >
      {label ? (
        <Field.Label
          id={labelId}
          htmlFor={triggerId}
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

      <Popover.Root open={open} onOpenChange={(next) => onOpenChange(next)}>
        <span
          className={cx(
            triggerShellClasses,
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
                ? fieldReadOnlyClasses[variant]
                : fieldRestClasses[variant],
            classNames?.control
          )}
        >
          <Popover.Trigger
            id={triggerId}
            ref={triggerRef}
            disabled={disabled}
            aria-labelledby={label ? labelId : undefined}
            aria-describedby={describedBy}
            aria-required={required || undefined}
            aria-invalid={isInvalid || undefined}
            className={cx(
              'flex min-w-0 flex-1 items-center bg-transparent text-start [font:inherit] text-inherit',
              gapClasses[size],
              '[outline:none]',
              inert ? 'cursor-default' : 'cursor-pointer'
            )}
          >
            {startIcon ? (
              <span className="flex h-[1lh] shrink-0 items-center text-(--plass-muted-fg)">
                {startIcon}
              </span>
            ) : null}
            {/* The value and, under it, every value it could be. */}
            <span className="flex min-w-0 flex-1 flex-col">
              <span
                className={cx(
                  'w-full truncate',
                  empty ? 'text-(--plass-muted-fg)' : 'text-(--plass-fg)'
                )}
              >
                {display}
              </span>
              <WidthSizer samples={samples ?? []} />
            </span>
          </Popover.Trigger>

          {clearable && !empty && !inert ? (
            <button
              type="button"
              aria-label={labels.clear}
              className={cx(chipRemoveClasses, 'text-(--plass-muted-fg)')}
              onClick={(event) => {
                event.stopPropagation();
                onClear();
              }}
            >
              <CloseIcon />
            </button>
          ) : null}
        </span>

        <Popover.Portal>
          {/* `plass-portal` is a hook, not a style: a portalled popup leaves the
              subtree a host may have scoped its CSS reset to. */}
          <Popover.Positioner
            className="plass-portal z-(--plass-z-portal) [outline:none]"
            sideOffset={6}
            align="start"
          >
            <Popover.Popup
              // Base UI is told to leave the focus alone so the calendar can take
              // it into the grid itself. Its own move would land on the popup
              // element and run *after* the grid's, undoing it.
              initialFocus={false}
              className={cx(
                pickerPopupClasses,
                radiusClasses[size],
                popupPaddingClasses[size],
                controlTextLeadingClasses[size]
              )}
              style={popupSlots(family, 3)}
            >
              {children}
            </Popover.Popup>
          </Popover.Positioner>
        </Popover.Portal>
      </Popover.Root>

      {description ? (
        <Field.Description
          id={descriptionId}
          className={cx(metaTextClasses[size], 'text-(--plass-muted-fg)', classNames?.description)}
        >
          {description}
        </Field.Description>
      ) : null}

      {hasError ? (
        <Field.Error
          id={errorId}
          match
          className={cx(metaTextClasses[size], 'text-(--p-accent)', classNames?.error)}
        >
          {error}
        </Field.Error>
      ) : null}

      {hiddenValues?.map((entry, index) => (
        <input key={index} type="hidden" name={entry.name} value={entry.value} />
      ))}
    </Field.Root>
  );
}

/* ---------------------------------------------------------------------------
 * The footer
 * ------------------------------------------------------------------------- */

/**
 * The row of shortcuts under a picker's panel.
 *
 * A hairline above it rather than a gap, because the actions act on the panel
 * and a gap would read as a second popup stacked under the first.
 */
export function PickerFooter({ size, children }: { size: PlassSize; children: React.ReactNode }) {
  return (
    <div
      className={cx(
        'flex items-center justify-end border-t pt-1.5',
        '[border-color:var(--plass-divider)]',
        gapClasses[size]
      )}
    >
      {children}
    </div>
  );
}

/** The vertical hairline between a calendar and the clock beside it. */
export function PickerDivider() {
  return <div aria-hidden="true" className="w-px self-stretch bg-(--plass-divider)" />;
}
