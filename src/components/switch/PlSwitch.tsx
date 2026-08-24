import * as React from 'react';
import { Switch as BaseUISwitch } from '@base-ui/react/switch';
import { Field } from '@base-ui/react/field';
import {
  controlSlots,
  controlTextClasses,
  glassClasses,
  hasContent,
  metaTextClasses,
  tickRowLeadingClasses
} from '../../internal/styles';
import type { PlassAlign, PlassColor, PlassSize } from '../../types';

/** Which side of the track the label sits on. */
export type PlSwitchLabelPlacement = Extract<PlassAlign, 'start' | 'end'>;

type BaseSwitchProps = Omit<
  React.ComponentPropsWithoutRef<typeof BaseUISwitch.Root>,
  'className' | 'style' | 'render' | 'children'
>;

export interface PlSwitchProps extends BaseSwitchProps {
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** The text beside the track. Wired to it by Base UI's Field. */
  label?: React.ReactNode;
  /** Helper text under the label. */
  description?: React.ReactNode;
  /** Error message below. Its presence also turns the switch invalid. */
  error?: React.ReactNode;
  /**
   * Forces the invalid state without a message — for when an external form
   * library owns the validity. Defaults to whether `error` has content.
   */
  invalid?: boolean;
  /**
   * Which side the label sits on. `end` reads as a caption for the control;
   * `start` is for a settings list, where the labels form a column and every
   * switch lines up on the right.
   * @default 'end'
   */
  labelPlacement?: PlSwitchLabelPlacement;
  /** Class names for the field wrapper, not for the track. */
  className?: string;
  style?: React.CSSProperties;
}

/**
 * Track and thumb.
 *
 * The thumb is inset 2px on every side, so its diameter is the track's height
 * minus 4 and the `left` it travels to is `100% − 2px − diameter`. That is the
 * one number per step that has to be written out; everything else falls out of
 * `inset-y-0.5` and `aspect-square`.
 */
const trackClasses: Record<PlassSize, string> = {
  xs: 'h-3.5 w-6',
  sm: 'h-4 w-7',
  md: 'h-5 w-9',
  lg: 'h-6 w-11',
  xl: 'h-7 w-13'
};

const thumbTravelClasses: Record<PlassSize, string> = {
  xs: 'data-[checked]:left-[calc(100%-0.75rem)]',
  sm: 'data-[checked]:left-[calc(100%-0.875rem)]',
  md: 'data-[checked]:left-[calc(100%-1.125rem)]',
  lg: 'data-[checked]:left-[calc(100%-1.375rem)]',
  xl: 'data-[checked]:left-[calc(100%-1.625rem)]'
};

/**
 * A pill, and one of the two places in the library that is right.
 *
 * Everywhere else the radius stops well short of 50%, because the flat run
 * along the top and bottom edge is what reads as a sheet with its corners cut
 * off. A switch is not a sheet — it is a track something runs along, and a
 * track with corners is a track the thumb would have to climb out of.
 */
const trackBaseClasses = [
  'relative inline-flex shrink-0 border rounded-full',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  // `background-image` is in the list because the on state is the gradient, and
  // `left` deliberately is not: it belongs to the thumb, which is the one thing
  // in the library that actually moves.
  '[transition-property:background-color,background-image,border-color,box-shadow]',
  '[transition-duration:var(--plass-duration)]',
  '[transition-timing-function:var(--plass-ease)]',
  'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:outline-offset-2'
].join(' ');

/**
 * Off, the track is the **groove** — the glass at its most opaque with
 * `--plass-well` falling into it, the same inset shadow a `solid` field is
 * drawn with. On, it is the family's gradient, and the groove's shadow goes
 * with the recess: something that is on is not something you are looking into.
 *
 * There is no gloss line on it, for the reason a PlCheckbox's tick has none: a
 * 1px white hairline around a 20px groove is a bevel rather than light on a cut
 * edge, and a bevelled groove with a domed thumb in it is the skeuomorphic
 * switch this design language is not.
 *
 * The edge is `--plass-border` rather than the sheet's own `--plass-glass-line`,
 * and that is not a slip. The glass hairline is white light on a translucent
 * pane, which is invisible the moment the tick is set on a light card rather
 * than on the page wash — and a tick nobody can see is a control nobody can
 * find. A neutral hairline reads on both.
 */
