/**
 * Shared prop vocabulary for every Plass component.
 *
 * These names and values are deliberately generic: a `size` of `md` or a
 * `color` of `primary` has to mean the same thing on a PlButton, a PlTextField, a
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
 * A width the layout answers to.
 *
 * The same five names as `PlassSize`, and deliberately so: a reader who has
 * learned the ladder once should not have to learn a second set of words for
 * where a page changes shape. They are not the same ladder — a `size` is how
 * tall a control is and a breakpoint is how wide the window is — but they run
 * in the same direction and they are used in the same sentence often enough
 * that two vocabularies would only ever get mixed up.
 *
 * The widths are Tailwind's own — `sm` 40rem, `md` 48rem, `lg` 64rem, `xl`
 * 80rem, with `xs` meaning "from zero up" — so a Plass layout and an `sm:`
 * utility change at the same moment.
 */
export type PlassBreakpoint = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

/**
 * A value that may change with the width of the window.
 *
 * A bare value applies everywhere: `span={6}` is six columns at every width.
 * A map applies each entry **from its own breakpoint up**, so
 * `span={{ xs: 12, md: 6 }}` is a full width on a phone and a half from 48rem —
 * two entries usually describe a whole layout.
 *
 * There is no `xs` fallback to write out: an entry cascades to the widths above
 * it, which is what keeps a responsive prop to the breakpoints it actually
 * names.
 */
export type PlassResponsive<T> = T | Partial<Record<PlassBreakpoint, T>>;

/**
 * How a row distributes the space its content did not use, along the axis the
 * content runs on.
 *
 * The three positional values are the library's own `start`/`center`/`end`
 * rather than `left`/`right`, for the reason `PlassAlign` gives: they flip
 * under RTL. The four distributions keep CSS's own hyphenated names, because
 * `space-between` is a word every reader already knows and `spread` would be a
 * word they had to look up.
 */
export type PlassJustify =
  'start' | 'center' | 'end' | 'space-between' | 'space-around' | 'space-evenly' | 'stretch';

/** How content sits across the axis it does not run on. */
export type PlassAlignItems = 'start' | 'center' | 'end' | 'stretch' | 'baseline';

/** The same, for one member overriding the set it is in. */
export type PlassAlignSelf = 'auto' | 'start' | 'center' | 'end' | 'stretch' | 'baseline';

/**
 * Which corner of a box something is pinned to. `PlBadge` reads this.
 *
 * Deliberately one word built out of the two the library already has —
 * `top`/`bottom` from `PlassSide`, `start`/`end` from `PlassAlign` — rather than
 * a pair of props. A corner is one decision, and splitting it into two would let
 * a caller spell `{ vertical: 'left' }`.
 */
export type PlassCorner = 'top-start' | 'top-end' | 'bottom-start' | 'bottom-end';

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
 * A control rests **on** the sheet rather than flush with it, so a PlButton
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
