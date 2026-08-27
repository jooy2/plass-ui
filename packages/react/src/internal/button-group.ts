/**
 * What a `PlButton` inherits from the `PlButtonGroup` around it.
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
 */

import * as React from 'react';
import type {
  PlassColor,
  PlassDensity,
  PlassElevation,
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
