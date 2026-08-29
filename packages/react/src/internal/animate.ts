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
 * ## What is deliberately not here
 *
 * An effect that has to know what its children *are* — a marquee that lays them
 * down twice, a headline that swaps between them, a typewriter that counts
 * graphemes — cannot be a class name and a few numbers. Those are components,
 * and their logic stays in their own files.
 */

import * as React from 'react';
import type {
  PlassAnimateRepeat,
  PlassAnimateTrigger,
  PlassAnimation,
  PlassSide
} from '../types.js';

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
  blink: 'plass-anim-blink'
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

export interface AnimationSlotOptions {
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

  return slots as React.CSSProperties;
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

/**
 * Whether the reader has asked for less motion.
 *
 * The CSS side of this is handled in the stylesheet, where every keyframe is
 * switched off at once. This is for the effects whose motion is written in
 * JavaScript — a typewriter, a headline reel — where there is no rule to switch
 * off and the component has to decide for itself what "still" means.
 *
 * `useSyncExternalStore` rather than state plus an effect: a media query is an
 * external store, and reading it in an effect means every animated element on
 * the page renders once with the wrong answer and then again with the right
 * one. Here that first render is the one that would start a typewriter a reader
 * asked not to see.
 */
const reducedMotionQuery = '(prefers-reduced-motion: reduce)';

function subscribeToMotion(onChange: () => void): () => void {
  if (typeof window === 'undefined' || !window.matchMedia) {
    return () => {};
  }

  const query = window.matchMedia(reducedMotionQuery);

  query.addEventListener('change', onChange);

  return () => query.removeEventListener('change', onChange);
}

function readMotion(): boolean {
  return typeof window !== 'undefined' && window.matchMedia
    ? window.matchMedia(reducedMotionQuery).matches
    : false;
}

/** A server has no reader and so no preference. */
function motionOnServer(): boolean {
  return false;
}

export function usePrefersReducedMotion(): boolean {
  return React.useSyncExternalStore(subscribeToMotion, readMotion, motionOnServer);
}

export interface AnimationRunOptions {
  trigger: PlassAnimateTrigger;
  play?: boolean;
  once: boolean;
  threshold: number;
  paused?: boolean;
  /** An infinite effect stops when the pointer leaves; a finite one finishes. */
  infinite: boolean;
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
  infinite
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
 * The six, assembled
 * ------------------------------------------------------------------------- */

export interface AnimateElementParams extends AnimationSlotOptions, AnimationRunOptions {
  /** Which keyframe. `null` for the components that write their own. */
  effect: PlassAnimation | null;
}

export interface AnimateElement {
  ref: React.RefCallback<HTMLElement>;
  className: string;
  style: React.CSSProperties;
  /** The hover handlers and the two data attributes, ready to be spread. */
  props: React.HTMLAttributes<HTMLElement> & Record<string, unknown>;
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
  const { effect, trigger, play, once, threshold, paused, infinite, ...slots } = params;

  const run = useAnimationRun({ trigger, play, once, threshold, paused, infinite });

  return {
    ref: run.ref,
    className: effect ? `${animBaseClass} ${animationClasses[effect]}` : '',
    style: { ...animationSlots(slots), '--p-anim-state': run.state } as React.CSSProperties,
    props: {
      ...run.handlers,
      'data-plass-animation': effect ?? undefined,
      'data-state': run.state
    }
  };
}
