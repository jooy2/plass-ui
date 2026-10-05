/**
 * The machinery every `PlAnimate*` component runs on.
 *
 * It lives in `internal/` for the reason `button-group.ts` and `progress.ts`
 * do: eleven components need it and none of them should have to import another.
 *
 * ## The shape of it
 *
 * Every effect is one `@keyframes` in `styles.css` running from a state written
 * entirely in custom properties to the element's natural one. Nothing here
 * generates CSS — it fills `--p-anim-*` slots and the stylesheet decides what
 * they mean, which is the same split `controlSlots()` makes for colour and for
 * the same reason: Tailwind only ever sees class names that appear literally in
 * the source, so a class per duration would not survive the first prop.
 *
 * Because the from-state is the *keyframe* rather than a second class, running
 * an effect backwards is `animation-direction: reverse` and nothing else. That
 * is what makes `mode="out"` free on the five that offer it.
 *
 * ## Where the design language draws the line
 *
 * A Plass **control** never moves — a key that scales resamples its label, and
 * that rule holds without exception. What moves here is content a caller has
 * asked to have moved, and it moves on the independent `translate`, `scale` and
 * `rotate` properties rather than on the `transform` shorthand, so a caller's
 * own transform on the same element survives.
 *
 * ## Telling the children apart
 *
 * `stagger`, `durationStep` and `reverse` move an effect off the box and onto
 * the things inside it, one after another. There is no `PlAnimateStagger`
 * component and there should not be: a stagger is a *differential* rather than
 * an effect, and a wrapper would be a second way to spell something all six
 * effects can already say. `animateChildren` and `staggerSlots` are what
 * `PlAnimateAppear` — which was staggering long before the six could — now runs
 * on as well, because two implementations of "one after another" is two
 * opinions about the arithmetic.
 *
 * ## What is deliberately not here
 *
 * An effect that has to know what its children *are* — a marquee that lays them
 * down twice, a headline that swaps between them, a typewriter that counts
 * graphemes — cannot be a class name and a few numbers. Those are components,
 * and their logic stays in their own files. They are also the four that cannot
 * take a `stagger`, for the same reason: their children are already spoken for.
 */

import * as React from 'react';
import type {
  PlassAnimateRepeat,
  PlassAnimateStaggerProps,
  PlassAnimateTimelineProps,
  PlassAnimateTrigger,
  PlassAnimation,
  PlassSide
} from '../types.js';
import { prefersReducedMotion, reducedMotionQuery, useMediaQuery } from './media.js';
import { cx } from './styles.js';

/* ---------------------------------------------------------------------------
 * Slots
 * ------------------------------------------------------------------------- */

/**
 * Which keyframe an effect runs.
 *
 * `grow` and `zoom` share one: they are the same arithmetic at two strengths,
 * and a second identical `@keyframes` would only be a second place to fix a
 * bug. What separates them is their defaults and their origin, and an origin is
 * a property rather than a keyframe.
 */
export const animationClasses: Record<PlassAnimation, string> = {
  fade: 'plass-anim-fade',
  grow: 'plass-anim-scale',
  slide: 'plass-anim-slide',
  zoom: 'plass-anim-scale',
  rotate: 'plass-anim-rotate',
  blink: 'plass-anim-blink',
  reveal: 'plass-anim-reveal'
};

/** The class that reads the slots. Always paired with one of the above. */
export const animBaseClass = 'plass-anim';

const animSelector = `.${animBaseClass}`;

/**
 * The keyframes that move, turn or scale the element they run on, rather than
 * only changing how much of it is drawn. Where such an element is drawn is not
 * where it lives, which is what `AnimationRunOptions.moves` is about.
 */
const movingEffects: ReadonlySet<PlassAnimation> = /* @__PURE__ */ new Set<PlassAnimation>([
  'grow',
  'slide',
  'zoom',
  'rotate'
]);

/** A number is pixels; a string is already a CSS length. */
export function lengthValue(value: number | string): string {
  return typeof value === 'number' ? `${value}px` : value;
}

/** `'infinite'` reaches CSS as the word; a count reaches it as the number. */
export function repeatValue(repeat: PlassAnimateRepeat): string {
  return repeat === 'infinite' ? 'infinite' : String(repeat);
}

export function isInfinite(repeat: PlassAnimateRepeat | undefined): boolean {
  return repeat === 'infinite';
}

/**
 * `normal`, `reverse`, `alternate`, `alternate-reverse` — the four CSS already
 * has, assembled from the two props that mean something to a caller.
 *
 * `mode="out"` is a reversed run rather than a keyframe of its own, which is
 * also why a reversed animation ends held on its own first frame: `fill-mode`
 * is `both`, so a faded-out element stays faded out instead of snapping back.
 */
export function directionValue(mode: 'in' | 'out', alternate: boolean | undefined): string {
  if (mode === 'out') {
    return alternate ? 'alternate-reverse' : 'reverse';
  }

  return alternate ? 'alternate' : 'normal';
}

/**
 * Where a scroll-linked effect starts and finishes, as an `animation-range`.
 *
 * Finished while the element is still arriving rather than when it reaches the
 * middle of the screen: an entrance that is only half drawn by the time a
 * reader has read past it is an entrance that never happened.
 */
export const defaultViewRange = 'entry 0% cover 45%';

