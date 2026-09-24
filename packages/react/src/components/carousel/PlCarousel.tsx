'use client';

import * as React from 'react';
import { mergeProps } from '@base-ui/react/merge-props';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { PlIconButton } from '../icon-button/PlIconButton.js';
import { ChevronIcon, PauseIcon, PlayIcon } from '../../internal/icons.js';
import { usePrefersReducedMotion } from '../../internal/media.js';
import {
  cx,
  pictureSlotClasses,
  radiusClasses,
  sheetRestClasses,
  srOnlyClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassElevation, PlassSize, PlassStyleProps } from '../../types.js';

export interface PlCarouselProps
  extends
    PlassStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /**
   * Drop shadow depth of the frame. `0` — the default — is flat.
   * @default 0
   */
  elevation?: PlassElevation;
  /** Which slide is showing, counted from 0. Use with `onValueChange`. */
  value?: number;
  /** Which starts showing, for an uncontrolled carousel. @default 0 */
  defaultValue?: number;
  onValueChange?: (index: number) => void;
  /**
   * Whether the arrows wrap from the last slide back to the first. With it off
   * they go inert at the ends instead, which is the honest thing for a set that
   * has a beginning and an end — a gallery of three photographs does, a
   * rotating banner does not.
   * @default true
   */
  loop?: boolean;
  /**
   * Advances on its own, with a button over the frame that stops it and starts
   * it again.
   *
   * Off by default and deliberately so: a carousel that moves while it is being
   * read is the most complained-about pattern on the web. It pauses while the
   * pointer is over it and while the tab is in the background. It **stops** once
   * the focus comes into it, and stays stopped until the button starts it
   * again. For a reader who has asked for reduced motion it starts stopped.
   * @default false
   */
  autoPlay?: boolean;
  /** How long each slide is held, in milliseconds. @default 5000 */
  interval?: number;
  /** The previous/next buttons. @default true */
  arrows?: boolean;
  /** The row of position dots under the frame. @default true */
  indicators?: boolean;
  /**
   * The carousel's accessible name, and what the arrows and the dots are called.
   * Never drawn.
   * @default 'Carousel'
   */
  label?: string;
  /** @default 'Previous slide' */
  previousLabel?: string;
  /** @default 'Next slide' */
  nextLabel?: string;
  /** What the `autoPlay` button says while the carousel is stopped. @default 'Start slide show' */
  playLabel?: string;
  /** What it says while the carousel is playing. @default 'Stop slide show' */
  stopLabel?: string;
  /**
   * How one slide is named to a screen reader, and how its dot is labelled.
   * @default `Slide {index} of {count}`, from the label pack
   */
  slideLabel?: (index: number, count: number) => string;
  /** The slides. Every top-level child becomes one. */
  children?: React.ReactNode;
}

/** How far the arrows sit in from the frame's edge. */
const arrowInsetClasses: Record<PlassSize, string> = {
  xs: 'start-1 end-1',
  sm: 'start-1.5 end-1.5',
  md: 'start-2 end-2',
  lg: 'start-3 end-3',
  xl: 'start-4 end-4'
};

/** Where the `autoPlay` button sits: the top corner the reading starts from,
 * in as far as the arrows are from the sides. */
const toggleInsetClasses: Record<PlassSize, string> = {
  xs: 'top-1 start-1',
  sm: 'top-1.5 start-1.5',
  md: 'top-2 start-2',
  lg: 'top-3 start-3',
  xl: 'top-4 start-4'
};

/**
 * The dot ladder.
 *
 * A current dot is a short bar rather than a bigger circle: it grows along the
 * row it is in, so the row's height never changes and the dots either side of
 * it do not move. Width and colour are the only two things that travel, which
 * is what keeps this inside the house rule against scaling anything.
 */
const dotClasses: Record<PlassSize, { rest: string; current: string }> = {
  xs: { rest: 'h-1 w-1', current: 'h-1 w-3' },
  sm: { rest: 'h-1 w-1', current: 'h-1 w-3.5' },
  md: { rest: 'h-1.5 w-1.5', current: 'h-1.5 w-4' },
  lg: { rest: 'h-1.5 w-1.5', current: 'h-1.5 w-5' },
  xl: { rest: 'h-2 w-2', current: 'h-2 w-6' }
};

/** How long a smooth scroll of our own is given to arrive. */
const SETTLE_MS = 700;

