/**
 * What a `PlButton` inherits from the `PlButtonGroup` around it, and what a run
 * of keys is made of.
 *
 * A context rather than `React.Children.map` with `cloneElement`, and a file of
 * its own rather than something the group exports, for one reason each.
 *
 * Cloning breaks the moment a caller wraps one of the buttons in a `PlTooltip`,
 * a `<Fragment>` or a `.map()` — which is most of the time — and a context
 * reaches the button wherever it ended up. And it lives here rather than beside
 * the group so that `PlButton` can read it without the two components importing
 * each other, which is the arrangement `internal/menu.ts` already has.
 *
 * Every field is optional, and every one of them means *not specified* rather
 * than a value: a button falls back to its own default, so a `PlButtonGroup`
 * with no props of its own changes nothing except the corners.
 *
 * The three class lists at the end are here for the same reason the context is:
 * a `PlToggleGroup` is the same run of keys with a selection on it, and two
 * copies of the join would be two places for the seam to stop lining up.
 */

import * as React from 'react';
import type {
  PlassColor,
  PlassDensity,
  PlassElevation,
  PlassOrientation,
  PlassSize,
  PlassVariant
} from '../types.js';

export interface PlassButtonGroupContextValue {
  variant?: PlassVariant;
  size?: PlassSize;
  color?: PlassColor;
  density?: PlassDensity;
  elevation?: PlassElevation;
  disabled?: boolean;
}

export const ButtonGroupContext =
  /* @__PURE__ */ React.createContext<PlassButtonGroupContextValue | null>(null);

/**
 * The corners that face a neighbour are squared off, so a run reads as one
 * piece scored into segments rather than as three keys that happen to be
 * touching.
 *
 * Logical properties (`s`/`e`) rather than left/right: under RTL the first key
 * is on the right, and `rounded-l-none` would flatten the wrong side.
 */
export const groupJoinClasses: Record<PlassOrientation, string> = {
  horizontal: '[&>*:not(:first-child)]:rounded-s-none [&>*:not(:last-child)]:rounded-e-none',
  vertical: '[&>*:not(:first-child)]:rounded-t-none [&>*:not(:last-child)]:rounded-b-none'
};

/**
 * Only `glass` needs the overlap, because it is the only variant that draws an
 * edge. Two glass keys meeting would otherwise show both of their hairlines and
 * the seam would be twice as heavy as every other edge on the page; pulling the
 * second one back a pixel makes the two share one line.
 *
 * A `solid` run must **not** do this. Its keys have no border to double up, and
 * overlapping would put one gradient over the start of the next — which is
 * exactly the join the squared corners are drawing.
 */
export const groupOverlapClasses: Record<PlassOrientation, string> = {
  horizontal: '[&>*:not(:first-child)]:-ms-px',
  vertical: '[&>*:not(:first-child)]:-mt-px'
};

/** What a run of keys is, before either of the two above. */
export const groupBaseClasses = /* @__PURE__ */ [
  'inline-flex align-middle',
  // Every child gets a stacking context so the hovered or focused one can come
  // forward. Without it the focus ring — which is drawn outside the border box —
  // is painted over by whichever neighbour happens to come after it.
  '[&>*]:relative [&>*:hover]:z-10 [&>*:focus-visible]:z-10',
  // A run is a set of equal keys, so they stay the same height even when one of
  // them has an icon and the others do not.
  '[&>*]:shrink-0'
].join(' ');
