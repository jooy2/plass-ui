import * as React from 'react';
import { Switch as BaseUISwitch } from '@base-ui/react/switch';
import { Field } from '@base-ui/react/field';
import {
  controlSlots,
  focusRingClasses,
  hasContent,
  metaTextClasses,
  tickRowTextClasses
} from '../../internal/styles.js';
import type { PlassAlign, PlassColor, PlassSize } from '../../types.js';

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
const trackBaseClasses = /* @__PURE__ */ [
  'relative inline-flex shrink-0 rounded-full',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  // `background-image` is in the list because the on state is the gradient, and
  // `left` deliberately is not: it belongs to the thumb, which is the one thing
  // in the library that actually moves.
  '[transition-property:background-color,background-image,box-shadow,filter]',
  '[transition-duration:var(--plass-duration)]',
  '[transition-timing-function:var(--plass-ease)]',
  focusRingClasses
].join(' ');

/**
 * Off, the track is the **groove** — `--plass-track`, the one neutral ink in the
 * library whose job is to be seen from across a room. On, it is the family's
 * gradient.
 *
 * Off used to be the glass at its most opaque with `--plass-well` falling into
 * it, and it was wrong twice over. It was invisible: a 88%-white pill with a
 * white thumb in it, set on a near-white page, is a switch a reader cannot find
 * until they have already flipped it — and the off state is the one a settings
 * list is mostly made of. And where it *was* visible, in the dark, an inset
 * shadow under a thumb carrying a drop shadow of its own was a moulded rocker
 * in a bevelled slot, which is the one picture this design language exists to
 * not draw.
 *
 * So there is no well, no gloss and no edge either. A groove that is a *tone*
 * rather than a recess needs no hairline to say where it ends, and the hairline
 * it used to have was the second of two lines round the same object once the
 * focus ring arrived.
 *
 * Dropping the border also squares the thumb's travel. `inset-y-0.5` and
 * `left-0.5` are measured from the padding box; the `left` a checked thumb
 * travels to is measured from the track's *width*. With a 1px edge between
 * them the two disagreed, and every switch in the library sat 2px from its
 * track on the left and 4px from it on the right.
 */
const restTrackClasses = /* @__PURE__ */ [
  'cursor-pointer bg-(--plass-track)',
  'hover:brightness-[0.97] dark:hover:brightness-110',
  'data-[checked]:[background-image:var(--p-fill)]',
  'data-[checked]:[box-shadow:var(--p-lift)] data-[checked]:hover:brightness-105'
].join(' ');

const readOnlyTrackClasses = /* @__PURE__ */ [
  'cursor-default bg-(--plass-track) saturate-[0.55]',
  'data-[checked]:[background-image:var(--p-fill)]',
  'data-[checked]:shadow-none'
].join(' ');

const disabledTrackClasses = /* @__PURE__ */ [
  'cursor-not-allowed bg-(--plass-track)',
  'opacity-50 saturate-[0.35] shadow-none',
  'data-[checked]:[background-image:var(--p-fill)]'
].join(' ');

/**
 * The thumb is white in both themes — not `--plass-surface`, which is a near
 * navy in the dark and left the off state as a grey lozenge in a grey slot.
 *
 * It keeps a shadow, and it is the smallest one on the ladder rather than the
 * `--plass-shadow-1` it used to carry: the thumb is the one part of a switch
 * that genuinely is above the surface it moves along, so it casts something —
 * but a 14px disc under a 4px-blurred, 14px-wide shadow is a knob, not a light.
 */
const thumbClasses = /* @__PURE__ */ [
  'absolute inset-y-0.5 left-0.5 aspect-square rounded-full bg-white',
  '[box-shadow:0_1px_2px_rgb(20_40_90/0.25)]',
  '[transition:left_var(--plass-duration)_var(--plass-ease)]'
].join(' ');

/**
 * An immediate on/off.
 *
 * The difference from a PlCheckbox is not visual, it is temporal: a checkbox is
 * a value that gets submitted with a form, a switch takes effect the moment it
 * moves. If there is a Save button underneath, it should have been a checkbox.
 */
export const PlSwitch = /* @__PURE__ */ React.forwardRef<HTMLElement, PlSwitchProps>(
  function PlSwitch(
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
              className={disabled ? 'text-(--plass-muted-fg)' : 'cursor-pointer text-(--plass-fg)'}
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
        <div className={`flex items-start gap-2.5 ${tickRowTextClasses[size]}`}>
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
  }
);