/**
 * Scrolls the track, and nothing else, so that `slide` is the one in view.
 *
 * `scrollIntoView` would move every scrollable ancestor up to the window, so a
 * carousel partly off screen dragged the page to itself on every slide — once
 * per `interval` while it played. The offset is measured against the track
 * rather than read off `offsetLeft`, which counts from whichever ancestor is
 * positioned, and in physical pixels, which is also what `scrollLeft` counts in
 * under RTL. Left without a `behavior`, the track's own `scroll-behavior`
 * decides, which is smooth unless the reader has asked for reduced motion.
 */
function scrollTrackTo(track: HTMLElement, slide: HTMLElement, behavior?: ScrollBehavior) {
  track.scrollTo({
    left:
      track.scrollLeft + slide.getBoundingClientRect().left - track.getBoundingClientRect().left,
    behavior
  });
}

/**
 * A strip of slides, one of which is in view.
 *
 * The mechanism is a scroll container with CSS scroll snapping, and everything
 * good about this component follows from that one choice. Swiping on a phone
 * and two-finger dragging on a trackpad both work because they are the
 * browser's own scrolling and not a gesture handler pretending to be it. The
 * strip runs the other way under RTL without being told, because scrolling is
 * directional and `translate` is not. And nothing is transformed — the house
 * rule against moving a surface holds here for free, where a translated track
 * would have had to argue for an exception.
 *
 * The motion is `scroll-behavior: smooth`, which means a reader who has asked
 * for reduced motion gets an instant cut from the same code path rather than
 * from a second one written to remember them.
 *
 * Slides are not a sub-component. Every top-level child is wrapped in its own
 * slide, so `<PlCarousel><img /><img /></PlCarousel>` is the whole API — and the
 * wrapper is what carries the snap point, the width and the
 * `role="group"` / `aria-roledescription="slide"` pair a screen reader needs,
 * none of which a caller should have to remember to put on a photograph.
 */
