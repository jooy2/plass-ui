'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { Progress } from '@base-ui/react/progress';
import {
  fillTransitionClasses,
  plateGapClasses,
  plateRadiusClasses,
  plateSizeClasses,
  progressAriaText,
  progressFraction,
  progressSlots,
  progressText,
  trackClasses,
  type PlassProgressProps
} from '../../internal/progress.js';
import { cx, metaTextClasses, stackGapClasses } from '../../internal/styles.js';

export interface PlProgressBoxProps extends PlassProgressProps {
  /** Size of one plate. */
  size?: PlassProgressProps['size'];
  /**
   * How many plates the row is made of.
   *
   * Four by default: enough that the wave reads as a wave, few enough that a
   * determinate row can be counted at a glance rather than measured. Set it to
   * the number of steps when the thing being waited on genuinely has steps.
   * @default 4
   */
  count?: number;
}

/**
 * A row of small glass plates that light up.
 *
 * The third shape, and the one that is about the material rather than about the
 * quantity. A bar and a ring both say "this much of it is done"; a row of
 * plates says "this is working" in the library's own vocabulary — the same
 * groove, the same corner, the same gradient — which is what makes it the right
 * one for a loading state inside a Plass surface, where a foreign grey spinner
 * would look borrowed.
 *
 * It answers a value when it has one: the plates fill in order, the leading one
 * partially, so four plates read as a four-segment bar rather than as four
 * quarters. Without a value they cycle, each held back by its own index — and
 * what cycles is the fill's **opacity**, because a gradient has no interpolation
 * between itself and nothing.
 */
export const PlProgressBox = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlProgressBoxProps>(
  function PlProgressBox(
    {
      size: sizeProp,
      color: colorProp,
      count = 4,
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
    // A row of no plates is not a loading indicator, and a fractional count is a
    // caller who divided something. Both land on one plate rather than on none.
    const plates = Math.max(1, Math.floor(count));

    return (
      <Progress.Root
        ref={ref}
        value={value ?? null}
        min={min}
        max={max}
        format={format}
        getAriaValueText={progressAriaText(fraction, hasFormat)}
        className={cx('inline-flex flex-col', stackGapClasses[size], className)}
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
              <Progress.Label className="min-w-0 truncate text-(--plass-fg)">
                {label}
              </Progress.Label>
            ) : null}
            {showValue ? (
              <Progress.Value className="shrink-0 tabular-nums text-(--plass-muted-fg)">
                {(formatted) => progressText(fraction, formatted, hasFormat)}
              </Progress.Value>
            ) : null}
          </div>
        ) : null}

        <Progress.Track className={cx('flex', plateGapClasses[size])}>
          {Array.from({ length: plates }, (_, index) => (
            <span
              key={index}
              className={cx(
                'relative overflow-hidden',
                trackClasses,
                plateSizeClasses[size],
                plateRadiusClasses[size]
              )}
            >
              {/* The plate is a groove of its own, so the leading one can be part
                  full. Without that, four plates could only ever show 0, 25, 50,
                  75 or 100 and a value of 30% would round away to a quarter. */}
              <span
                aria-hidden="true"
                className={cx(
                  'absolute inset-y-0 start-0 [background-image:var(--p-fill)]',
                  indeterminate ? 'plass-plate-wave w-full' : fillTransitionClasses
                )}
                style={
                  indeterminate
                    ? ({ '--p-i': index } as React.CSSProperties)
                    : {
                        width: `${Math.min(100, Math.max(0, (fraction * plates - index) * 100))}%`
                      }
                }
              />
            </span>
          ))}
        </Progress.Track>
      </Progress.Root>
    );
  }
);
