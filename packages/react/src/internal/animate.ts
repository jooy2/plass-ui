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
}

export interface AnimationRun {
  /** Goes on the animated element. */
  ref: React.RefCallback<HTMLElement>;
  /** `running` or `paused`, for `--p-anim-state`. */
  state: 'running' | 'paused';
  /** Whether the animation has been let go at all. */
  started: boolean;
  /** Spread onto the element when `trigger` is `hover`; empty otherwise. */
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
 */
export function useAnimationRun({
  trigger,
  play,
  once,
  threshold,
  paused,
  infinite,
  nonce
}: AnimationRunOptions): AnimationRun {
  const node = React.useRef<HTMLElement | null>(null);
  const [started, setStarted] = React.useState(trigger === 'mount');
  const [run, setRun] = React.useState(0);

  const start = React.useCallback(() => {
    setStarted(true);
    setRun((previous) => previous + 1);
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
    const targets: HTMLElement[] = [
      element,
      ...element.querySelectorAll<HTMLElement>('.plass-anim, .plass-marquee-track')
    ];

    for (const target of targets) {
      target.style.animationName = 'none';
    }

    void element.offsetWidth;

    for (const target of targets) {
      target.style.animationName = '';
    }
  }, [run]);

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

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          start();

          if (once) {
            observer.disconnect();
          }
        } else if (!once) {
          setStarted(false);
        }
      },
      { threshold }
    );

    observer.observe(element);

    return () => observer.disconnect();
  }, [trigger, once, threshold, start]);

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
  }, [trigger, play, start]);

  const handlers: React.HTMLAttributes<HTMLElement> =
    trigger === 'hover'
      ? {
          onPointerEnter: start,
          // Focus counts, or an effect on something keyboard-reachable would
          // never run for a reader who is not holding a mouse.
          onFocus: start,
          onPointerLeave: () => {
            if (infinite) {
              setStarted(false);
            }
          },
          onBlur: () => {
            if (infinite) {
              setStarted(false);
            }
          }
        }
      : {};

  return {
    ref: React.useCallback((element: HTMLElement | null) => {
      node.current = element;
    }, []),
    state: started && !paused ? 'running' : 'paused',
    started,
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

export interface AnimateElementParams
  extends AnimationSlotOptions, AnimationRunOptions, PlassAnimateStaggerProps {
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
  /** The hover handlers and the two data attributes, ready to be spread. */
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
    children,
    ...slots
  } = params;

  // A scroll timeline has no use for a trigger: the scroll position *is* the
  // trigger, and an effect left `paused` waiting to be scrolled into view would
  // sit on its own first frame while the reader scrolled straight past it. So
  // the run is told it mounted, which starts it, and `paused` — a caller saying
  // "hold it" rather than "wait for something" — goes on working.
  const run = useAnimationRun({
    trigger: slots.timeline === 'view' ? 'mount' : trigger,
    play,
    once,
    threshold,
    paused,
    infinite,
    nonce
  });

  const effectClass = effect ? `${animBaseClass} ${animationClasses[effect]}` : '';
  const spread = stagger !== 0 && effect !== null;
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
