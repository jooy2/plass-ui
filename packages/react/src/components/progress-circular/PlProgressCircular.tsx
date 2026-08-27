import * as React from 'react';
import { Progress } from '@base-ui/react/progress';
import {
  progressAriaText,
  progressFraction,
  progressSlots,
  progressText,
  ringDiameters,
  ringStrokes,
  type PlassProgressProps
} from '../../internal/progress.js';
import { cx, gapClasses, metaTextClasses } from '../../internal/styles.js';

export interface PlProgressCircularProps extends PlassProgressProps {
  /** Diameter of the ring. Sits just under the control ladder at every step. */
  size?: PlassProgressProps['size'];
}

/**
 * A ring that fills, and the one to reach for where there is no room for a bar
 * — inside a button, at the end of a table row, next to a field.
 *
 * The arc is the family's gradient rather than a flat colour, which takes a
 * `<linearGradient>` of its own: an SVG stroke cannot be given a CSS gradient,
 * so the two ends of the fill are lifted out of the slots and rebuilt at 135°.
 * It is worth the extra element — a flat ring beside a swept bar is two
 * materials for one idea.
 *
 * The value and the label sit *beside* the ring rather than inside it. A number
 * in the middle of a dial is the picture everyone has of this component, and it
 * only works at two of the five sizes: at `xs` the ring is fourteen pixels
 * across and there is nowhere for "40%" to go. Beside it, every size reads.
 */
export const PlProgressCircular = /* @__PURE__ */ React.forwardRef<
  HTMLDivElement,
  PlProgressCircularProps
>(function PlProgressCircular(
  {
    size = 'md',
    color = 'primary',
    value = null,
    min = 0,
    max = 100,
    label,
    showValue = false,
    format,
    className,
    style,
    ...props
  },
  ref
) {
  const fraction = progressFraction(value, min, max);
  const indeterminate = fraction === null;
  const hasFormat = format !== undefined;
  const gradientId = `${React.useId()}-fill`;

  const diameter = ringDiameters[size];
  const stroke = ringStrokes[size];
  const centre = diameter / 2;
  // The stroke straddles the path, so the radius has to come in by half of it
  // or the ring is clipped by its own viewBox.
  const radius = centre - stroke / 2;
  const circumference = 2 * Math.PI * radius;

  // Indeterminate draws a fixed quarter-arc and turns; determinate holds still
  // and lets the gap close. Both are one dash pattern on one circle.
  const dashArray = indeterminate ? `${circumference * 0.28} ${circumference}` : `${circumference}`;
  const dashOffset = indeterminate ? 0 : circumference * (1 - fraction);

  return (
    <Progress.Root
      ref={ref}
      value={value ?? null}
      min={min}
      max={max}
      format={format}
      getAriaValueText={progressAriaText(fraction, hasFormat)}
      className={cx('inline-flex items-center', gapClasses[size], metaTextClasses[size], className)}
      style={{ ...progressSlots(color), ...style }}
      {...props}
    >
      <svg
        // The rotation is on the whole `<svg>` and not on a group inside it:
        // `transform-origin: center` resolves against an element's border box,
        // which an SVG child does not have one of unless `transform-box` is set
        // as well. One element, one rule, no surprises across browsers.
        className={cx('shrink-0', indeterminate && 'plass-ring-spin')}
        width={diameter}
        height={diameter}
        viewBox={`0 0 ${diameter} ${diameter}`}
        fill="none"
        aria-hidden="true"
      >
        <defs>
          {/* 135°: the top-left corner to the bottom-right one, which is where
              every other gradient in the library is lit from. */}
          <linearGradient id={gradientId} x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="var(--p-solid)" />
            <stop offset="100%" stopColor="var(--p-solid-to)" />
          </linearGradient>
        </defs>

        <circle
          cx={centre}
          cy={centre}
          r={radius}
          stroke="var(--plass-track)"
          strokeWidth={stroke}
        />
        <circle
          cx={centre}
          cy={centre}
          r={radius}
          stroke={`url(#${gradientId})`}
          strokeWidth={stroke}
          strokeLinecap="round"
          strokeDasharray={dashArray}
          strokeDashoffset={dashOffset}
          // An SVG geometry attribute rather than a CSS transform: this is where
          // the arc starts, not something the ring does when its state changes.
          // Without it a determinate ring would fill from three o'clock.
          transform={`rotate(-90 ${centre} ${centre})`}
          className="[transition:stroke-dashoffset_var(--plass-duration-slow)_var(--plass-ease)]"
        />
      </svg>

      {label ? (
        <Progress.Label className="min-w-0 truncate text-(--plass-fg)">{label}</Progress.Label>
      ) : null}
      {showValue ? (
        <Progress.Value className="shrink-0 tabular-nums text-(--plass-muted-fg)">
          {(formatted) => progressText(fraction, formatted, hasFormat)}
        </Progress.Value>
      ) : null}
    </Progress.Root>
  );
});