export interface AnimationSlotOptions extends PlassAnimateTimelineProps {
  duration: number;
  delay: number;
  easing?: string;
  repeat: PlassAnimateRepeat;
  alternate?: boolean;
  mode?: 'in' | 'out';
  /** Where the animated properties start. Only the ones an effect reads. */
  opacity?: number;
  scale?: number;
  x?: string;
  y?: string;
  angle?: string;
  angleTo?: string;
  /** The `clip-path` a reveal is uncovered from. */
  clip?: string;
}

/**
 * The `--p-anim-*` slots, as an inline style object.
 *
 * Inline rather than utilities for the reason the colour slots are: these are
 * per-instance numbers, and Tailwind cannot generate a class for a duration it
 * has never seen written down.
 */
export function animationSlots(options: AnimationSlotOptions): React.CSSProperties {
  const slots: Record<string, string> = {
    '--p-anim-duration': `${options.duration}ms`,
    '--p-anim-delay': `${options.delay}ms`,
    '--p-anim-repeat': repeatValue(options.repeat),
    '--p-anim-direction': directionValue(options.mode ?? 'in', options.alternate)
  };

  // Read only under reduced motion, where an effect is run in no time and
  // shown on its last frame. An endless one has no last frame, so it is shown
  // on the last frame of one pass — which also gives an alternating one the
  // direction its first pass runs in.
  if (isInfinite(options.repeat)) {
    slots['--p-anim-still-repeat'] = '1';
  }

  if (options.easing) {
    slots['--p-anim-ease'] = options.easing;
  }

  // Only when a caller asked for it. `auto` is what the property already
  // resolves to, so writing it here would be the same answer copied into every
  // inline style in the page.
  if (options.timeline === 'view') {
    slots['--p-anim-timeline'] = 'view()';
    slots['--p-anim-range'] = options.range ?? defaultViewRange;
  }

  if (options.opacity !== undefined) {
    slots['--p-anim-opacity'] = String(options.opacity);
  }

  if (options.scale !== undefined) {
    slots['--p-anim-scale'] = String(options.scale);
  }

  if (options.x !== undefined) {
    slots['--p-anim-x'] = options.x;
  }

  if (options.y !== undefined) {
    slots['--p-anim-y'] = options.y;
  }

  if (options.angle !== undefined) {
    slots['--p-anim-angle'] = options.angle;
  }

  if (options.angleTo !== undefined) {
    slots['--p-anim-angle-to'] = options.angleTo;
  }

  if (options.clip !== undefined) {
    slots['--p-anim-clip'] = options.clip;
  }

  return slots as React.CSSProperties;
}

/**
 * The `clip-path` a reveal starts from, given the edge it uncovers from.
 *
 * `inset()` takes its four sides in the physical order CSS writes them, and
 * `PlassSide` is physical for the same reason it is on a slide: a title wiped
 * in from the top is wiped in from the top in every writing direction.
 */
export function revealClip(from: PlassSide): string {
  switch (from) {
    case 'top':
      return 'inset(0 0 100% 0)';
    case 'bottom':
      return 'inset(100% 0 0 0)';
    case 'right':
      return 'inset(0 0 0 100%)';
    default:
      return 'inset(0 100% 0 0)';
  }
}

/**
 * Which way a slide starts, given the edge it comes from.
 *
 * `PlassSide` is physical everywhere in the library and it stays physical here:
 * something arriving from the top of the window arrives from the top in every
 * writing direction.
 */
export function slideOffsets(from: PlassSide, distance: number | string): { x: string; y: string } {
  const length = lengthValue(distance);
  const negative = typeof distance === 'number' ? `${-distance}px` : `calc(-1 * ${length})`;

  switch (from) {
    case 'top':
      return { x: '0px', y: negative };
    case 'bottom':
      return { x: '0px', y: length };
    case 'left':
      return { x: negative, y: '0px' };
    default:
      return { x: length, y: '0px' };
  }
}

/* ---------------------------------------------------------------------------
 * Running one
 * ------------------------------------------------------------------------- */

export interface AnimationRunOptions {
  trigger: PlassAnimateTrigger;
  play?: boolean;
  once: boolean;
  threshold: number;
  paused?: boolean;
  /** An infinite effect stops when the pointer leaves; a finite one finishes. */
  infinite: boolean;
  /**
   * Whether the effect runs for ever once it has started: an `'infinite'`
   * repeat, a marquee, a reel that loops.
   *
   * An endless effect **rests while it is off screen** and goes on from the
   * frame it stopped on when it is back. A browser keeps running an animation
   * nobody can see, and a few of these redraw on the main thread on every frame
   * they run, so an endless one left running further up the page costs a reader
   * something on every frame of the rest of their visit. A finite one is left
   * alone: it finishes, and an entrance that played off screen has still
   * delivered its content.
   */
  endless?: boolean;
  /**
   * Whether the effect moves the element it runs on, so that where the element
   * is drawn is not where it lives. Whether an endless one is on screen is then
   * read off its parent, which stays put: read off the element, a slide that
   * starts outside its mask would rest there, out of sight, for good.
   */
  moves?: boolean;
  /**
   * A value that plays the effect again whenever it changes, and never on the
   * first render.
   *
   * `play` is a boolean, so replaying with it means toggling off and on — two
   * renders for one event, and a piece of state whose only job is to be
   * flipped back. A response to something that can happen twice needs the
   * *event*, and a value that has changed is the closest React has to one: a
   * count of failed attempts already is this.
   */
  nonce?: unknown;
  /**
   * What the effect arrives at: a counter's figure, a scramble's line. A new
   * one runs the effect again from its start while the trigger has it going,
   * and never on the first render.
   *
   * Unlike `nonce`, it never starts a run the trigger is holding back. A
   * counter waiting to be scrolled to, or for `play`, whose figure changes is
   * still waiting: what changed is what it will count to, and counting there
   * and then is what the trigger was there to stop.
   */
  target?: unknown;
}