export const PlCarousel = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlCarouselProps>(
  function PlCarousel(
    {
      variant = 'glass',
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      elevation = 0,
      value,
      defaultValue = 0,
      onValueChange,
      loop = true,
      autoPlay = false,
      interval = 5000,
      arrows = true,
      indicators = true,
      label: labelProp,
      previousLabel: previousLabelProp,
      nextLabel: nextLabelProp,
      playLabel: playLabelProp,
      stopLabel: stopLabelProp,
      slideLabel,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const labels = useLabels();
    const label = labelProp ?? labels.carousel;
    const previousLabel = previousLabelProp ?? labels.carouselPrevious;
    const nextLabel = nextLabelProp ?? labels.carouselNext;
    const playLabel = playLabelProp ?? labels.carouselPlay;
    const stopLabel = stopLabelProp ?? labels.carouselStop;
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';
    const density = densityProp ?? defaults.density ?? 'default';

    const nameSlide = slideLabel ?? labels.carouselSlide;

    // `toArray` is what drops the `null`s and `false`s a conditional slide
    // leaves behind, and what gives every remaining child a stable key.
    const slides = React.Children.toArray(children);
    const count = slides.length;

    const [uncontrolled, setUncontrolled] = React.useState(defaultValue);
    const index = Math.min(Math.max(value ?? uncontrolled, 0), Math.max(count - 1, 0));

    const trackRef = React.useRef<HTMLDivElement>(null);
    const slideRefs = React.useRef<(HTMLDivElement | null)[]>([]);
    // Set while the index is catching up with a scroll the reader performed. The
    // effect below skips those, or every drag would be answered by a scroll back
    // to where the browser had already put us.
    const fromScroll = React.useRef(false);
    const mounted = React.useRef(false);
    // Raised while a smooth scroll of our own is still travelling. Without it
    // the scroll events thrown on the way from slide 0 to slide 2 would each be
    // read as the reader landing on slide 1.
    const settling = React.useRef(false);
    // Raised while the track has no width, inside a hidden tab or a closed
    // disclosure, until the placement below has put the strip on the current
    // slide. A browser showing the track again puts back the offset it had when
    // it was hidden, and a scroll event that arrives before the placement,
    // which Firefox throws for that, reads the old slide rather than the reader
    // landing on one.
    const hidden = React.useRef(false);

    // Two different things hold the strip still, and they are kept apart on
    // purpose. The pointer over the frame is a *pause*: it lasts exactly as long
    // as the pointer does. The focus coming in is a *stop*: a keyboard reader
    // who has tabbed into a slide is reading it, and the strip stays where it is
    // until the button starts it again — leaving with the pointer, or with the
    // focus, does not.
    const [hovered, setHovered] = React.useState(false);
    // The reader's own answer to "should this be moving?", `true` for stopped.
    // `null` until they have given one, and until then it is the platform's
    // answer: a reader who asked for reduced motion starts stopped, and the
    // button is how they start it anyway.
    const [choice, setChoice] = React.useState<boolean | null>(null);
    const reducedMotion = usePrefersReducedMotion();
    const stopped = choice ?? reducedMotion;
    const playing = autoPlay && !stopped;
    const toggleRef = React.useRef<HTMLButtonElement>(null);
    const focusInside = React.useRef(false);
    // Raised when the button starts the strip while the focus is inside it. The
    // reader has just answered the focus, and moving it on to the arrows or a
    // slide does not stop what they started. Lowered when the focus leaves.
    const resumedInside = React.useRef(false);

    const go = React.useCallback(
      (next: number, viaScroll = false) => {
        if (count === 0) {
          return;
        }

        const wrapped = loop
          ? ((next % count) + count) % count
          : Math.min(Math.max(next, 0), count - 1);

        fromScroll.current = viaScroll;

        if (value === undefined) {
          setUncontrolled(wrapped);
        }

        if (wrapped !== index) {
          onValueChange?.(wrapped);
        }
      },
      [count, loop, value, index, onValueChange]
    );

    // Read by the placement below when the track only gets a width later, by
    // which time the slide may have changed. Written in a layout effect so it
    // is current before the browser lays out the frame the width arrives in.
    const indexRef = React.useRef(index);

    React.useLayoutEffect(() => {
      indexRef.current = index;
    });

    // The strip opens on the current slide rather than on the first, or a
    // carousel handed slide 3 marks its third dot over the first picture. Done
    // before the first paint, so the first picture is never seen, and
    // `instant`, so the strip does not travel to where it was always meant to
    // be. Slide 0 is where the browser already has a strip it has only just
    // laid out.
    React.useLayoutEffect(() => {
      const track = trackRef.current;

      if (!track) {
        return;
      }

      const place = () => {
        const slide = slideRefs.current[indexRef.current];

        if (slide) {
          scrollTrackTo(track, slide, 'instant');
        }
      };

      if (typeof ResizeObserver === 'undefined') {
        if (indexRef.current > 0) {
          place();
        }

        return;
      }

      hidden.current = track.clientWidth === 0;

      if (!hidden.current && indexRef.current > 0) {
        place();
      }

      // With no width, inside a hidden tab or a closed disclosure, there is
      // nothing to scroll, and a slide change in the meantime moves nothing:
      // the strip would appear on the first slide, or on the one it was hidden
      // on, under the current slide's dot. It is placed on the current slide
      // every time the width comes back, before that frame is painted.
      const observer = new ResizeObserver((entries) => {
        if (entries[entries.length - 1].contentRect.width === 0) {
          hidden.current = true;
        } else if (hidden.current) {
          hidden.current = false;
          place();
        }
      });

      observer.observe(track);

      return () => observer.disconnect();
      // The mount only: every later change of slide is the effect below's.
    }, []);

    React.useEffect(() => {
      if (fromScroll.current) {
        fromScroll.current = false;

        return;
      }

      // The first pass has nothing to do: the layout effect above has already
      // put the strip on the slide it opens on.
      if (!mounted.current) {
        mounted.current = true;

        return;
      }

      const track = trackRef.current;
      const slide = slideRefs.current[index];

      if (track && slide) {
        scrollTrackTo(track, slide);
      }

      settling.current = true;

      const timer = window.setTimeout(() => {
        settling.current = false;
      }, SETTLE_MS);

      return () => window.clearTimeout(timer);
    }, [index]);

    /**
     * Where the strip has settled, read off the scroll offset rather than
     * measured per slide: every slide is exactly the width of the frame, so the
     * offset divided by that width *is* the index. `Math.abs` is what makes it
     * hold under RTL, where a scroll position counts backwards from zero.
     */
    const handleScroll = () => {
      const track = trackRef.current;

      // `settling` is tested before anything is measured, and that order is the
      // point: a smooth scroll of our own throws events for most of a second,
      // and those are exactly the ones with nothing to answer. Reading
      // `clientWidth` first would force a layout on every one of them.
      if (settling.current || hidden.current || !track || track.clientWidth === 0) {
        return;
      }

      const nearest = Math.round(Math.abs(track.scrollLeft) / track.clientWidth);

      if (nearest !== index && nearest >= 0 && nearest < count) {
        go(nearest, true);
      }
    };

    // The interval reads `go` through a ref. `go` is a new function whenever an
    // inline `onValueChange` is, so with it among the effect's dependencies a
    // parent that renders every second restarted a five-second interval before
    // it ever fired, and the carousel never advanced.
    const goRef = React.useRef(go);

    React.useEffect(() => {
      goRef.current = go;
    });

    React.useEffect(() => {
      if (!playing || hovered || count < 2) {
        return;
      }

      const timer = window.setInterval(() => {
        if (document.hidden) {
          return;
        }

        goRef.current(index + 1);
      }, interval);

      return () => window.clearInterval(timer);
    }, [playing, hovered, count, interval, index]);

    const toggle = () => {
      const next = !stopped;

      setChoice(next);
      resumedInside.current = !next && focusInside.current;
    };

    const atStart = index <= 0;
    const atEnd = index >= count - 1;

    return (
      <div
        ref={ref}
        role="region"
        aria-roledescription={labels.carousel}
        aria-label={label}
        className={cx('flex flex-col', className)}
        style={{ ...surfaceSlots(color, elevation), ...style }}
        // Merged with the caller's props through `mergeProps` rather than spread
        // beside them, which kept only one of each pair: a caller's own
        // `onPointerEnter` or `onFocus` quietly turned the pause off.
        {...mergeProps(props, {
          onPointerEnter: () => setHovered(true),
          onPointerLeave: () => setHovered(false),
          onFocus: (event: React.FocusEvent<HTMLDivElement>) => {
            focusInside.current = true;

            // The button is the one place the focus can land without stopping
            // anything. A keyboard reader reaches it first and can stop the
            // strip from there, and a mouse press moves the focus onto it
            // before the click arrives — stopping on that focus would have
            // turned the click on "stop" into a click on "start".
            if (
              autoPlay &&
              (event.target as EventTarget) !== toggleRef.current &&
              !resumedInside.current
            ) {
              setChoice(true);
            }
          },
          onBlur: (event: React.FocusEvent<HTMLDivElement>) => {
            if (!event.currentTarget.contains(event.relatedTarget as Node | null)) {
              focusInside.current = false;
              resumedInside.current = false;
            }
          }
        })}
      >
        <div
          className={cx(
            'relative min-w-0 overflow-hidden',
            radiusClasses[size],
            sheetRestClasses[variant],
            transitionClasses
          )}
        >
          {/* First in the source, so it is the first thing a keyboard reader
              reaches and can stop the strip before anything else. A button
              whose name changes rather than a pressed toggle: "Stop slide show"
              says what pressing it does, where a pressed "Slide show" would
              make the reader work out which way round the state goes. Raised
              with `z-10` because it comes before the slides in the source, and
              anything positioned inside a slide would otherwise be painted over
              it. */}
          {autoPlay && count > 1 ? (
            <div className={cx('absolute z-10 flex', toggleInsetClasses[size])}>
              <PlIconButton
                ref={toggleRef}
                variant="glass"
                size={size}
                color={color}
                density={density}
                elevation={1}
                label={stopped ? playLabel : stopLabel}
                icon={stopped ? <PlayIcon /> : <PauseIcon />}
                onClick={toggle}
              />
            </div>
          ) : null}

          <div
            ref={trackRef}
            // Focusable, so the strip can be scrolled with the arrow keys by
            // whoever is not using a pointer. That is the browser's own key
            // handling on a scroll container, which means it is already right
            // under RTL — a handler of ours mapping ArrowRight to "next" would
            // not have been.
            tabIndex={0}
            role="group"
            aria-label={label}
            className={cx(
              'flex min-w-0 snap-x snap-mandatory overflow-x-auto scroll-smooth',
              'motion-reduce:scroll-auto',
              // The strip is driven by buttons and by dragging; a scrollbar
              // under it is a third control saying the same thing.
              '[scrollbar-width:none] [&::-webkit-scrollbar]:hidden',
              'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:[outline-offset:-2px]'
            )}
            onScroll={handleScroll}
          >
            {/* Keyed by the slide's own key, which `toArray` has given every
                element (by position where the caller gave none), so a slide
                added at the front does not remount every slide after it. */}
            {slides.map((slide, slideIndex) => (
              <div
                key={React.isValidElement(slide) ? (slide.key ?? slideIndex) : slideIndex}
                ref={(element) => {
                  slideRefs.current[slideIndex] = element;
                }}
                role="group"
                aria-roledescription={labels.slide}
                aria-label={nameSlide(slideIndex + 1, count)}
                // Deliberately *not* `aria-hidden` when off-screen. A slide can
                // hold a link or a button, and an `aria-hidden` subtree that is
                // still in the tab order is the exact shape of the bug where a
                // keyboard reader lands somewhere their screen reader refuses
                // to describe. The strip is scrollable, so everything in it is
                // genuinely reachable — hiding it would be a lie.
                //
                // A bare `<img>` as the slide is laid out to the slide's width,
                // which is what makes `<PlCarousel><img /></PlCarousel>` enough.
                className={cx('w-full shrink-0 grow-0 basis-full snap-start', pictureSlotClasses)}
              >
                {slide}
              </div>
            ))}
          </div>

          {arrows && count > 1 ? (
            <div
              className={cx(
                'pointer-events-none absolute inset-y-0 flex items-center',
                arrowInsetClasses[size]
              )}
            >
              <PlIconButton
                variant="glass"
                size={size}
                color={color}
                density={density}
                elevation={1}
                label={previousLabel}
                disabled={!loop && atStart}
                className="pointer-events-auto"
                // Drawn pointing down and turned, which is the one allowance the
                // no-transform rule makes — and turned the other way under RTL,
                // where "previous" is on the other side of the frame.
                icon={
                  <span className="flex rotate-90 items-center rtl:-rotate-90">
                    <ChevronIcon />
                  </span>
                }
                onClick={() => go(index - 1)}
              />
              <span className="flex-1" />
              <PlIconButton
                variant="glass"
                size={size}
                color={color}
                density={density}
                elevation={1}
                label={nextLabel}
                disabled={!loop && atEnd}
                className="pointer-events-auto"
                icon={
                  <span className="flex -rotate-90 items-center rtl:rotate-90">
                    <ChevronIcon />
                  </span>
                }
                onClick={() => go(index + 1)}
              />
            </div>
          ) : null}
        </div>

        {indicators && count > 1 ? (
          // No gap and no padding: each dot is a 24px press target with the dot
          // drawn in its middle, so the targets sit edge to edge without
          // overlapping and the dot lands about where the padding put it.
          <div className="flex shrink-0 items-center justify-center">
            {slides.map((_, dotIndex) => (
              <button
                key={dotIndex}
                type="button"
                aria-label={nameSlide(dotIndex + 1, count)}
                aria-current={dotIndex === index ? 'true' : undefined}
                // The press target is 24px on each side, what WCAG 2.5.8 asks
                // for, around a dot a few pixels across. The dot is the only
                // thing drawn.
                className={cx(
                  'group flex h-6 min-w-6 cursor-pointer items-center justify-center rounded-full',
                  'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:outline-offset-0'
                )}
                onClick={() => go(dotIndex)}
              >
                <span
                  aria-hidden="true"
                  className={cx(
                    'rounded-full',
                    // Width and colour, never a transform: the current dot grows
                    // along the row instead of scaling, so nothing beside it
                    // moves.
                    '[transition-property:width,background-color]',
                    '[transition-duration:var(--plass-duration)]',
                    '[transition-timing-function:var(--plass-ease)]',
                    dotIndex === index
                      ? `${dotClasses[size].current} bg-(--p-accent)`
                      : `${dotClasses[size].rest} bg-(--plass-border) group-hover:bg-(--p-accent)`
                  )}
                />
              </button>
            ))}
          </div>
        ) : null}

        {/* Where the reader is, as a sentence rather than as a highlighted dot.
            Silent while the carousel is advancing on its own: a live region
            that says a new slide's name every five seconds is what makes a
            screen reader unusable on a page that has one. Once it is stopped
            the reader is the one moving it, and hears where they went. */}
        <span className={srOnlyClasses} aria-live={playing ? 'off' : 'polite'}>
          {count > 0 ? nameSlide(index + 1, count) : ''}
        </span>
      </div>
    );
  }
);
