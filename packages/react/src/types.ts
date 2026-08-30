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
 * A day of the week, as `Date.getDay()` counts them: Sunday is `0`.
 *
 * `Date`'s own numbering rather than CLDR's, which starts the week on Monday at
 * `1`. Every comparison a calendar makes is against `getDay()`, and a second
 * numbering in the same file is a numbering somebody will subtract from the
 * wrong one.
 */
export type PlassWeekday = 0 | 1 | 2 | 3 | 4 | 5 | 6;

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
 * How a component sits in the page's scroll, spelled the way CSS spells it.
 *
 * These are `position`'s own values rather than a nicer set of words, for the
 * reason `PlAspectRatio` keeps `object-fit`'s: inventing `pinned` would only
 * make a reader look up which CSS it maps to. `absolute` and `relative` are
 * deliberately absent — a component that offers those is a component being used
 * as a `<div>`.
 */
export type PlassPosition = 'static' | 'sticky' | 'fixed';

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

/* ---------------------------------------------------------------------------
 * The token channel
 *
 * A `className` is not the only way a caller changes how a component looks, and
 * on the parts of a Plass surface that matter most it is not even the effective
 * one. The library writes its edge, its shadow, its focus ring and its fill as
 * Tailwind *arbitrary properties* — `[box-shadow:var(--p-elev),var(--p-lift)]`
 * and friends — and those sort last in the generated stylesheet, so an ordinary
 * utility appended after them loses on order no matter what it says.
 *
 * What does reach them is the custom property underneath: every one of those
 * declarations reads a `--plass-*` token, and a token set in an inline `style`
 * beats every class there is. It also *cascades*, which the other channel does
 * not — set one on a wrapping `<div>` and every Plass component inside it
 * answers, which is usually what a caller actually wanted.
 *
 * So the tokens are the library's real theming surface, and the only thing
 * standing between a caller and them was TypeScript: React's `CSSProperties`
 * has no index signature, so `style={{ '--plass-radius-md': '4px' }}` is an
 * error before it is anything else. The augmentation at the bottom of this
 * section is what opens it, and it is deliberately narrow — `--plass-*` and
 * nothing else, so a typo in any other custom property is still a typo.
 * ------------------------------------------------------------------------- */

/**
 * The twelve slots a colour family is cut into.
 *
 * Not a vocabulary a caller invents in: these are the names `styles.css`
 * declares six times over, once per family, and a component reads them through
 * its `--p-*` locals rather than by name. They are spelled out here so that
 * `PlassToken` can be a real union rather than a string.
 */
export type PlassColorSlot =
  | 'accent'
  | 'fill'
  | 'line'
  | 'line-hover'
  | 'on-solid'
  | 'ring'
  | 'soft'
  | 'soft-hover'
  | 'soft-press'
  | 'solid'
  | 'solid-to'
  | 'tint';

/**
 * Every design token a caller may set, by name.
 *
 * The `--p-*` locals a component writes onto itself are **not** here on
 * purpose. Those are the library talking to itself — which family this control
 * resolved to, what its shadow costs at this `elevation` — and a caller who
 * sets one is setting the answer rather than the question. `color`, `variant`
 * and `elevation` are the props that decide them.
 */
export type PlassToken =
  | `--plass-${PlassColor}-${PlassColorSlot}`
  | `--plass-radius-${PlassSize}`
  | `--plass-shadow-${0 | 1 | 2 | 3 | 4}`
  | '--plass-shadow-ambient'
  | '--plass-bg-from'
  | '--plass-bg-to'
  | '--plass-blur'
  | '--plass-border'
  | '--plass-divider'
  | '--plass-duration'
  | '--plass-duration-slow'
  | '--plass-ease'
  | '--plass-fg'
  | '--plass-flash-on-fill'
  | '--plass-glass'
  | '--plass-glass-hover'
  | '--plass-glass-line'
  | '--plass-glass-press'
  | '--plass-gloss-glass'
  | '--plass-glow-angle'
  | '--plass-glow-on-fill'
  | '--plass-muted-fg'
  | '--plass-scrim'
  | '--plass-stripe'
  | '--plass-surface'
  | '--plass-tint-strength'
  | '--plass-track'
  | '--plass-well'
  | '--plass-z-portal';