/**
 * The steps a `visible` trigger's two observers report at.
 *
 * Neither of them decides anything — both only say *when* to measure — so all
 * the list has to do is arrive often enough while the element crosses the view.
 * Twenty steps is a callback every twentieth of the way, and the caller's own
 * threshold is added to it because that is the exact point a mask cut to the
 * size of what it holds crosses at, which is the arrangement the measurement
 * exists for.
 */
function measureSteps(threshold: number): number[] {
  const steps = Array.from({ length: 21 }, (_, step) => step / 20);

  return threshold > 0 && threshold < 1 ? [...steps, threshold] : steps;
}

/** The window, in the coordinates every rectangle here is measured in. */
function viewportRect(): DOMRectReadOnly {
  const page = document.documentElement;

  return new DOMRect(0, 0, page.clientWidth, page.clientHeight);
}

/**
 * How much of the view an element's parent leaves it.
 *
 * `intersectionRect` is the parent's own box with every clip above it already
 * taken off — the mask it sits in, the scroller above that, and the window —
 * which is the whole reason the parent is worth watching.
 */
function clipRect(entry: IntersectionObserverEntry): DOMRectReadOnly {
  const box = entry.boundingClientRect;

  // A parent with no box of its own clips nothing: `display: contents`, or a
  // wrapper left with no height by what is inside it. Reading its empty
  // intersection as the clip would leave the effect waiting for ever.
  return box.width * box.height > 0 ? entry.intersectionRect : (entry.rootBounds ?? viewportRect());
}

/** What the keyframes in `src/styles.css` move an element's own box with. */
const boxProperties = ['translate', 'scale', 'rotate'] as const;

/**
 * Which of `boxProperties` the element's own animations set.
 *
 * Only those are taken off for a read. Whatever a caller has set on another one
 * is still there when the effect lands, and so is their `transform`, which no
 * keyframe here touches.
 */
function movedProperties(element: HTMLElement): string[] {
  // A DOM without the Web Animations API, a test environment's, has no
  // keyframes to take off.
  if (typeof element.getAnimations !== 'function') {
    return [];
  }

  const moved = new Set<string>();

  for (const animation of element.getAnimations()) {
    if (!(animation.effect instanceof KeyframeEffect)) {
      continue;
    }

    for (const keyframe of animation.effect.getKeyframes()) {
      for (const property of boxProperties) {
        if (property in keyframe) {
          moved.add(property);
        }
      }
    }
  }

  return [...moved];
}

/**
 * Where the element itself sits, in window coordinates: where an entrance
 * lands, and where an exit leaves from.
 *
 * Read off what is drawn, a slide waiting to arrive measures a screen away from
 * where it lives, and a turn measures as the box its corners sweep. Both of
 * those are what the observer sees, and it is why a slide inside a mask — the
 * arrangement the slide page recommends — used to report as off the screen for
 * ever. A running one is no different: a slide a tenth of the way in is a
 * tenth inside its mask, which read as leaving and held it there.
 *
 * So the properties the effect moves the box with are set to `none` for the
 * length of the read. An `!important` declaration outranks an animation, and
 * all it changes is what the cascade hands the element: the animation goes on
 * from the frame it is on, starts no transition and fires no event. A value a
 * caller set on one of those properties goes with it, which costs nothing,
 * since the keyframes fill both ends of the run and it is never drawn.
 *
 * An effect that has not been let go yet has its `animation-name` cleared for
 * the read as well, which is the move the rewind above makes. That one starts
 * the animation again, which is why only a held one is given it: what the
 * restore starts is an animation held paused on its first frame, which is what
 * was there.
 */
function restingRect(element: HTMLElement, held: boolean): DOMRect {
  // Asked before the name is cleared, which takes the animations with it.
  const moved = movedProperties(element);
  const style = element.style;
  const name = style.animationName;
  const before = moved.map((property) => ({
    property,
    value: style.getPropertyValue(property),
    priority: style.getPropertyPriority(property)
  }));

  if (held) {
    style.animationName = 'none';
  }

  for (const property of moved) {
    style.setProperty(property, 'none', 'important');
  }

  const rect = element.getBoundingClientRect();

  for (const { property, value, priority } of before) {
    if (value) {
      style.setProperty(property, value, priority);
    } else {
      style.removeProperty(property);
    }
  }

  if (held) {
    style.animationName = name;
  }

  return rect;
}

/** How much of `rect` the clip leaves showing, as a share of its own area. */
function visibleShare(rect: DOMRect, clip: DOMRectReadOnly): number {
  const area = rect.width * rect.height;

  if (area <= 0) {
    return 0;
  }

  const width = Math.min(rect.right, clip.right) - Math.max(rect.left, clip.left);
  const height = Math.min(rect.bottom, clip.bottom) - Math.max(rect.top, clip.top);

  return (Math.max(0, width) * Math.max(0, height)) / area;
}

/** Whether the focus is arriving from, or leaving for, something inside. */
function holds(element: HTMLElement | null, related: EventTarget | null): boolean {
  return element !== null && related instanceof Node && element.contains(related);
}

