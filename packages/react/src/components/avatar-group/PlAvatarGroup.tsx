'use client';

import * as React from 'react';
import { PlAvatar, type PlAvatarShape } from '../avatar/PlAvatar.js';
import {
  AvatarGroupContext,
  type PlassAvatarGroupContextValue
} from '../../internal/avatar-group.js';
import { cx, toLength } from '../../internal/styles.js';
import type { PlassColor, PlassElevation, PlassSize, PlassVariant } from '../../types.js';

export interface PlAvatarGroupProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * How many avatars are drawn before the rest become a count. Left out, every
   * one of them is drawn.
   */
  max?: number;
  /**
   * How many there are altogether, when the group was handed only the first
   * few. Without it the count is worked out from the children, which is right
   * only when all of them were passed.
   */
  total?: number;
  /**
   * How far each avatar sits under the one before it — a number of pixels or
   * any CSS length. Left out it is a fraction of `size`, which keeps the
   * overlap looking the same at every step.
   */
  overlap?: number | string;
  /** Passed to every avatar in the group. @default 'md' */
  size?: PlassSize;
  /** Passed to every avatar in the group. @default 'circle' */
  shape?: PlAvatarShape;
  /** Passed to every avatar in the group. @default 'ghost' */
  variant?: PlassVariant;
  /** Passed to every avatar in the group. @default 'primary' */
  color?: PlassColor;
  /** Passed to every avatar in the group. @default 0 */
  elevation?: PlassElevation;
  /** The avatars. */
  children?: React.ReactNode;
}

/**
 * How far one avatar sits under the last, per step.
 *
 * Roughly a third of the box at every size: enough that the stack reads as a
 * stack, and not so much that a face is hidden behind the next one.
 */
const overlapSizes: Record<PlassSize, string> = {
  xs: '0.5rem',
  sm: '0.625rem',
  md: '0.875rem',
  lg: '1rem',
  xl: '1.25rem'
};

/**
 * The gap between two overlapping avatars, drawn as a ring in the sheet's own
 * colour.
 *
 * The one opaque outline in the library, and it is not an edge — it is the
 * *hole* the near avatar is cut out of. Two circles of similar tone laid over
 * each other have no boundary between them at all and the stack reads as one
 * smeared shape; a translucent hairline would not help, because what is behind
 * it is the other avatar. `--plass-surface` is the page's own sheet, so the ring
 * reads as space rather than as a line drawn around anything.
 */
const ringClasses = '[&>*]:ring-2 [&>*]:ring-(--plass-surface)';

/**
 * A stack of avatars, overlapping, with the ones that did not fit as a count.
 *
 * `size`, `shape`, `variant`, `color` and `elevation` are set once here rather
 * than on every avatar — a stack whose fourth face is a size out is not a stack
 * — and an avatar's own prop still wins, which is what lets one of them be
 * marked out from the rest.
 *
 * The order is the DOM order, and each face overlaps the one before it — so the
 * last avatar in the list is the one in front, and the `+n` sits over all of
 * them.
 */
export const PlAvatarGroup = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlAvatarGroupProps>(
  function PlAvatarGroup(
    {
      max,
      total,
      overlap,
      size = 'md',
      shape = 'circle',
      variant = 'ghost',
      color = 'primary',
      elevation = 0,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const context = React.useMemo<PlassAvatarGroupContextValue>(
      () => ({ size, shape, variant, color, elevation }),
      [size, shape, variant, color, elevation]
    );

    const items = React.Children.toArray(children);
    const shown = max === undefined ? items : items.slice(0, Math.max(0, max));
    const counted = total ?? items.length;
    const hidden = Math.max(0, counted - shown.length);

    return (
      <AvatarGroupContext.Provider value={context}>
        <div
          ref={ref}
          className={cx(
            // `isolate` so the ring of the first avatar is painted against the
            // page rather than against whatever is behind the group.
            'isolate inline-flex items-center',
            '[&>*:not(:first-child)]:[margin-inline-start:calc(var(--p-overlap)*-1)]',
            ringClasses,
            className ?? ''
          )}
          style={
            {
              '--p-overlap': overlap === undefined ? overlapSizes[size] : toLength(overlap),
              ...style
            } as React.CSSProperties
          }
          {...props}
        >
          {shown}
          {hidden > 0 ? <PlAvatar initials={`+${hidden}`} /> : null}
        </div>
      </AvatarGroupContext.Provider>
    );
  }
);
