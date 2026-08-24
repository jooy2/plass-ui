/**
 * Shared prop vocabulary for every Plass component.
 *
 * These names and values are deliberately generic: a `size` of `md` or a
 * `color` of `primary` has to mean the same thing on a Button, a TextField, a
 * Card or a Dialog. Components pick the subset they need from here and never
 * invent a parallel spelling of the same idea.
 */

/** Scale of a component. `md` is the desktop default. */
export type PlassSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

/** Semantic color role. Maps to a token family in `styles.css`. */
export type PlassColor = 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info';

/**
 * How tightly a component packs its content. Only spacing changes — never the
 * type scale or the control's own height — so a compact and a default control
 * of the same `size` still line up on a shared baseline.
 */
export type PlassDensity = 'default' | 'compact';

/**
 * Which way a component runs. `horizontal` everywhere it is offered, because a
 * vertical control is the exception and an exception should have to be asked
 * for.
 */
export type PlassOrientation = 'horizontal' | 'vertical';

/**
 * Which edge of an anchor something is placed against.
 *
 * Physical rather than logical — `start`/`end` would be wrong here, because a
 * tooltip above a button is above it in every writing direction.
 */
export type PlassSide = 'top' | 'right' | 'bottom' | 'left';

/**
 * Where something sits along the axis it is not placed on.
 *
 * `start`/`end` rather than `left`/`right` because these flip under RTL, which
 * is the whole reason the library never says `left`.
 */
export type PlassAlign = 'start' | 'center' | 'end';

/**
 * What a surface is made of. This is the library's own name, and the two
 * materials in it are the whole design language.
 *
 * - `solid` — **tinted glass.** A gradient that sweeps between two ends of the
 *   colour family at one lightness, and a drop shadow tinted with that family.
 *   No highlight over the top of it: the sweep is the form. One per view, for
 *   the action the screen is about.
 * - `glass` — **clear glass.** A translucent sheet over a blurred backdrop with
 *   a white hairline around it. Secondary actions, and the default for anything
 *   that *holds* content rather than being pressed.
 * - `ghost` — neither. No surface at all until the pointer is on it.
 *   Tertiary and inline actions.
 */
export type PlassVariant = 'solid' | 'glass' | 'ghost';

/**
 * How far a surface sits off the page, as a drop shadow.
 *
 * A control rests **on** the sheet rather than flush with it, so a Button
 * defaults to `1` and not to `0`. Hovering adds a level and pressing removes
 * one, which is what puts it down against the sheet under the finger. The
 * ladder is neutral and faint; a control's shadow is mostly the tint below it.
 *
 * `0` is flat, and it is the right default for anything a reader looks *into*
 * rather than presses — a field, a well, a panel behind other content.
 */
export type PlassElevation = 0 | 1 | 2 | 3;

/** Style props shared by most components; spread into their own prop types. */
export interface PlassStyleProps {
  /** @default 'solid' */
  variant?: PlassVariant;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** @default 'default' */
  density?: PlassDensity;
}
