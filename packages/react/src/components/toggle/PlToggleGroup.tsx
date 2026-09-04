'use client';

import * as React from 'react';
import { ToggleGroup as BaseUIToggleGroup } from '@base-ui/react/toggle-group';
import {
  ButtonGroupContext,
  groupBaseClasses,
  groupJoinClasses,
  groupOverlapClasses,
  type PlassButtonGroupContextValue
} from '../../internal/button-group.js';
import { cx } from '../../internal/styles.js';
import type {
  PlassElevation,
  PlassOrientation,
  PlassStyleProps,
  PlassVariant
} from '../../types.js';

export interface PlToggleGroupProps
  extends
    PlassStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /** Passed to every toggle in the set. @default 'glass' */
  variant?: PlassVariant;
  /**
   * Which toggles are on, by their `value`. An array in both the single and the
   * multiple case — Base UI's own shape, and the one that does not change type
   * when `multiple` is turned on.
   */
  value?: readonly string[];
  /** Which start on, for an uncontrolled set. */
  defaultValue?: readonly string[];
  onValueChange?: (value: string[]) => void;
  /**
   * Whether more than one can be on at a time. Off, turning one on turns the
   * last one off — which is a one-of-a-set, and worth a second thought: if the
   * choice is a *value* rather than a state, that is a `PlSegmentedButton` or a
   * `PlRadioGroup`.
   * @default false
   */
  multiple?: boolean;
  /** Which way the toggles run. @default 'horizontal' */
  orientation?: PlassOrientation;
  /** Drop shadow depth, passed to every toggle in the set. @default 0 */
  elevation?: PlassElevation;
  /** Disables every toggle in the set at once. */
  disabled?: boolean;
  /** Whether the arrow keys wrap around at the ends. @default true */
  loopFocus?: boolean;
  /** Stretches to the container and divides the width evenly between toggles. */
  fullWidth?: boolean;
  children?: React.ReactNode;
}

/**
 * A set of toggles that share one state.
 *
 * Two things are happening and only one of them is visual. The corners facing a
 * neighbour are squared off — that is the look. The other half is that the set
 * owns the value: the toggles report into one array, `multiple` decides whether
 * more than one of them can be on, and `variant`, `size`, `color`, `density`,
 * `elevation` and `disabled` are set once here rather than on every toggle.
 *
 * Base UI owns the roving tab index — one tab stop for the whole set, arrow keys
 * between the members — which is what makes a toolbar of eight toggles two key
 * presses deep instead of eight.
 */
export const PlToggleGroup = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlToggleGroupProps>(
  function PlToggleGroup(
    {
      variant,
      size,
      color,
      density,
      elevation,
      value,
      defaultValue,
      onValueChange,
      multiple = false,
      orientation = 'horizontal',
      disabled,
      loopFocus = true,
      fullWidth = false,
      className,
      children,
      ...props
    },
    ref
  ) {
    // Every value passes through as it is, `undefined` included: a `PlToggle`
    // reads the group only as a fallback, so "not set here" keeps meaning "use
    // the toggle's own default" rather than turning into one.
    const context = React.useMemo<PlassButtonGroupContextValue>(
      () => ({ variant, size, color, density, elevation, disabled }),
      [variant, size, color, density, elevation, disabled]
    );

    return (
      <ButtonGroupContext.Provider value={context}>
        <BaseUIToggleGroup
          ref={ref}
          value={value}
          defaultValue={defaultValue}
          onValueChange={(next) => onValueChange?.(next)}
          multiple={multiple}
          orientation={orientation}
          disabled={disabled}
          loopFocus={loopFocus}
          className={cx(
            groupBaseClasses,
            orientation === 'vertical' ? 'flex-col' : 'flex-row',
            groupJoinClasses[orientation],
            // A `PlToggle` defaults to `glass`, so a group that says nothing is
            // a hairline group and does need the overlap.
            (variant ?? 'glass') === 'glass' ? groupOverlapClasses[orientation] : '',
            fullWidth ? 'flex w-full [&>*]:flex-1' : '',
            className
          )}
          {...props}
        >
          {children}
        </BaseUIToggleGroup>
      </ButtonGroupContext.Provider>
    );
  }
);