/**
 * What an effect writes its keyframe onto inside its own root, when the root is
 * not what moves: the children of a stagger, the parts of a split line, the
 * strips of a marquee.
 */
const partSelector = '.plass-anim, .plass-marquee-track';

/** A strip of a marquee, one of the parts above. */
const trackSelector = '.plass-marquee-track';

/**
 * Whether `part` carries `element`'s effect rather than the effect of another
 * `PlAnimate*` nested inside it.
 *
 * Every root names itself with `data-plass-animation`, so whose a part is is
 * already written in the DOM: it is this element's when the nearest named root
 * at or above it is this element. A nested root is its own nearest, and
 * everything inside it answers to that one.
 */
function ownsPart(element: HTMLElement, part: Element): boolean {
  return part.closest('[data-plass-animation]') === element;
}

/** The element, and the parts inside it that carry its own keyframe. */
function ownParts(element: HTMLElement): HTMLElement[] {
  const parts: HTMLElement[] = [element];

  for (const part of element.querySelectorAll<HTMLElement>(partSelector)) {
    if (ownsPart(element, part)) {
      parts.push(part);
    }
  }

  return parts;
}

/**
 * The element an animation event is about, when the keyframe is the effect's
 * own: one of the library's keyframes, on the root or on a part the root owns,
 * which is what a rewind takes back. `null` for the rest, which reaches the
 * root as well because animation events bubble: a nested `PlAnimate*`, a
 * headline's lines, a keyframe of the caller's own.
 */
function ownTarget(element: HTMLElement, event: AnimationEvent): HTMLElement | SVGElement | null {
  const target = event.target;

  if (
    !event.animationName.startsWith('plass-anim-') ||
    !(target instanceof HTMLElement || target instanceof SVGElement)
  ) {
    return null;
  }

  return target === element || (target.matches(partSelector) && ownsPart(element, target))
    ? target
    : null;
}

/* ---------------------------------------------------------------------------
 * Resting off screen
 * ------------------------------------------------------------------------- */

/** Told whether the element it was registered for is off screen now. */
type AwayListener = (away: boolean) => void;

/**
 * Every element an endless effect is watching, with whoever is listening.
 *
 * One observer for the whole page rather than one per effect. A strip of logos,
 * a glowing card and a typed headline on one page are three elements on one
 * observer, which reports whichever of them has just crossed the edge of the
 * screen and is otherwise silent.
 */
const awayListeners = new Map<Element, Set<AwayListener>>();
let awayObserver: IntersectionObserver | null = null;

function reportAway(entries: IntersectionObserverEntry[]): void {
  for (const entry of entries) {
    const box = entry.boundingClientRect;
    // A box with no area of its own says nothing about where what it holds is
    // drawn: a `display: contents` parent, or an element with nothing in it.
    // Read as off screen, it would hold an effect still on a visible page.
    const away = !entry.isIntersecting && box.width * box.height > 0;

    for (const listener of awayListeners.get(entry.target) ?? []) {
      listener(away);
    }
  }
}

/**
 * Tells `listener` whether `element` is off screen, now and whenever that
 * changes, and hands back the function that stops it.
 */
function watchAway(element: Element, listener: AwayListener): () => void {
  awayObserver ??= new IntersectionObserver(reportAway);

  let listeners = awayListeners.get(element);

  if (listeners) {
    // An element that is already watched has already been reported, and an
    // observer does not report a target twice for being observed twice. Taking
    // it off and putting it back is what has the newcomer told where it is.
    awayObserver.unobserve(element);
  } else {
    listeners = new Set();
    awayListeners.set(element, listeners);
  }

  listeners.add(listener);
  awayObserver.observe(element);

  return () => {
    listeners.delete(listener);

    if (listeners.size === 0) {
      awayListeners.delete(element);
      awayObserver?.unobserve(element);
    }
  };
}

/**
 * Whether the element in `node`, or its parent with `parent`, is off screen.
 *
 * `false` until the observer has said otherwise, which is what the server
 * renders and what the first frame shows: an effect runs as it always has, and
 * rests only once something has seen it leave. With no observer to ask, it
 * never rests.
 *
 * Exported for `PlAnimateTyping`'s caret, which blinks for ever after a typing
 * that finishes, and so rests on its own while the typing does not.
 */
export function useOffScreen(
  node: React.RefObject<Element | null>,
  enabled: boolean,
  parent = false
): boolean {
  const [away, setAway] = React.useState(false);

  React.useEffect(() => {
    const element = parent ? node.current?.parentElement : node.current;

    if (!enabled || !element || typeof IntersectionObserver === 'undefined') {
      return undefined;
    }

    const stop = watchAway(element, setAway);

    return () => {
      stop();
      setAway(false);
    };
  }, [node, enabled, parent]);

  return enabled && away;
}

