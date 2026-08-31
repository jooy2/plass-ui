'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { Progress } from '@base-ui/react/progress';
import {
  barThicknessClasses,
  fillTransitionClasses,
  progressAriaText,
  progressFraction,
  progressSlots,
  progressText,
  trackClasses,
  type PlassProgressProps
} from '../../internal/progress.js';
import { cx, metaTextClasses, stackGapClasses } from '../../internal/styles.js';

export interface PlProgressLinearProps extends PlassProgressProps {
  /** Thickness of the groove. Nothing else on a bar has a size. */
  size?: PlassProgressProps['size'];
}

/**
 * A bar that fills.
 *
 * The workhorse of the three: it is the only one that can show *how much* is
 * left at a glance, because length is the one quantity a reader can compare
 * without counting.
 *
 * The groove is `--plass-track`, the same neutral ink a PlSlider's rail and a
 * PlSwitch's off state are cut in, and the segment over it is the family's
 * gradient — so the filled part of the run is made of exactly the same material
 * as the button that submits the form it is in. Which is also why the movement
 * is on `width`: a gradient cannot be transitioned, and a length can.
 *
 * Both the groove and the segment are fully rounded, and that is the one place
 * the library's rule about pills does not apply. The rule protects the flat run
 * along a control's edge that a line of text sits on; at six pixels tall there
 * is no flat run left to protect, and a square-ended bar reads as a rendering
 * fault rather than as a cut edge.
 *
 * Base UI owns the semantics — `role="progressbar"`, the value and range
 * attributes, `aria-valuetext`, and dropping the value entirely when the bar is
 * indeterminate — and it computes the fill width too, so the determinate case
 * here is a class list and nothing else.
 */
export const PlProgressLinear = /* @__PURE__ */ React.forwardRef<
  HTMLDivElement,
  PlProgressLinearProps
>(function PlProgressLinear(
  {
    size: sizeProp,
    color: colorProp,
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
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';

  const fraction = progressFraction(value, min, max);
  const indeterminate = fraction === null;
  const hasFormat = format !== undefined;

  return (
    <Progress.Root
      ref={ref}
      value={value ?? null}
      min={min}
      max={max}
      format={format}
      getAriaValueText={progressAriaText(fraction, hasFormat)}
      className={cx('flex w-full flex-col', stackGapClasses[size], className)}
      style={{ ...progressSlots(color), ...style }}
      {...props}
    >
      {label || showValue ? (
        <div
          className={cx(
            'flex items-baseline gap-2',
            label ? 'justify-between' : 'justify-end',
            metaTextClasses[size]
          )}
        >
          {label ? (
            <Progress.Label className="min-w-0 truncate text-(--plass-fg)">{label}</Progress.Label>
          ) : null}
          {showValue ? (
            <Progress.Value className="shrink-0 tabular-nums text-(--plass-muted-fg)">
              {(formatted) => progressText(fraction, formatted, hasFormat)}
            </Progress.Value>
          ) : null}
        </div>
      ) : null}

      <Progress.Track
        className={cx(
          'relative w-full overflow-hidden rounded-full',
          trackClasses,
          barThicknessClasses[size]
        )}
      >
        <Progress.Indicator
          className={cx(
            'rounded-full [background-image:var(--p-fill)]',
            // `plass-progress-sweep` supplies the position, the width and the
            // animation; with a value Base UI supplies the width instead and
            // this transition is what makes it travel rather than jump. Both
            // change an inline size, never a transform.
            indeterminate ? 'plass-progress-sweep' : `absolute top-0 ${fillTransitionClasses}`
          )}
        />
      </Progress.Track>
    </Progress.Root>
  );
});
