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
 * Every rung but `xs`, which is the one with nothing below it.
 *
 * The type of a question about a *floor* — "from here up", "below here". `xs`
 * has no floor to ask about: everything is at or above it, so `from="xs"` would
 * mean "always" and `until="xs"` would mean "never", and a prop with two values
 * that do nothing is a prop that invites them.
 */
export type PlassBreakpointFloor = Exclude<PlassBreakpoint, 'xs'>;

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
 * Slots
 *
 * A `className` lands on the one element a reader would point at and call "the
 * component" — a button's button, a modal's sheet, a field's stack. That is the
 * right default and it is where nearly every override belongs.
 *
 * Some components draw more than that, though, and the rest of it is out of
 * reach: a modal also paints the scrim behind it, and a field also draws its
 * own label and the line of red under it. `classNames` is a map to those, and
 * it is deliberately **only** those — a component's main surface has one prop
 * and not two, so there is never a question of which of them wins.
 *
 * The keys are named for what the part *is*, and the same word means the same
 * part everywhere, exactly as the prop vocabulary above does.
 * ------------------------------------------------------------------------- */

/**
 * The parts of a labelled control a `className` does not reach.
 *
 * A field is four things stacked, and only the stack itself is addressable
 * otherwise: `className` lands on the wrapper that holds the label, the control
 * and the two lines of text under it. That is right for the layout — a
 * `w-full`, a margin, a grid position — and it is the wrong element for every
 * other override a caller reaches for.
 *
 * `control` is the part a reader acts on: the box a `PlTextField` is typed
 * into, the button a `PlSelect` opens, the tick, the track, the row of radios.
 * It is the one of the four that is worth naming even when the other three are
 * not there.
 */
export interface PlassFieldClassNames {
  /** The text above the control. */
  label?: string;
  /** The part a reader acts on. */
  control?: string;
  /** The helper text below it. */
  description?: string;
  /** The message below it, shown when the field is invalid. */
  error?: string;
}

/**
 * Chords a control answers to, in the vocabulary `PlHotKeys` draws.
 *
 * The key is a shortcut written the way a key cap is written — `'Enter'`,
 * `'Escape'`, `'Mod+Enter'`, `'Shift+Enter'` — and `Mod` resolves per platform,
 * so one entry is ⌘ on a Mac and Ctrl everywhere else. It is deliberately the
 * *same* string a `PlHotKeys` beside the field would print: a shortcut a
 * component displays and a shortcut it binds have to be spelled one way, or the
 * cap on the screen is a claim nobody checked.
 *
 * A chord that matches is **consumed** — the handler runs and the key goes no
 * further, so `Escape` bound on a field does not also close the dialog around
 * it and `Enter` does not also submit the form. That is what binding a key
 * means, and it is why these are chords rather than letters: `hotKeys={{ a }}`
 * is a field that cannot type an `a`.
 */
export type PlassHotKeys = Record<string, () => void>;