export interface AnimationRun {
  /** Goes on the animated element. */
  ref: React.RefCallback<HTMLElement>;
  /** `running` or `paused`, for `--p-anim-state`. */
  state: 'running' | 'paused';
  /** Whether the animation has been let go at all. */
  started: boolean;
  /**
   * Whether an endless effect is resting because it is off screen, which
   * `state` already says as `paused`. Typing runs on timers rather than a
   * keyframe, and stops scheduling them while it is true.
   */
  resting: boolean;
  /**
   * How many times it has been started, counting every hover, every `play`,
   * every change of `nonce` and every change of `target` that started it again.
   *
   * `started` stays `true` from the first start on, so a second hover changes
   * nothing an effect could depend on. A keyframe does not need to know, because
   * it is rewound in the DOM whenever this changes. Counter, Scramble and Typing
   * run their own loops in JavaScript, and they replay by listing this among
   * their effects' dependencies.
   */
  runs: number;
  /**
   * The hover trigger's handlers when `trigger` is `hover`; empty otherwise.
   *
   * Merged with the caller's props through `mergeProps` rather than spread
   * beside them. Both sides want `onPointerEnter` and `onFocus`, and a spread
   * keeps only one: either a caller's prefetch never runs, or a caller's
   * `onFocus` quietly takes the keyboard's way in away from the effect.
   */
  handlers: React.HTMLAttributes<HTMLElement>;
}

/**
 * Starts, restarts and holds an animation.
 *
 * Two things here are less obvious than they look.
 *
 * **Waiting is `animation-play-state: paused`, not a second class.** An element
 * that has not been triggered yet has to already look like its own first frame,
 * or a `visible` fade would be fully drawn until it scrolled into view and then
 * blink out to start. With `fill-mode: both` a paused animation shows exactly
 * that frame, so waiting and running are one animation in two states rather
 * than two states to keep in step.
 *
 * **Restarting reaches for the DOM.** There is no way to rewind a CSS animation
 * from React: re-rendering with the same class changes nothing, and a `key`
 * would restart the animation by unmounting the children, taking their state
 * with it. Clearing `animation-name`, reading a layout property to force the
 * style to settle, and putting it back is the one move that rewinds the element
 * and leaves everything inside it alone.
 *
 * **`visible` is measured rather than observed.** Two observers report and
 * neither decides: what they say is that the view has moved, and the answer is
 * then read off the element's own resting box. An `IntersectionObserver` sees
 * the element where its first frame is holding it, or where a running one has
 * got to, which for a slide is up to a screen from where it lives, so the box
 * it reports on is the wrong box.
 */
/**
 * Marks an element whose animation is being rewound, for the length of one
 * layout read. `src/styles.css` reads it to turn a pseudo-element's own
 * animation off and on again, which no inline style can do.
 */
const REWIND_ATTRIBUTE = 'data-plass-rewind';

/**
 * Marks a part whose run landed under reduced motion, until the next run.
 * `src/styles.css` reads it to keep the timing the run landed with once the
 * reader gives movement back.
 */
const LANDED_ATTRIBUTE = 'data-plass-landed';

/**
 * Marks a part of a run that `paused` held while reduced motion was showing it,
 * until the run is let go. `src/styles.css` reads it to keep the frame reduced
 * motion showed once the reader gives movement back.
 */
const HELD_ATTRIBUTE = 'data-plass-held';

/**
 * The delay a run started with, written onto the element or part it runs on
 * until the next run. `src/styles.css` reads it ahead of `--p-anim-delay`.
 */
const RUN_DELAY = '--p-anim-run-delay';

