import * as React from 'react';
import { Slider as BaseUISlider } from '@base-ui/react/slider';
import { controlSlots, metaTextClasses, transitionClasses } from '../../internal/styles';
import type { PlassColor, PlassElevation, PlassOrientation, PlassSize } from '../../types';

type BaseSliderProps = Omit<
  React.ComponentPropsWithoutRef<typeof BaseUISlider.Root>,
  'className' | 'style' | 'render' | 'children' | 'orientation'
>;

export interface PlSliderProps extends BaseSliderProps {
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /**
   * Drop shadow depth of the **thumb**. `1`, like a PlButton: the thumb is the
   * one part of a slider you press, and it rests on the sheet.
   * @default 1
   */
  elevation?: PlassElevation;
  /**
   * Which way the slider runs. A vertical slider has no length of its own, so
   * give it a height — the default `h-40` is a starting point, not a rule.
   * @default 'horizontal'
   */
  orientation?: PlassOrientation;
  /** The label above the track. */
  label?: React.ReactNode;
  /** Helper text below the track. */
  description?: React.ReactNode;
  /**
   * Shows the current value beside the label. Pass a function to format it —
   * the raw numbers and Base UI's already-localised strings are both handed in.
   * @default false
   */
  showValue?:
    boolean | ((formatted: readonly string[], values: readonly number[]) => React.ReactNode);
  /** Class names for the wrapper, not for the track. */
  className?: string;
  style?: React.CSSProperties;
}

/**
 * Groove thickness and thumb diameter.
 *
 * The thumb is deliberately far bigger than the groove — it is the only part of
 * the control you can actually hit, and a thumb sized to match a 6px rail is a
 * thumb nobody catches on a touchscreen.
 */
const trackThicknessClasses: Record<PlassSize, string> = {
  xs: 'h-1',
  sm: 'h-1.5',
  md: 'h-1.5',
  lg: 'h-2',
  xl: 'h-2.5'
};

const verticalThicknessClasses: Record<PlassSize, string> = {
  xs: 'w-1',
  sm: 'w-1.5',
  md: 'w-1.5',
  lg: 'w-2',
  xl: 'w-2.5'
};

const thumbSizeClasses: Record<PlassSize, string> = {
  xs: 'size-3',
  sm: 'size-3.5',
  md: 'size-4.5',
  lg: 'size-5',
  xl: 'size-6'
};

/**
 * The control is taller than the groove it holds so that the whole strip is a
 * pointer target, not just the rail. Base UI presses the track wherever you
 * click, and a 6px hit area would make that unusable.
 */
const trackBoxHeightClasses: Record<PlassSize, string> = {
  xs: 'h-4',
  sm: 'h-4.5',
  md: 'h-5',
  lg: 'h-6',
  xl: 'h-7'
};

const trackBoxWidthClasses: Record<PlassSize, string> = {
  xs: 'w-4',
  sm: 'w-4.5',
  md: 'w-5',
  lg: 'w-6',
  xl: 'w-7'
};

/**
 * The rail is a **groove cut into the sheet**, which is why it carries
 * `--plass-well` — the one inset shadow in the library, and the same one a
 * `solid` field is drawn with. A slider's rail and a filled text field are the
 * same idea: something recessed that holds a value.
 *
 * The indicator over it is the gradient, so the filled part of the run is made
 * of exactly the same material as the button that submits the form it is in.
 *
 * Both are pills rather than taking the radius ladder: this is a channel
 * something travels along, not a sheet.
 */
const railClasses = 'rounded-full bg-(--plass-glass-press) [box-shadow:var(--plass-well)]';
const indicatorClasses = `rounded-full [background-image:var(--p-fill)] ${transitionClasses}`;

/**
 * The thumb is a key of tinted glass on the same gradient as the run behind it,
 * separated from it by a ring in the page's own surface colour — white on a
 * light page, near-black on a dark one — so it never dissolves into the
 * indicator it is sitting on.
 *
 * It grows a halo on hover and while dragging rather than growing itself. The
 * no-transform rule is not relaxed just because this particular part carries no
 * label.
 */
