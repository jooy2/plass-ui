/**
 * What a `PlAvatar` inherits from the `PlAvatarGroup` around it.
 *
 * `button-group.ts`'s arrangement, one component over and for the same two
 * reasons. Cloning the children with `React.cloneElement` stops working the
 * moment a caller wraps one of them in a `PlTooltip`, a `<Fragment>` or a
 * `.map()` — which is most of the time — and a context reaches the avatar
 * wherever it ended up. And it lives here rather than beside the group so that
 * `PlAvatar` can read it without the two components importing each other.
 *
 * Every field is optional, and every one of them means *not specified* rather
 * than a value: an avatar falls back to its own default, so a group with no
 * props of its own changes nothing except the overlap.
 */

import * as React from 'react';
import type { PlAvatarShape } from '../components/avatar/PlAvatar.js';
import type { PlassColor, PlassElevation, PlassSize, PlassVariant } from '../types.js';

export interface PlassAvatarGroupContextValue {
  size?: PlassSize;
  shape?: PlAvatarShape;
  variant?: PlassVariant;
  color?: PlassColor;
  elevation?: PlassElevation;
}

export const AvatarGroupContext =
  /* @__PURE__ */ React.createContext<PlassAvatarGroupContextValue | null>(null);