export function useAnimationRun({
  trigger,
  play,
  once,
  threshold,
  paused,
  infinite,
  endless = false,
  moves = false,
  nonce,
  target
}: AnimationRunOptions): AnimationRun {
  const node = React.useRef<HTMLElement | null>(null);

  // Whether it has been let go, and how many times it has been started. One
  // state rather than two, so `again` reads whether it has been let go after
  // every change queued before it, a `play` turned off in the same commit
  // included, rather than as the last render saw it.
  const [{ started, run }, setGate] = React.useState({ started: trigger === 'mount', run: 0 });

  const setStarted = React.useCallback((value: boolean) => {
    setGate((gate) => (gate.started === value ? gate : { ...gate, started: value }));
  }, []);

  const start = React.useCallback(() => {
    setGate((gate) => ({ started: true, run: gate.run + 1 }));
  }, []);

  // Starts it again only if it has been let go.
  const again = React.useCallback(() => {
    setGate((gate) => (gate.started ? { started: true, run: gate.run + 1 } : gate));
  }, []);

  // Nothing to rewind on the first pass — the element has only just been drawn.
  React.useLayoutEffect(() => {
    const element = node.current;

    if (!element || run === 0) {
      return;
    }

    // The element itself for the effects that animate their own root, and its
    // descendants for the ones that animate their children instead: a staggered
    // PlAnimateAppear has nothing to rewind on its own box.
    //
    // Only the descendants that are *this* animation's, though. Another
    // PlAnimate* nested inside is an animation with a trigger of its own, and
    // rewinding it too would fade an error message in again on every shake of
    // the form around it.
    const targets = ownParts(element);

    // An inline style cannot reach a pseudo-element, and the arc of a
    // `PlAnimateLighting` is drawn on one. The attribute is what the stylesheet
    // answers for those, and it is off again before anything is painted.
    element.setAttribute(REWIND_ATTRIBUTE, '');

    for (const target of targets) {
      target.removeAttribute(LANDED_ATTRIBUTE);
      target.removeAttribute(HELD_ATTRIBUTE);
      target.style.removeProperty(RUN_DELAY);
      target.style.animationName = 'none';
    }

    void element.offsetWidth;

    for (const target of targets) {
      target.style.animationName = '';
    }

    element.removeAttribute(REWIND_ATTRIBUTE);
  }, [run]);

  // What a keyframe's timing must not change once its run has begun: the delay
  // it started with, and the timing it landed with under reduced motion. Both
  // are held in the stylesheet until the next run, whose rewind takes them off.
  //
  // In the stylesheet rather than through `updateTiming()`, which would hold the
  // same timing on the animation itself. When the stylesheet's timing changes,
  // Chromium draws a keyframe whose timing a script has set with the
  // stylesheet's timing instead, and does not draw a finished one again, so a
  // landed fade stood at the opacity of a run a few hundred milliseconds in.
  React.useLayoutEffect(() => {
    const element = node.current;

    if (!element) {
      return undefined;
    }

    // A run under way keeps the delay it started with. A new `animation-delay`
    // applies to a keyframe that is already running, so a `delay` changed
    // during the run sent it back to waiting. The new one is waited out from
    // the next run, as in the Flutter build. A run still waiting has not
    // started and goes on reading the slot itself, so a new delay is measured
    // from when its wait began, as a keyframe measures one.
    //
    // Written on the root even for the arc of a `PlAnimateLighting`, which its
    // pseudo-element inherits. The slot is read inline where it is written,
    // which is everywhere but a marquee's strips, so a line split into a
    // hundred parts does not work out its style a hundred times as it starts.
    const hold = (event: AnimationEvent) => {
      const part = ownTarget(element, event);

      if (!part || part.style.getPropertyValue(RUN_DELAY) !== '') {
        return;
      }

      const delay = (
        part.style.getPropertyValue('--p-anim-delay') ||
        getComputedStyle(part).getPropertyValue('--p-anim-delay')
      ).trim();

      if (delay !== '') {
        part.style.setProperty(RUN_DELAY, delay);
      }
    };

    // A finite run that has landed under reduced motion stays where it landed
    // when the reader gives movement back. The stylesheet lands it by running
    // it in no time, and a keyframe goes on counting its time from when it
    // began, so handed its duration back before the run would have ended, it
    // stood that far into it and played on from there.
    //
    // An endless run is left to the stylesheet, which goes on from where its
    // passes would have got to by then: it has no last frame to stay on. So is
    // a scroll-linked one, which goes back to following the scroll.
    //
    // The arc of a `PlAnimateLighting` and the strips of a `PlAnimateMarquee`
    // are marked on their root, which is what the stylesheet holds them by:
    // the arc is a pseudo-element, and the strips after the first are not
    // drawn under reduced motion, so they never land.
    const land = (event: AnimationEvent) => {
      const part = ownTarget(element, event);

      if (!part || !prefersReducedMotion()) {
        return;
      }

      const style = getComputedStyle(part);

      if (
        style.getPropertyValue('--p-anim-repeat').trim() === 'infinite' ||
        style.getPropertyValue('--p-anim-timeline').trim() !== ''
      ) {
        return;
      }

      const marked = event.pseudoElement || part.matches(trackSelector) ? element : part;

      marked.setAttribute(LANDED_ATTRIBUTE, '');
    };

    element.addEventListener('animationstart', hold);
    element.addEventListener('animationend', land);

    return () => {
      element.removeEventListener('animationstart', hold);
      element.removeEventListener('animationend', land);
    };
  }, []);

  // A run held by `paused` keeps the frame reduced motion showed when the
  // reader gives movement back, until it is let go. A paused keyframe stands
  // where its clock stopped, which for an endless run that landed in no time
  // is where it landed, the start of a pass, and for a run paused before its
  // delay was over is ahead of its start, which with movement draws its first
  // frame: given its timing back, an endless fade held there went from fully
  // drawn to nearly gone, and a finite one from fully drawn to nothing. Let
  // go, it goes on from where its clock stands, as it did.
  //
  // Only while it is held, so a run that is not asks nothing of the media
  // query. A run waiting for its trigger is not held: it waits on its first
  // frame, as one that is not paused does. Nor is a scroll-linked one, which
  // goes back to following the scroll. A finite run that landed is marked as
  // landed as well, and keeps its last frame once it is let go.
  const holding = started && Boolean(paused);
  const reduced = useMediaQuery(holding ? reducedMotionQuery : null);
  const held = React.useRef(false);

  React.useLayoutEffect(() => {
    const element = node.current;

    if (!element) {
      return;
    }

    if (holding && reduced) {
      held.current = true;

      for (const part of ownParts(element)) {
        if (
          part.matches(animSelector) &&
          getComputedStyle(part).getPropertyValue('--p-anim-timeline').trim() === ''
        ) {
          part.setAttribute(HELD_ATTRIBUTE, '');
        }
      }
    } else if (!holding && held.current) {
      held.current = false;

      for (const part of ownParts(element)) {
        part.removeAttribute(HELD_ATTRIBUTE);
      }
    }
  }, [holding, reduced, run]);

  // Whether the element is still being held on its own first frame, which is
  // what the measurement below has to undo before it reads a box. A ref rather
  // than a dependency of that effect: `started` in its list would take both
  // observers down and put them back on every start.
  const waiting = React.useRef(trigger !== 'mount');

  React.useEffect(() => {
    waiting.current = !started;
  }, [started]);

  React.useEffect(() => {
    if (trigger !== 'visible') {
      return;
    }

    const element = node.current;

    if (!element || typeof IntersectionObserver === 'undefined') {
      // No observer means no way to know: show it rather than hide it forever.
      setStarted(true);

      return;
    }

    const observers: IntersectionObserver[] = [];
    const parent = element.parentElement;
    // Nothing to measure against until the parent has reported once, which it
    // does as soon as it is watched. Without a parent there is no clip but the
    // window, and that rectangle does not move.
    let clip: DOMRectReadOnly | null = parent ? null : viewportRect();
    // Whether the last measurement found it on screen. Not `once`, it starts
    // when it arrives and not on every report after that: the observers report
    // at every step its share crosses, and starting it again at each one
    // rewound an effect that had never left.
    let seen = false;

    const check = () => {
      if (!clip) {
        return;
      }

      const shown = visibleShare(restingRect(element, waiting.current), clip);

      // `> 0` as well, for the reason an observer's own `threshold: 0` means
      // any pixel of it: zero is the least that counts as seen, rather than a
      // reason to start something that is nowhere near the screen.
      if (shown > 0 && shown >= threshold) {
        if (once) {
          start();

          for (const observer of observers) {
            observer.disconnect();
          }
        } else if (!seen) {
          seen = true;
          start();
        }
      } else if (!once) {
        seen = false;
        setStarted(false);
      }
    };

    const steps = measureSteps(threshold);

    if (parent) {
      const above = new IntersectionObserver(
        ([entry]) => {
          clip = clipRect(entry);
          check();
        },
        { threshold: steps }
      );

      observers.push(above);
      above.observe(parent);
    }

    // The element as well, because a box taller than the screen keeps the same
    // share of itself in view the whole way down it: while the parent has
    // nothing left to report, the element crossing the view is what says the
    // reader has moved.
    const own = new IntersectionObserver(check, { threshold: steps });

    observers.push(own);
    own.observe(element);

    return () => {
      for (const observer of observers) {
        observer.disconnect();
      }
    };
  }, [trigger, once, threshold, start, setStarted]);

  // Held rather than compared against the previous render, so the first pass is
  // never a change: a shake that played itself on mount would be answering an
  // event that has not happened.
  const seen = React.useRef(nonce);

  React.useEffect(() => {
    if (Object.is(nonce, seen.current)) {
      return;
    }

    seen.current = nonce;
    start();
  }, [nonce, start]);

  React.useEffect(() => {
    if (trigger !== 'manual') {
      return;
    }

    // `play` is a caller pressing go, and what it starts is a CSS animation.
    // There is no external system to push to: the run counter *is* the rewind.
    if (play) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      start();
    } else {
      setStarted(false);
    }
  }, [trigger, play, start, setStarted]);

  // After the `play` above, so a `play` turned off in the same commit as a new
  // target has already held it back when this asks.
  const aimed = React.useRef(target);

  React.useEffect(() => {
    if (Object.is(target, aimed.current)) {
      return;
    }

    aimed.current = target;
    again();
  }, [target, again]);

  const handlers: React.HTMLAttributes<HTMLElement> =
    trigger === 'hover'
      ? {
          onPointerEnter: start,
          // Focus counts, or an effect on something keyboard-reachable would
          // never run for a reader who is not holding a mouse. What counts is
          // the focus *arriving*, though: focus events bubble, so tabbing from
          // one link inside the wrapper to the next is another one of these,
          // and starting the effect again there would replay it under the
          // reader's hands. A move with its other end already inside is a move
          // within one visit, which is the sentence Flutter's `Focus` says by
          // reporting a subtree entered and left and nothing in between.
          onFocus: (event) => {
            if (!holds(node.current, event.relatedTarget)) {
              start();
            }
          },
          onPointerLeave: () => {
            if (infinite) {
              setStarted(false);
            }
          },
          onBlur: (event) => {
            if (infinite && !holds(node.current, event.relatedTarget)) {
              setStarted(false);
            }
          }
        }
      : {};

  // Watched only while it is running. One that is waiting or held is already
  // still and has nothing to rest from. Nor under a `visible` trigger that is
  // not `once`, which already stops the effect when it leaves the view.
  const resting = useOffScreen(
    node,
    endless && started && !paused && !(trigger === 'visible' && !once),
    moves
  );

  return {
    ref: React.useCallback((element: HTMLElement | null) => {
      node.current = element;
    }, []),
    // Paused rather than taken off, so the keyframe holds the frame it was on
    // and goes on from it: nothing is rewound, because `run` has not moved.
    state: started && !paused && !resting ? 'running' : 'paused',
    started,
    resting,
    runs: run,
    handlers
  };
}