/** The parts of a portalled surface a `className` does not reach. */
export interface PlassPortalClassNames {
  /**
   * The sheet drawn over the page behind the surface — the scrim, the blur, and
   * the thing a click outside the surface lands on.
   */
  backdrop?: string;
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
  // The chart palette: eight categorical slots and the two five-step ramps, plus
  // what is legible written *on* a ramp step. Templated rather than written out
  // because the numbers are a ladder and the only thing to get wrong is how far
  // it goes.
  | `--plass-chart-${1 | 2 | 3 | 4 | 5 | 6 | 7 | 8}`
  | `--plass-chart-seq-${1 | 2 | 3 | 4 | 5}`
  | `--plass-chart-div-${1 | 2 | 3 | 4 | 5}`
  | `--plass-chart-seq-on-${1 | 2 | 3 | 4 | 5}`
  | `--plass-chart-div-on-${1 | 2 | 3 | 4 | 5}`
  | '--plass-shadow-ambient'
  | '--plass-bg-from'
  | '--plass-bg-to'
  | '--plass-blur'
  | '--plass-border'
  | '--plass-breakpoint-sm'
  | '--plass-breakpoint-md'
  | '--plass-breakpoint-lg'
  | '--plass-breakpoint-xl'
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
export type PlassAnimation = 'fade' | 'grow' | 'slide' | 'zoom' | 'rotate' | 'blink' | 'reveal';

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

/**
 * What advances an animation.
 *
 * - `auto` — the clock. The default, and what every effect did before this
 *   existed.
 * - `view` — the reader's scroll position. The effect no longer *happens*; it
 *   tracks where the element sits in the scrollport, and scrolling back plays
 *   it backwards.
 *
 * `view` makes three of the other settings meaningless, and they are ignored
 * rather than quietly half-working: `duration`, `delay` and `repeat` all belong
 * to a clock, and so does the whole idea of a `trigger` — the scroll position
 * *is* the trigger. `range` is what replaces `duration`.
 *
 * A browser without `animation-timeline` falls back to one clock-driven run, so
 * the content still arrives. Degraded is allowed; blank is not.
 */
export type PlassAnimateTimeline = 'auto' | 'view';

/** Whether an effect brings its content in or takes it away. */
export type PlassAnimateMode = 'in' | 'out';

/**
 * How many times an animation runs. `'infinite'` rather than `Infinity`,
 * because it is written into CSS as that word and a caller who typed the number
 * would be surprised by which one worked.
 */
export type PlassAnimateRepeat = number | 'infinite';

/**
 * The three props that turn an effect on a box into the same effect on each of
 * the things inside it.
 *
 * There is deliberately no `PlAnimateStagger`. A stagger is not an effect — it
 * is a *differential*, and every one of the six single-keyframe effects can
 * take one. A wrapper would have been a second way to spell something they can
 * already say, and the rule against two spellings of one idea is the same rule
 * that keeps a `Pulse` (`blink` + `alternate`) and a `Bounce` (`grow` +
 * `alternate`) out of the library.
 *
 * The four effects that do **not** take these are the four that already know
 * what their children are: a `PlAnimateMarquee` lays them down twice, a
 * `PlAnimateHeadline` swaps between them, a `PlAnimateTyping` counts their
 * graphemes, and a `PlAnimateLighting` keeps its motion on a pseudo-element,
 * which there is no way to put on somebody else's child. A
 * `PlAnimateAppear` is a *set* rather than an effect and has had its own
 * `stagger` from the start; these are the same three props under the same
 * names.
 */
export interface PlassAnimateStaggerProps {
  /**
   * Milliseconds added to each child's delay, so the children run one after
   * another rather than together.
   *
   * `0` — the default — plays the **box**, which is what an effect does without
   * this and what it should go on doing when it wraps one thing. Anything else
   * moves the effect onto the children and takes it off the box entirely: eight
   * children fading in under a box that is also fading in is the same content
   * faded twice.
   *
   * The step is per *child*, so what is passed matters — eight children are
   * eight steps and one child holding eight things is one step, which is also
   * how to opt part of a set out.
   *
   * The animation is written onto the children themselves rather than onto
   * wrappers, so a row of `<li>`s stays a row of `<li>`s. The cost is that a
   * child has to accept a `className` and a `style`; one that does not is a
   * child that will not animate.
   * @default 0
   */
  stagger?: number;
  /**
   * Milliseconds added to each child's duration, so later children take longer
   * — or, negative, less long. Floored at `0`.
   * @default 0
   */
  durationStep?: number;
  /**
   * Runs the set from the last child to the first.
   *
   * The *order* turns round and nothing else: each child still plays forwards.
   * An effect that runs backwards is `mode="out"`.
   * @default false
   */
  reverse?: boolean;
}

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

/**
 * The two props that hand an effect to the reader's scroll position.
 *
 * On the same six as `PlassAnimateStaggerProps` and absent from the same four,
 * for a different reason: `animation-timeline` is a property of the element the
 * keyframe is running on, and a marquee's motion is on a duplicated track, a
 * typewriter's is not a keyframe at all, and a lighting's is on a
 * pseudo-element. An endless decoration also has nothing a scroll position
 * could advance it *to*.
 *
 * There is no `PlAnimateOnScroll`, for the reason there is no
 * `PlAnimateStagger`: this changes what advances an effect, not what the effect
 * is, so every effect can take it and none of them needs a twin.
 */
export interface PlassAnimateTimelineProps {
  /**
   * What advances the animation: the clock, or the reader's scroll position.
   *
   * `view` ignores `duration`, `delay`, `repeat` and `trigger` — all four
   * belong to a clock, and with a scroll timeline the scroll position *is* the
   * trigger — and runs the effect against `range` instead.
   * @default 'auto'
   */
  timeline?: PlassAnimateTimeline;
  /**
   * How much of the element's pass through the scrollport the effect is spread
   * over, as CSS writes an `animation-range`. Only read when `timeline` is
   * `view`.
   *
   * The default finishes while the element is still arriving rather than when
   * it reaches the middle of the screen, which is what keeps a reader from
   * scrolling past a half-drawn entrance.
   * @default 'entry 0% cover 45%'
   */
  range?: string;
}

/* ---------------------------------------------------------------------------
 * Charts
 *
 * The vocabulary the chart components share, and the reason it is here rather
 * than in one of them: a `series` handed to a PlLineChart has to be the same
 * `series` a PlBarChart takes, or switching a dashboard tile from one to the
 * other is a rewrite instead of a rename. The same argument `PlassSize` makes.
 *
 * Everything below describes *data*. How a chart draws it — the curve, the
 * stacking, the hole in a donut — belongs to the component, because that is
 * exactly the part that differs.
 * ------------------------------------------------------------------------- */

/**
 * Where a point sits along the category axis.
 *
 * A `Date` is accepted because a time series is the common case and converting
 * one to a string at the call site is what makes two charts of the same data
 * label their axes differently.
 */
export type PlassChartCategory = string | number | Date;

/**
 * One value, with everything the chart might want to know about it.
 *
 * `y` of `null` is a **gap** and not a zero — a sensor that was offline, a month
 * that has not closed yet. A line breaks across it, an area breaks with it, and
 * a bar is not drawn. This distinction is the whole reason a datum may be
 * `null` at all: a chart that renders missing data as zero is a chart that
 * reports an outage as a collapse.
 */
export interface PlassChartPoint {
  /**
   * Its place on the category axis. Optional — without it the point is placed
   * by its index, against `categories` if the chart was given any.
   */
  x?: PlassChartCategory;
  /** The value. `null` is a gap. */
  y: number | null;
  /**
   * A second magnitude, for the marks that have one: the radius of a bubble,
   * the weight of a tile. Ignored by the charts that do not.
   */
  z?: number;
  /**
   * Overrides the series' colour for this one point — the slice worth pointing
   * at, the bar that is over budget. Any CSS colour, or a `PlassColor` family.
   */
  color?: string;
  /** What the tooltip, the legend and any value label say instead of `y`. */
  label?: React.ReactNode;
}

/** A number, a gap, or a point that says more about itself. */
export type PlassChartDatum = number | null | PlassChartPoint;

/**
 * One line, one band of bars, one ring of slices — and the unit identity is
 * attached to.
 *
 * Colour follows the series, never its position in the drawing: a chart whose
 * legend is filtered keeps every survivor on the colour it had. That is why the
 * slot a series takes is decided by where it sits in this array and not by how
 * many of its neighbours are currently visible.
 */
export interface PlassChartSeries {
  /**
   * Its name in the legend, the tooltip and the data table. A chart with two or
   * more series always shows a legend, so a series without a name is a series
   * the reader cannot identify.
   */
  name?: string;
  /** The values, in category order. */
  data: readonly PlassChartDatum[];
  /**
   * Overrides the palette slot this series would otherwise take. A `PlassColor`
   * family name, or any CSS colour.
   *
   * This is the one place in the library where a colour is not a semantic role,
   * and it is deliberate: a series is an *entity* — a region, a plan, a
   * competitor — and nothing about it means success or danger. Reach for it to
   * match a brand or to hold a colour steady across two charts, not to say how
   * a number should be felt.
   */
  color?: PlassColor | (string & {});
  /**
   * Starts the series hidden. Only meaningful with an interactive legend, which
   * is what turns it back on.
   * @default false
   */
  hidden?: boolean;
}

/**
 * One span on a [PlTimelineChart] — a stretch of time with two ends.
 *
 * Its own type rather than a `z2` or an `x2` bolted onto `PlassChartPoint`,
 * because a second position on the axis is a field the other six charts would
 * carry and never read. The trade the whole `types.ts` makes is that a name
 * means one thing everywhere; a `PlassChartPoint` that sometimes has an end and
 * usually does not is the opposite of that.
 *
 * `start` and `end` rather than `x` and `end`: a span has two places on the
 * axis, and naming one of them `x` only reads correctly to someone who already
 * knows which one it is.
 */
export interface PlassTimelinePoint {
  /** When it begins. A `Date`, or a number of milliseconds. */
  start: PlassChartCategory;
  /** And when it is done. A span that ends before it starts is drawn either way round. */
  end: PlassChartCategory;
  /** What the span is called, in the tooltip and the table. */
  label?: React.ReactNode;
  /** Overrides its row's colour for this one span. */
  color?: PlassColor | (string & {});
}

/**
 * One row of a PlTimelineChart, and everything on it.
 *
 * A row is a series — one entity, one name, one colour — but its data are
 * spans rather than values, so it cannot be a `PlassChartSeries`. There is no
 * `hidden` here and no legend to pair it with: a Gantt's rows *are* its
 * category axis, already named down the side, and a twenty-entry legend
 * restating them is not a filter anyone wants.
 */
export interface PlassTimelineSeries {
  /** Its name on the axis, in the tooltip and in the table. */
  name?: string;
  /** The spans on this row. Overlapping ones are drawn over each other. */
  data: readonly PlassTimelinePoint[];
  /** Overrides the palette slot this row would otherwise take. */
  color?: PlassColor | (string & {});
}

/** How a line gets from one point to the next. */
export type PlassChartCurve = 'linear' | 'smooth' | 'step';

/**
 * Which values are written onto the marks themselves.
 *
 * The default is `none` everywhere, and that is not timidity — a number beside
 * every point is the most reliable way to make a chart unreadable. Label the
 * end, or the extremes, and let the axis and the tooltip carry the rest;
 * `'all'` is there for the eight-bar chart where it genuinely is the answer.
 */
export type PlassChartValueLabels = 'none' | 'last' | 'extremes' | 'all';

/**
 * What the pointer uncovers.
 *
 * - `index` — every series at the category under the pointer, with a crosshair.
 *   The default on anything with a shared x axis, because the question a line
 *   chart is asked is "what happened in March", not "what is this pixel".
 * - `item` — the one mark being pointed at.
 * - `none` — no tooltip. The values still have to be readable some other way.
 */
export type PlassChartTooltipMode = 'index' | 'item' | 'none';

/** One series' answer at the category the pointer is on. */
export interface PlassChartTooltipItem {
  /** Its place in the `series` array — the same index its colour came from. */
  seriesIndex: number;
  name?: string;
  color: string;
  value: number | null;
  /** `value` run through the chart's `format`. */
  formatted: string;
  /** What the point called itself, if it said. */
  label?: React.ReactNode;
}

/** What a custom tooltip is handed. */
export interface PlassChartTooltipContext {
  index: number;
  category: PlassChartCategory;
  /** Only the series that are visible and have a value here. */
  items: readonly PlassChartTooltipItem[];
}

/** The tooltip, when a bare `true` or `false` is not enough. */
export interface PlassChartTooltip {
  /** @default 'index' */
  mode?: PlassChartTooltipMode;
  /**
   * The line dropped through the plot at the active category. On in `index`
   * mode, where it is what says which column the numbers belong to.
   */
  crosshair?: boolean;
  /** Draws the panel. Without it the chart draws its own. */
  render?: (context: PlassChartTooltipContext) => React.ReactNode;
}

/** One axis of a cartesian chart. */
export interface PlassChartAxis {
  /** Leaves the axis undrawn — its rule, its ticks and its labels. */
  hidden?: boolean;
  /** A name for what the axis measures, set beside it. */
  label?: React.ReactNode;
  /**
   * The gridlines this axis casts across the plot. On by default for the value
   * axis and off for the category axis, which is the only arrangement where the
   * grid helps read a value without turning the plot into graph paper.
   */
  grid?: boolean;
  /**
   * Where the scale starts and ends. Left out, both are taken from the data —
   * the value axis from zero, so a bar's length stays proportional to its
   * value. Set `min` only when zero is genuinely not the baseline.
   */
  min?: number;
  max?: number;
  /** Roughly how many ticks. The scale still rounds to clean numbers. */
  tickCount?: number;
  /** How a tick is written, overriding the chart's own `format`. */
  tickFormat?: (value: PlassChartCategory, index: number) => React.ReactNode;
  /**
   * How much room the axis keeps for its ticks and its label, in pixels.
   * Measured from the ticks themselves otherwise; set it when a long category
   * name needs more, or when two charts stacked on a dashboard have to line
   * their plots up.
   */
  thickness?: number;
}

/** Where the legend sits, and whether it does anything when clicked. */
export interface PlassChartLegend {
  /** Which edge of the plot. @default 'bottom' */
  side?: PlassSide;
  /** Where along that edge. @default 'center' */
  align?: PlassAlign;
  /**
   * Clicking an entry hides and shows its series; hovering one dims the rest.
   * @default true
   */
  interactive?: boolean;
  /** Draws each series' current value beside its name. @default false */
  showValue?: boolean;
}