/**
 * A set of token overrides, on its own.
 *
 * Not a `style` object — deliberately. The augmentation below widens
 * `CSSProperties` to accept any `--plass-*` key, which is what makes the
 * channel usable at all but also means a typo inside a `style` is a
 * declaration nobody reads rather than an error. This type is not widened, so
 * a name that is not a token fails to compile: write the theme here, once, and
 * spread it into as many `style` props as it applies to.
 */
export type PlassTokens = Partial<Record<PlassToken, string | number>>;

declare module 'react' {
  interface CSSProperties {
    /**
     * A Plass design token. See `PlassToken` for the names, and
     * [the token reference](https://plass.cdget.com/design/color) for what each
     * one paints.
     */
    [token: `--plass-${string}`]: string | number | undefined;
  }
}

/* ---------------------------------------------------------------------------
 * Motion
 *
 * The vocabulary the `PlAnimate*` components share. It is one set of names for
 * the same reason `PlassSize` is: a `delay` of 200 has to mean the same thing
 * on a fade and on a marquee, or a screen running two of them is written in two
 * units.
 * ------------------------------------------------------------------------- */

/**
 * The six effects the `PlAnimate*` components are built out of.
 *
 * Named after what a reader sees rather than after the CSS property
 * underneath: `zoom` and `grow` are both a change of scale, and they are two
 * words because they are two *gestures* — one arrives from the middle of where
 * it will end up, the other unfolds from an edge.
 *
 * Everything past these six is a component rather than a value. A typewriter, a
 * marquee and a headline reel have to know what their children *are*, and a
 * name that only picks a keyframe cannot.
 */
export type PlassAnimation = 'fade' | 'grow' | 'slide' | 'zoom' | 'rotate' | 'blink';

/**
 * What makes an animation run.
 *
 * - `mount` — as soon as it is on the page. The default, and the only one that
 *   needs nothing from the caller.
 * - `visible` — when it is scrolled into view. Once, unless `once` is off.
 * - `hover` — while the pointer is on it, starting again on each entry.
 *   Keyboard focus counts, or the effect would be unreachable without a mouse.
 * - `manual` — never on its own. `play` is what runs it.
 */
export type PlassAnimateTrigger = 'mount' | 'visible' | 'hover' | 'manual';

/** Whether an effect brings its content in or takes it away. */
export type PlassAnimateMode = 'in' | 'out';

/**
 * How many times an animation runs. `'infinite'` rather than `Infinity`,
 * because it is written into CSS as that word and a caller who typed the number
 * would be surprised by which one worked.
 */
export type PlassAnimateRepeat = number | 'infinite';

/**
 * The settings every `PlAnimate*` component takes.
 *
 * Durations and delays are milliseconds — numbers, not CSS strings. A prop
 * typed `string` invites `'0.4s'`, and then two components on one screen are
 * written in two units.
 */
export interface PlassAnimateProps {
  /** How long one run takes, in milliseconds. */
  duration?: number;
  /** How long before it starts, in milliseconds. @default 0 */
  delay?: number;
  /** The easing curve, as CSS writes it. @default the house curve */
  easing?: string;
  /** How many times it runs. @default 1 */
  repeat?: PlassAnimateRepeat;
  /** Runs every other pass backwards, so a repeat returns instead of jumping. */
  alternate?: boolean;
  /** Holds the animation where it is. @default false */
  paused?: boolean;
  /** What starts it. @default 'mount' */
  trigger?: PlassAnimateTrigger;
  /** Runs it, when `trigger` is `manual`. Each `false` → `true` starts it over. */
  play?: boolean;
  /**
   * With `trigger="visible"`, whether it runs only the first time. Off, it runs
   * again every time the element comes back into view.
   * @default true
   */
  once?: boolean;
  /**
   * With `trigger="visible"`, how much of the element has to be on screen
   * before it counts as visible, from `0` to `1`.
   * @default 0.2
   */
  threshold?: number;
}
