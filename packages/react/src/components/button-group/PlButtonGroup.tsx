'use client';

import * as React from 'react';
import {
  ButtonGroupContext,
  groupBaseClasses,
  groupJoinClasses,
  groupOverlapClasses,
  type PlassButtonGroupContextValue
} from '../../internal/button-group.js';
import { cx } from '../../internal/styles.js';
import type { PlassElevation, PlassOrientation, PlassStyleProps } from '../../types.js';

export interface PlButtonGroupProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Which way the buttons run. A vertical group is a stacked menu of equal
   * actions; a horizontal one is the default because that is what a toolbar is.
   * @default 'horizontal'
   */
  orientation?: PlassOrientation;
  /** Drop shadow depth, passed to every button in the group. */
  elevation?: PlassElevation;
  /** Disables every button in the group at once. */
  disabled?: boolean;
  /** Stretches to the container and divides the width evenly between buttons. */
  fullWidth?: boolean;
  children?: React.ReactNode;
}

/**
 * A run of buttons that belong together.
 *
 * Two things are happening here and only one of them is visual. The corners
 * that face a neighbour are squared off — that is the look. The other half is
 * that `variant`, `size`, `color`, `density`, `elevation` and `disabled` are
 * stated once for the set rather than repeated on every button; a group where
 * one button is a size out is the failure this exists to prevent.
 *
 * The buttons stay real `PlButton`s and nothing about them is replaced. Which
 * also means this is **not** a segmented control and it does not manage
 * selection: for one-of-a-set reach for `PlSegmentedButton`, which is what that
 * actually is.
 */
export const PlButtonGroup = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlButtonGroupProps>(
  function PlButtonGroup(
    {
      variant,
      size,
      color,
      density,
      elevation,
      orientation = 'horizontal',
      disabled,
      fullWidth = false,
      className,
      children,
      ...props
    },
    ref
  ) {
    // Every value is passed through as it arrived, `undefined` included. A
    // PlButton reads the group only as a fallback, so "not set here" goes on
    // meaning "use the button's own default" rather than turning into one.
    const context = React.useMemo<PlassButtonGroupContextValue>(
      () => ({ variant, size, color, density, elevation, disabled }),
      [variant, size, color, density, elevation, disabled]
    );

    return (
      <ButtonGroupContext.Provider value={context}>
        <div
          ref={ref}
          role="group"
          className={cx(
            groupBaseClasses,
            orientation === 'vertical' ? 'flex-col' : 'flex-row',
            groupJoinClasses[orientation],
            // `variant` defaults to `solid` on a PlButton, so a group that says
            // nothing is a solid group and must not overlap.
            (variant ?? 'solid') === 'glass' ? groupOverlapClasses[orientation] : '',
            fullWidth ? 'flex w-full [&>*]:flex-1' : '',
            className
          )}
          {...props}
        >
          {children}
        </div>
      </ButtonGroupContext.Provider>
    );
  }
);