const restTrackClasses = [
  glassClasses,
  'cursor-pointer bg-(--plass-glass-press) [border-color:var(--plass-border)]',
  '[box-shadow:var(--plass-well)]',
  'hover:[border-color:var(--p-line)]',
  'data-[checked]:[background-image:var(--p-fill)] data-[checked]:[border-color:transparent]',
  'data-[checked]:[box-shadow:var(--p-lift)] data-[checked]:hover:brightness-105'
].join(' ');

const readOnlyTrackClasses = [
  glassClasses,
  'cursor-default bg-(--plass-glass-press) [border-color:var(--plass-border)]',
  '[box-shadow:var(--plass-well)] saturate-[0.55]',
  'data-[checked]:[background-image:var(--p-fill)] data-[checked]:[border-color:transparent]',
  'data-[checked]:shadow-none'
].join(' ');

const disabledTrackClasses = [
  glassClasses,
  'cursor-not-allowed bg-(--plass-glass-press) [border-color:var(--plass-border)]',
  'opacity-50 saturate-[0.35] shadow-none',
  'data-[checked]:[background-image:var(--p-fill)] data-[checked]:[border-color:transparent]'
].join(' ');

/**
 * The thumb keeps the page's surface colour in both states rather than taking
 * the accent: it is the light on the track, not a second coloured object, and a
 * coloured thumb on a coloured track is two things fighting over sixteen
 * pixels.
 */
const thumbClasses = [
  'absolute inset-y-0.5 left-0.5 aspect-square rounded-full bg-(--plass-surface)',
  '[box-shadow:var(--plass-shadow-1)]',
  '[transition:left_var(--plass-duration)_var(--plass-ease)]'
].join(' ');

/**
 * An immediate on/off.
 *
 * The difference from a PlCheckbox is not visual, it is temporal: a checkbox is
 * a value that gets submitted with a form, a switch takes effect the moment it
 * moves. If there is a Save button underneath, it should have been a checkbox.
 */
export const PlSwitch = React.forwardRef<HTMLElement, PlSwitchProps>(function PlSwitch(
  {
    size = 'md',
    color = 'primary',
    label,
    description,
    error,
    invalid,
    labelPlacement = 'end',
    disabled = false,
    readOnly = false,
    className,
    style,
    ...props
  },
  ref
) {
  const hasError = hasContent(error);
  const isInvalid = invalid ?? hasError;
  const family: PlassColor = isInvalid ? 'danger' : color;

  const track = (
    <span className="flex h-[1lh] shrink-0 items-center">
      <BaseUISwitch.Root
        ref={ref}
        className={[
          trackBaseClasses,
          trackClasses[size],
          disabled ? disabledTrackClasses : readOnly ? readOnlyTrackClasses : restTrackClasses
        ].join(' ')}
        disabled={disabled}
        readOnly={readOnly}
        {...props}
      >
        <BaseUISwitch.Thumb className={`${thumbClasses} ${thumbTravelClasses[size]}`} />
      </BaseUISwitch.Root>
    </span>
  );

  const text =
    label || description ? (
      <span
        className={[
          'flex min-w-0 flex-col gap-0.5',
          // With the label on the left it has to take the slack, or the switch
          // sits against the text instead of against the edge of the row.
          labelPlacement === 'start' ? 'flex-1' : ''
        ]
          .filter(Boolean)
          .join(' ')}
      >
        {label ? (
          <Field.Label
            className={[
              'leading-[1.4]',
              disabled ? 'text-(--plass-muted-fg)' : 'cursor-pointer text-(--plass-fg)'
            ].join(' ')}
          >
            {label}
          </Field.Label>
        ) : null}
        {description ? (
          <Field.Description className={`${metaTextClasses[size]} text-(--plass-muted-fg)`}>
            {description}
          </Field.Description>
        ) : null}
      </span>
    ) : null;

  return (
    <Field.Root
      disabled={disabled}
      invalid={isInvalid}
      className={['inline-flex flex-col gap-1 align-top', className ?? '']
        .filter(Boolean)
        .join(' ')}
      // `solid`, because an on track *is* the coloured thing.
      style={{ ...controlSlots(family, 0, 'solid'), ...style }}
    >
      <div
        className={`flex items-start gap-2.5 ${controlTextClasses[size]} ${tickRowLeadingClasses}`}
      >
        {labelPlacement === 'start' ? (
          <>
            {text}
            {track}
          </>
        ) : (
          <>
            {track}
            {text}
          </>
        )}
      </div>

      {hasError ? (
        <Field.Error match className={`${metaTextClasses[size]} text-(--p-accent)`}>
          {error}
        </Field.Error>
      ) : null}
    </Field.Root>
  );
});