/* ---------------------------------------------------------------------------
 * One effect, told off across the children
 * ------------------------------------------------------------------------- */

export interface StaggerPosition extends Required<PlassAnimateStaggerProps> {
  index: number;
  count: number;
}

/**
 * Where one child sits in a staggered run.
 *
 * `reverse` turns the *order* round and nothing else: the last child goes
 * first and every child still plays forwards. An effect that ran backwards is
 * `mode="out"`, which is a different question and already has an answer.
 *
 * The duration is floored at zero rather than allowed to go negative, because a
 * negative `animation-duration` is invalid and an invalid declaration is
 * dropped — which would leave that one child playing at the CSS default while
 * its neighbours honoured the prop.
 */
export function staggerSlots(
  slots: AnimationSlotOptions,
  { index, count, stagger, durationStep, reverse }: StaggerPosition
): AnimationSlotOptions {
  const step = reverse ? count - 1 - index : index;

  return {
    ...slots,
    delay: slots.delay + step * stagger,
    duration: Math.max(0, slots.duration + step * durationStep)
  };
}

/**
 * Writes one effect onto each child, with that child's own slots.
 *
 * Onto the children **themselves** rather than onto wrappers around them, which
 * is the whole reason this is worth sharing: a row of `<li>`s stays a row of
 * `<li>`s, a grid's cells stay its direct children, and nothing about the
 * layout changes because the set is being animated. A wrapper per child would
 * break every one of those.
 *
 * The trade is the one `React.cloneElement` always makes — a child has to
 * accept a `className` and a `style` — and it is taken here and nowhere else in
 * the library. It is bearable because what is being copied is *only* the
 * animation, so a child that ignores both is a child that does not animate,
 * rather than a child that lands in the wrong place. `PlStack` draws a wrapper
 * per item instead, and takes the layout cost, precisely because *there* the
 * failure would not be survivable: a child that dropped the class would land in
 * the wrong place rather than merely arriving without an entrance.
 *
 * A bare string has no element to write onto, so that one is wrapped in a
 * `<span>`. It is the only case that gets a wrapper.
 */
