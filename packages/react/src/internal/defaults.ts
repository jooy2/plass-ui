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
import type { PlassLabels } from './labels.js';
import type { PlassDirection } from './direction.js';
import type {
  PlassColor,
  PlassDensity,
  PlassFieldLabelPlacement,
  PlassSize,
  PlassWeekday
} from '../types.js';

/** Everything a `PlassProvider` can decide for the tree under it. */
export interface PlassDefaults {
  /** The rung of the size ladder every component starts from. */
  size?: PlassSize;
  /** The semantic family they start from. */
  color?: PlassColor;
  /** How tightly they pack their content. */
  density?: PlassDensity;
  /**
   * Where a labelled control puts its label — above the box, in the box's top
   * edge, or inside the box until it is focused or filled.
   *
   * Here for the same reason `density` is: a product whose forms notch their
   * labels notches all of them, and the decision is the application's rather
   * than the field's. A component's own `labelPlacement` still wins, which is
   * what a form with one field that genuinely cannot take a notch needs.
   *
   * `PlOtpField` is not reached by it: a row of separate boxes has no one edge
   * to cut, so its label stays above the row whatever this says.
   */
  labelPlacement?: PlassFieldLabelPlacement;
  /**
   * The BCP 47 tag the date and time components format and read against.
   *
   * Left out, it is the browser's own, which a server cannot ask for: a server
   * render and its hydration write `en-US`, and the components switch once
   * hydration is done. A server-rendered page that names it paints the reader's
   * format from the start.
   */
  locale?: string;
  /** Which day their weeks start on, as `Date` counts them — Sunday is `0`. */
  weekStartsOn?: PlassWeekday;
  /**
   * The words the library says on its own behalf, translated.
   *
   * A partial: whatever is not in it stays English, so a caller can replace one
   * string without owning the other sixty. `plass-ui/locales` ships whole ones.
   */
  labels?: Partial<PlassLabels>;
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

/* ---------------------------------------------------------------------------
 * The locale, and the server render
 *
 * A locale nobody named means the runtime's own, which is what `Intl` does with
 * `undefined` and what a page rendered only in the browser wants. A server has
 * a runtime default as well, and it is the machine's rather than the reader's:
 * an `en-US` server writes `12,345` into the HTML and a `de-DE` browser hydrates
 * it as `12.345`, which React reports as a failed hydration and answers by
 * throwing the server's tree away and rendering it again.
 *
 * So the default is pinned for exactly the two renders that have to agree, the
 * server's and the hydration's, and let go straight after: `useSyncExternalStore`
 * reads the server snapshot for both, then re-renders the component with the
 * client snapshot once hydration is done. A component mounted in the browser
 * never sees the pinned value at all, and a locale that was named — by the
 * component's prop or by a provider — is the same in every snapshot, so it
 * costs no second render either.
 * ------------------------------------------------------------------------- */

/** What a server render and its hydration format in when nobody named a locale. */
const hydrationLocale = 'en-US';

/** The runtime's locale does not change under a page, so there is nothing to listen to. */
function subscribeToNothing(): () => void {
  return unsubscribeFromNothing;
}

function unsubscribeFromNothing(): void {}

/**
 * The locale to format in, given the one a component was told.
 *
 * `given` comes back as it is. Left out, it is `undefined` — the runtime's own
 * locale — except in a server render and its hydration, where it is `en-US`.
 * For the few components that do not read the provider's locale; the rest call
 * {@link useLocale}.
 */
export function useRuntimeLocale<T extends Intl.LocalesArgument>(
  given: T
): T | typeof hydrationLocale {
  return React.useSyncExternalStore<T | typeof hydrationLocale>(
    subscribeToNothing,
    () => given,
    () => given ?? hydrationLocale
  );
}

/**
 * The locale a component formats in: its own `locale` prop, then the nearest
 * provider's, then the runtime's, which a server render and its hydration pin
 * to `en-US`. See {@link useRuntimeLocale}.
 */
export function useLocale<T extends Intl.LocalesArgument = string | undefined>(
  own?: T
): T | string | undefined {
  const provided = React.useContext(DefaultsContext).locale;

  return useRuntimeLocale<T | string | undefined>(own ?? provided);
}

/* ---------------------------------------------------------------------------
 * The clock, and the server render
 *
 * "Today" is the same problem as the locale with a second cause: the server and
 * the browser read one instant on clocks in different zones. At 08:00 in Seoul
 * a UTC server is still on yesterday, so a calendar it renders lights up a
 * different day from the one the browser hydrating it would — and on the 1st of
 * a month it opens on a different month. So the clock is read in UTC for the
 * server render and its hydration, and in the browser's own zone straight
 * after, the way the locale is. No component takes a zone of its own and
 * neither does the provider, so UTC is the whole of the rule.
 * ------------------------------------------------------------------------- */

/** What a server render and its hydration read the clock in. */
const hydrationTimeZone = 'UTC';

function runtimeTimeZone(): undefined {
  return undefined;
}

function pinnedTimeZone(): typeof hydrationTimeZone {
  return hydrationTimeZone;
}

/**
 * The zone to read the clock in: `undefined` — the runtime's own — except in a
 * server render and its hydration, where it is `UTC`. `todayIn` in
 * `internal/date.ts` turns it into a day.
 */
export function useRuntimeTimeZone(): typeof hydrationTimeZone | undefined {
  return React.useSyncExternalStore<typeof hydrationTimeZone | undefined>(
    subscribeToNothing,
    runtimeTimeZone,
    pinnedTimeZone
  );
}
