import * as React from 'react';
import { Field } from '@base-ui/react/field';
import { Popover } from '@base-ui/react/popover';
import { FormControl, leaveFormControl } from './form.js';
import { glowPointerMove } from './glow.js';
import { CloseIcon } from './icons.js';
import { WidthSizer } from './sizer.js';
import { FieldNotch, notchShellStyle } from './notch.js';
import { useDefaults } from './defaults.js';
import {
  chipRemoveClasses,
  controlHeightClasses,
  controlTextLeadingClasses,
  cx,
  disabledClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  fieldSlots,
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
} from './styles.js';
import type { PlassPickerLabels } from './calendar.js';
import type {
  PlassColor,
  PlassElevation,
  PlassFieldClassNames,
  PlassFieldLabelPlacement,
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
  iconClasses
].join(' ');

/**
 * The ring, added at the call site rather than above: a notched trigger does
 * not have one. An outline is a rectangle and the label is sitting on the edge
 * it would be drawn along, so there the edge itself thickens instead. See
 * `internal/notch`.
 */
const triggerRingClasses = focusWithinRingClasses;

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
 * The arrow
 * ------------------------------------------------------------------------- */

/**
 * Where a side puts the wedge, and which way it is turned.
 *
 * Base UI positions it and reports which side the popup ended up on. It is
 * drawn pointing down once and turned to match — a rotation of a glyph, which
 * is the one allowance the no-transform rule makes. The `-1px` is what tucks
 * the wedge's base under the plate's own border so the two hairlines meet.
 */
const arrowSideClasses = /* @__PURE__ */ [
  'data-[side=top]:bottom-[-1px]',
  'data-[side=bottom]:top-[-1px] data-[side=bottom]:rotate-180',
  'data-[side=left]:right-[-1px] data-[side=left]:-rotate-90',
  'data-[side=right]:left-[-1px] data-[side=right]:rotate-90'
].join(' ');

export interface PopupArrowProps {
  /**
   * The `Arrow` part of whichever Base UI popup this is — `Popover.Arrow`,
   * `PreviewCard.Arrow`, `Tooltip.Arrow`. Each of the three roots has its own,
   * and only the primitive knows where to put it.
   */
  as: React.ElementType<{ className?: string; children?: React.ReactNode }>;
  /** How wide the wedge is, in pixels. Its height is half of that. */
  size: number;
}

/**
 * The wedge that points a floating sheet at what opened it.
 *
 * One drawing for all three, and it is the *stroked* one: a triangle filled
 * with the sheet's own `--plass-glass-press`, with the hairline drawn along its
 * two slanted sides only.
 *
 * Both of those are the glass rules rather than a preference. The fill is the
 * same one declaration the plate carries, so the wedge stays on the plate's
 * rung of the opacity ladder — a wedge stacked out of a line triangle and a
 * fill triangle composites two translucent whites and comes out lighter than
 * the sheet it grew from, which in the dark theme is 0.25 against the plate's
 * 0.15. And `--plass-glass-line` is a cut edge rather than a colour to fill
 * with, so it is stroked: on the two sides that are a cut edge, and not across
 * the base, which is not one — the plate is on the other side of it.
 *
 * `non-scaling-stroke` is what keeps that hairline one pixel at every `size`.
 * The path is written in a 10×5 viewBox and the box is drawn at whatever the
 * component's ladder says, so a stroke that scaled would be thinner than the
 * plate's border on a small sheet and thicker on a large one.
 */