export function animateChildren(
  children: React.ReactNode,
  className: string,
  slotsFor: (index: number, count: number) => React.CSSProperties
): React.ReactNode[] {
  const items = React.Children.toArray(children);

  return items.map((child, index) => {
    const style = slotsFor(index, items.length);

    if (!React.isValidElement(child)) {
      return React.createElement('span', { key: index, className, style }, child);
    }

    const childProps = child.props as { className?: string; style?: React.CSSProperties };

    return React.cloneElement(child as React.ReactElement<Record<string, unknown>>, {
      className: cx(className, childProps.className),
      style: { ...style, ...childProps.style }
    });
  });
}

/* ---------------------------------------------------------------------------
 * The six, assembled
 * ------------------------------------------------------------------------- */

/**
 * `endless` is left out because it is worked out here, from `repeat`, and
 * `target` because a keyframe has nothing to arrive at but its last frame.
 * `moves` is only needed for a keyframe of the component's own: the named ones
 * are already known.
 */
export interface AnimateElementParams
  extends
    AnimationSlotOptions,
    Omit<AnimationRunOptions, 'endless' | 'target'>,
    PlassAnimateStaggerProps {
  /** Which keyframe. `null` for the components that write their own. */
  effect: PlassAnimation | null;
  /** `transform-origin`, for the two effects that turn about a point. */
  origin?: string;
  /** Needed only to be handed back staggered. Passed straight through otherwise. */
  children?: React.ReactNode;
}

export interface AnimateElement {
  ref: React.RefCallback<HTMLElement>;
  className: string;
  style: React.CSSProperties;
  /**
   * The hover handlers and the two data attributes, to be merged with the
   * caller's props through `mergeProps` for the reason `AnimationRun.handlers`
   * gives.
   */
  props: React.HTMLAttributes<HTMLElement> & Record<string, unknown>;
  /** The children, with the effect written onto them if it was staggered. */
  children: React.ReactNode;
}

/**
 * Everything a one-keyframe `PlAnimate*` root needs, in one call.
 *
 * The six effect components differ only in their defaults and in which slots
 * they fill, so this is where the identical two-thirds of each of them lives.
 * The ones that have to understand their children — Appear, Headline, Marquee,
 * Typing — call `useAnimationRun` directly and put the classes where their own
 * structure needs them, which is why `effect` is allowed to be `null`.
 *
 * `data-plass-animation` and `data-state` are here rather than in each
 * component because they are the same two facts every time, and because a test
 * that has to assert on a class name is a test that breaks when a class name
 * changes.
 */
export function useAnimateElement(params: AnimateElementParams): AnimateElement {
  const {
    effect,
    trigger,
    play,
    once,
    threshold,
    paused,
    infinite,
    nonce,
    stagger = 0,
    durationStep = 0,
    reverse = false,
    origin,
    moves,
    children,
    ...slots
  } = params;

  const spread = stagger !== 0 && effect !== null;

  // A scroll timeline has no use for a trigger: the scroll position *is* the
  // trigger, and an effect left `paused` waiting to be scrolled into view would
  // sit on its own first frame while the reader scrolled straight past it. So
  // the run is told it mounted, which starts it, and `paused` — a caller saying
  // "hold it" rather than "wait for something" — goes on working.
  //
  // Nor does it rest off screen: it only advances while it is being scrolled
  // through, and a paused one would stop following the scroll.
  const run = useAnimationRun({
    trigger: slots.timeline === 'view' ? 'mount' : trigger,
    play,
    once,
    threshold,
    paused,
    infinite,
    endless: isInfinite(slots.repeat) && slots.timeline !== 'view',
    // Staggered, the effect is on the children and the root stays where it is.
    moves: !spread && (moves ?? (effect !== null && movingEffects.has(effect))),
    nonce
  });

  const effectClass = effect ? `${animBaseClass} ${animationClasses[effect]}` : '';
  const originStyle = origin === undefined ? null : { transformOrigin: origin };

  return {
    ref: run.ref,
    // Nothing on the root once the children are carrying the effect. Eight
    // children fading in under a box that is also fading in is the same content
    // faded twice, and the second one is not free.
    className: spread ? '' : effectClass,
    style: {
      ...originStyle,
      ...(spread ? null : animationSlots(slots)),
      '--p-anim-state': run.state
    } as React.CSSProperties,
    props: {
      ...run.handlers,
      'data-plass-animation': effect ?? undefined,
      'data-state': run.state
    },
    children: spread
      ? animateChildren(children, effectClass, (index, count) => ({
          ...originStyle,
          ...animationSlots(staggerSlots(slots, { index, count, stagger, durationStep, reverse }))
        }))
      : children
  };
}
