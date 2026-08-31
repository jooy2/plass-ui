'use client';

/**
 * The defaults an application sets once, and every component reads.
 *
 * The context lives here rather than beside `PlassProvider` for the reason
 * `internal/button-group.ts` gives one folder over: seventy components read it
 * and one component writes it, and none of them should have to import the
 * other.
 *
 * **What is in here is decided by one rule: an axis belongs to the application
 * or it belongs to the component.** `size` and `density` are the application's
 * — a product that is compact is compact everywhere, and repeating `size="sm"`
 * at four hundred call sites is not a design decision, it is transcription.
 * `color` is the application's for the same reason, one step weaker: a brand
 * whose primary family is `secondary` says so once.
 *
 * `variant` and `elevation` are **not** here, and their absence is the load
 * bearing part:
 *
 * - `variant` names what a surface is *made of*, and the design language spends
 *   its first paragraph on the fact that a pressed thing and a thing that holds
 *   content are different materials. A button defaults to `solid` and a card to
 *   `glass` because that is the arrangement, not because nobody got round to
 *   configuring it. One value for both is not a default, it is a flattening.
 * - `elevation` is per-component semantics for the same reason: a control rests
 *   **on** the sheet and defaults to `1`, a field is cut **into** it and
 *   defaults to `0`. A single number for the two says the opposite of what the
 *   ladder means.
 *
 * A caller who genuinely wants every button glass writes it on the buttons.
 */

import * as React from 'react';
import type { PlassPickerLabels } from './calendar.js';
import type { PlassDirection } from './direction.js';
import type { PlassColor, PlassDensity, PlassSize, PlassWeekday } from '../types.js';

/** Everything a `PlassProvider` can decide for the tree under it. */
export interface PlassDefaults {
  /** The rung of the size ladder every component starts from. */
  size?: PlassSize;
  /** The semantic family they start from. */
  color?: PlassColor;
  /** How tightly they pack their content. */
  density?: PlassDensity;
  /** The BCP 47 tag the date and time components format and read against. */
  locale?: string;
  /** Which day their weeks start on, as `Date` counts them — Sunday is `0`. */
  weekStartsOn?: PlassWeekday;
  /** The strings a picker says that `Intl` has no opinion about. */
  labels?: Partial<PlassPickerLabels>;
  /**
   * Which way the tree runs, for the behaviours that read it in JavaScript.
   *
   * Left out is not "left to right" — it is **"read it off the document"**,
   * which is what a page that wrote `dir="rtl"` already said. Set it only for a
   * subtree that runs the other way from the page around it, or on a server
   * that knows the answer before there is a document to ask.
   */
  direction?: PlassDirection;
}

/**
 * Frozen and shared, so a tree with no provider in it hands every component the
 * same object and none of their `useMemo`s see a new one on every render.
 */
const none: PlassDefaults = /* @__PURE__ */ Object.freeze({});

export const DefaultsContext = /* @__PURE__ */ React.createContext<PlassDefaults>(none);

/**
 * What the nearest `PlassProvider` decided, or nothing.
 *
 * Every component that reads this resolves in the same order and it is the
 * order a reader would guess: **the component's own prop, then whatever set is
 * around it, then the provider, then the component's own default.** So a
 * `size="lg"` on one button still wins inside a `PlButtonGroup` inside a
 * compact application.
 */
export function useDefaults(): PlassDefaults {
  return React.useContext(DefaultsContext);
}