export function PopupArrow({ as: Arrow, size }: PopupArrowProps) {
  return (
    <Arrow className={arrowSideClasses}>
      <svg width={size} height={size / 2} viewBox="0 0 10 5" aria-hidden="true" className="block">
        <path d="M0 0h10L5 5z" fill="var(--plass-glass-press)" />
        <path
          d="M0 0 5 5 10 0"
          fill="none"
          stroke="var(--plass-glass-line)"
          strokeWidth="1"
          vectorEffect="non-scaling-stroke"
        />
      </svg>
    </Arrow>
  );
}

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
  /** The name of what the control holds. */
  label?: React.ReactNode;
  /**
   * Where the `label` goes — above the trigger, or in its top edge.
   * Falls back to the nearest `PlassProvider`, then to `top`.
   * @default 'top'
   */
  labelPlacement?: PlassFieldLabelPlacement;
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
  /** The name the value submits under. */
  name?: string;
  /**
   * The value as a form submits it: one string, or one row per entry. An empty
   * string, a list with an empty entry and an empty list are no value.
   */
  formValue: string | readonly string[];
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
  labelPlacement: labelPlacementProp,
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
  name,
  formValue,
  children,
  triggerRef,
  ...props
}: InternalShellProps) {
  const generatedId = React.useId();
  const triggerId = id ?? `${generatedId}-trigger`;
  const labelId = `${generatedId}-label`;
  const valueId = `${generatedId}-value`;
  const descriptionId = `${generatedId}-description`;
  const errorId = `${generatedId}-error`;

  // Read here rather than in each of the six pickers that draw this shell: they
  // all hand their shell props straight through, and one resolution cannot
  // disagree with itself the way six can.
  const defaults = useDefaults();
  const labelPlacement = labelPlacementProp ?? defaults.labelPlacement ?? 'top';
  // A notch with nothing in it is a gap in the edge for no reason, so the
  // placement only takes effect where there is a label to put there.
  const notched = labelPlacement === 'notch' && hasContent(label);

  const hasError = error !== undefined && error !== null && error !== false && error !== '';
  const isInvalid = invalid ?? hasError;
  const family: PlassColor = isInvalid ? 'danger' : color;
  const lit = !disabled && !readOnly;
  const inert = disabled || readOnly;
  const controlRef = React.useRef<HTMLInputElement>(null);

  // One element for both placements, so the label a reader clicks and the label
  // a screen reader reads are the same element wherever it is drawn.
  const labelNode = (
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
  );

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
      style={{ ...fieldSlots(family, elevation), ...style }}
      {...props}
    >
      {hasContent(label) && !notched ? labelNode : null}

      <Popover.Root open={open} onOpenChange={(next) => onOpenChange(next)}>
        <FieldNotch
          notched={notched}
          size={size}
          density={density}
          variant={variant}
          disabled={disabled}
          readOnly={readOnly}
          label={labelNode}
        >
          <span
            style={notched ? notchShellStyle : undefined}
            onPointerMove={glowPointerMove(lit)}
            className={cx(
              triggerShellClasses,
              notched ? '' : triggerRingClasses,
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
              // The interaction light, on the trigger rather than on the popup
              // it opens: a trigger is a field, and what a pointer is over is
              // the box the reader sees. A locked one carries none, because the
              // light is a claim that the surface answers.
              lit ? 'plass-glow' : '',
              classNames?.control
            )}
          >
            {/* What made the field invalid is not only the caller's `error`: an
              empty `required` value and a `PlForm`'s `errors` do too, and the
              trigger has to say so as an input would. */}
            <Field.Validity>
              {({ validity }) => {
                const failed = validity.valid === false;
                // Base UI's own message, the second `Field.Error` below, shows for
                // a failure the caller did not force with `invalid`.
                const message = hasError || (failed && !disabled && invalid !== true);
                const describedBy =
                  [description ? descriptionId : null, message ? errorId : null]
                    .filter(Boolean)
                    .join(' ') || undefined;

                return (
                  <Popover.Trigger
                    id={triggerId}
                    ref={triggerRef}
                    disabled={disabled}
                    // The label and then the value, as a native select is read: the name
                    // alone would leave the chosen date or colour to be found by opening it.
                    aria-labelledby={label ? `${labelId} ${valueId}` : undefined}
                    aria-describedby={describedBy}
                    aria-required={required || undefined}
                    aria-invalid={isInvalid || failed || undefined}
                    onBlur={() => {
                      // Focus that moves into the open popup has not left the control.
                      if (!open) {
                        leaveFormControl(controlRef.current);
                      }
                    }}
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
                        id={valueId}
                        className={cx(
                          'w-full truncate',
                          empty ? 'text-(--plass-muted-fg)' : 'text-(--plass-fg)'
                        )}
                      >
                        {display}
                      </span>
                      {/* A `fullWidth` trigger takes its width from its container, so
                      it renders no samples: every value written there would be
                      work for nothing. */}
                      {fullWidth ? null : <WidthSizer samples={samples ?? []} />}
                    </span>
                  </Popover.Trigger>
                );
              }}
            </Field.Validity>

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
        </FieldNotch>

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
          className={cx(
            'm-0',
            metaTextClasses[size],
            'text-(--plass-muted-fg)',
            classNames?.description
          )}
        >
          {description}
        </Field.Description>
      ) : null}

      {/* Two branches, as in `PlTextField`: the caller's message when there is
          one, and otherwise Base UI's — the browser's constraint message or a
          `PlForm`'s entry for this `name`. */}
      {hasError ? (
        <Field.Error
          id={errorId}
          match
          className={cx(metaTextClasses[size], 'text-(--p-accent)', classNames?.error)}
        >
          {error}
        </Field.Error>
      ) : (
        <Field.Error
          id={errorId}
          className={cx(metaTextClasses[size], 'text-(--p-accent)', classNames?.error)}
        />
      )}

      <FormControl
        ref={controlRef}
        name={name}
        value={formValue}
        // A read-only input is not validated either.
        required={required && !readOnly}
        disabled={disabled}
        standIn={() => controlRef.current?.ownerDocument.getElementById(triggerId)}
      />
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