const thumbClasses = [
  'rounded-full border-2 [background-image:var(--p-fill)]',
  '[border-color:var(--plass-surface)]',
  '[box-shadow:var(--p-elev),var(--p-lift)]',
  'cursor-grab select-none active:cursor-grabbing',
  transitionClasses,
  'hover:[box-shadow:var(--p-elev-hover),var(--p-lift-hover),0_0_0_4px_var(--p-soft)]',
  'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:outline-offset-2',
  'data-[dragging]:[box-shadow:var(--p-elev-press),var(--p-lift-press),0_0_0_6px_var(--p-soft-hover)]'
].join(' ');

/**
 * Disabled is the light going out, exactly as it is on every other control: the
 * shape and the place stay, the saturation and half the opacity go.
 */
const disabledSliderClasses = 'opacity-50 saturate-[0.35] [&_*]:cursor-not-allowed';

/**
 * A value chosen along a range.
 *
 * Pass an array to `value` or `defaultValue` and it becomes a range slider with
 * one thumb per entry — there is no separate `range` prop, because the shape of
 * the value already says which one this is.
 */
export const PlSlider = React.forwardRef<HTMLDivElement, PlSliderProps>(function PlSlider(
  {
    size = 'md',
    color = 'primary',
    elevation = 1,
    orientation = 'horizontal',
    label,
    description,
    showValue = false,
    disabled = false,
    className,
    style,
    ...props
  },
  ref
) {
  const vertical = orientation === 'vertical';

  // One thumb per value. The count comes off whichever of the two was given, so
  // an uncontrolled range slider works without being told it is one.
  const values = props.value ?? props.defaultValue;
  const thumbCount = Array.isArray(values) ? values.length : 1;

  return (
    <BaseUISlider.Root
      ref={ref}
      orientation={orientation}
      disabled={disabled}
      className={[
        'flex',
        vertical ? 'w-fit flex-col items-center gap-2' : 'w-full flex-col gap-1.5',
        disabled ? disabledSliderClasses : '',
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      // `solid`, always: the run and the thumb are the coloured thing, so the
      // interaction light on them is white rather than the family's own tint.
      style={{ ...controlSlots(color, elevation, 'solid'), ...style }}
      {...props}
    >
      {label || showValue ? (
        <div className={`flex w-full items-baseline gap-2 ${metaTextClasses[size]}`}>
          {label ? (
            <BaseUISlider.Label className="font-semibold text-(--plass-fg)">
              {label}
            </BaseUISlider.Label>
          ) : null}
          {showValue ? (
            <BaseUISlider.Value className="ms-auto tabular-nums text-(--plass-muted-fg)">
              {typeof showValue === 'function' ? showValue : null}
            </BaseUISlider.Value>
          ) : null}
        </div>
      ) : null}

      <BaseUISlider.Control
        className={[
          'flex touch-none items-center justify-center select-none',
          vertical
            ? `${trackBoxWidthClasses[size]} h-40 flex-col`
            : `w-full ${trackBoxHeightClasses[size]}`
        ].join(' ')}
      >
        <BaseUISlider.Track
          className={[
            railClasses,
            vertical
              ? `${verticalThicknessClasses[size]} h-full`
              : `${trackThicknessClasses[size]} w-full`
          ].join(' ')}
        >
          <BaseUISlider.Indicator className={indicatorClasses} />
          {Array.from({ length: thumbCount }, (_, index) => (
            <BaseUISlider.Thumb
              key={index}
              index={index}
              className={`${thumbClasses} ${thumbSizeClasses[size]}`}
            />
          ))}
        </BaseUISlider.Track>
      </BaseUISlider.Control>

      {description ? (
        <div className={`${metaTextClasses[size]} text-(--plass-muted-fg)`}>{description}</div>
      ) : null}
    </BaseUISlider.Root>
  );
});
