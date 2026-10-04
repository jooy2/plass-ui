'use client';

import * as React from 'react';
import { mergeProps } from '@base-ui/react/merge-props';
import { isInfinite, useAnimationRun, useOffScreen } from '../../internal/animate.js';
import { usePrefersReducedMotion } from '../../internal/media.js';
import { srOnlyClasses } from '../../internal/styles.js';
import { graphemesOf, textOf } from '../../internal/text.js';
import type { PlassAnimateProps } from '../../types.js';

export interface PlAnimateTypingProps
  extends
    Omit<PlassAnimateProps, 'alternate' | 'easing'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'children'> {
  /** The text, when it is easier to pass than to nest. Overrides `children`. */
  text?: string;
  /**
   * How fast it is typed, in characters per second.
   * @default 24
   */
  speed?: number;
  /**
   * How long the finished text is held before it repeats, in milliseconds.
   * @default 1400
   */
  hold?: number;
  /**
   * Deletes the text again before repeating, rather than clearing it in one
   * frame. Only means anything when `repeat` is more than once.
   * @default false
   */
  erase?: boolean;
  /**
   * How fast it is deleted, in characters per second. Deleting is usually about
   * twice as fast as typing, which is what a person actually does.
   * @default twice `speed`
   */
  eraseSpeed?: number;
  /**
   * The block after the text.
   * @default true
   */
  caret?: boolean;
  /** What the caret is drawn as. @default '|' */
  caretChar?: React.ReactNode;
  /** The text to type. Only text is typed — see below. */
  children?: React.ReactNode;
}

/**
 * Text appearing one character at a time.
 *
 * The whole string is in the document from the first frame — in a clipped box
 * for a screen reader, which reads it once and is not made to sit through the
 * performance — and what animates is a visible copy that is `aria-hidden`. So
 * the effect costs a reader who cannot see it nothing, and costs a reader who
 * can nothing either: the characters still to come are laid out after the
 * caret without being drawn, so the box holds the whole string from the first
 * frame and nothing around it moves as the text arrives.
 *
 * `repeat`, `hold` and `erase` are what make it a loop: type, hold, delete,
 * type again. Without `erase` a repeat clears in one frame, which is right for
 * a line that is being replaced rather than rewritten.
 *
 * Only text is typed. Pass a string, or strings; an element among the children
 * contributes its text and nothing about its markup, because there is no honest
 * way to reveal half of a link.
 */
export const PlAnimateTyping = /* @__PURE__ */ React.forwardRef<
  HTMLDivElement,
  PlAnimateTypingProps
>(function PlAnimateTyping(
  {
    text,
    speed = 24,
    hold = 1400,
    erase = false,
    eraseSpeed,
    caret = true,
    caretChar = '|',
    duration,
    delay = 0,
    repeat = 1,
    paused,
    trigger = 'mount',
    play,
    once = true,
    threshold = 0.2,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const run = useAnimationRun({
    trigger,
    play,
    once,
    threshold,
    paused,
    infinite: isInfinite(repeat),
    endless: isInfinite(repeat)
  });
  const reduced = usePrefersReducedMotion();

  const node = React.useRef<HTMLDivElement | null>(null);

  // The caret blinks for ever, after a typing that finishes as much as during
  // one that loops, so it rests off screen on its own account: a typing that
  // finishes is not endless, and goes on typing wherever it is.
  const caretResting = useOffScreen(node, caret && !reduced);

  const source = text ?? textOf(children);
  const graphemes = React.useMemo(() => graphemesOf(source), [source]);
  const total = graphemes.length;

  const [shown, setShown] = React.useState(0);

  /**
   * How far along it is, outside React's state.
   *
   * The typing loop is a chain of timeouts rather than a render, so pausing
   * tears it down and resuming builds a new one — and a new one has to know
   * where the old one stopped. Reading `shown` would put the effect in a loop
   * with its own output.
   */
  const progress = React.useRef(0);

  /**
   * Whether it was deleting when it stopped, kept beside `progress` for the
   * same reason: a loop held halfway through deleting its line goes on
   * deleting it, rather than typing it back out first.
   */
  const erasing = React.useRef(false);

  /**
   * Which pass of `repeat` it is on, kept beside `progress` as well. Counted
   * afresh each time the chain was built, a typing paused during its last pass
   * started counting from the first again when it was let go, and played every
   * pass it had already played a second time.
   */
  const pass = React.useRef(1);

  /**
   * Whether the typed-out line is being held before the next pass, kept beside
   * `erasing` as well. Marked as deleting from the start of the hold, a chain
   * built again during it deleted the next character at once; now it holds the
   * line first.
   */
  const holding = React.useRef(false);

  /**
   * What is left of the wait the chain is in, in milliseconds, or `null` when
   * it is in none: the `delay` before the first character, the wait before the
   * next one, the hold, or the wait before the first character of the next
   * pass. A chain built again goes on with what was left of it: let go during
   * the `delay` or between two passes, it used to wait the whole `delay` again,
   * and between two characters a whole character's time.
   */
  const waitLeft = React.useRef<number | null>(null);

  /**
   * `duration` is honoured as the time for the whole string, because a caller
   * who has set a duration on every other PlAnimate component will reach for it
   * here too. `speed` is the natural unit for a typewriter — a long paragraph
   * and a short one should be typed at the same pace, not in the same time — so
   * it is the default and the duration overrides it.
   */
  const typeDelay = duration && total > 0 ? duration / total : 1000 / Math.max(speed, 1);
  const deleteDelay = 1000 / Math.max(eraseSpeed ?? speed * 2, 1);

  // A new string starts a new performance rather than continuing the last, and
  // so does a new run: a second hover types the line again from its first
  // character, not from the end it already reached. The string itself rather
  // than how long it is — "design" becoming "deploy" is a new string, and
  // counting characters alone left it standing there already typed.
  React.useEffect(() => {
    progress.current = 0;
    erasing.current = false;
    pass.current = 1;
    holding.current = false;
    waitLeft.current = null;
  }, [source, run.runs]);

  React.useEffect(() => {
    if (reduced || total === 0) {
      // Not "nothing happens" — the text is simply there, which is the only
      // outcome that still delivers what the component was carrying.
      setShown(total);

      return;
    }

    if (!run.started) {
      // Waiting is empty, not finished: a typewriter that showed its whole
      // string until it scrolled into view and then blanked would be worse than
      // no effect at all.
      progress.current = 0;
      erasing.current = false;
      pass.current = 1;
      holding.current = false;
      waitLeft.current = null;
      setShown(0);

      return;
    }

    // Held by the caller, or resting off screen. Either way the chain is torn
    // down here and built again from `progress`, `erasing`, `pass`, `holding`
    // and `waitLeft` when it goes on.
    if (paused || run.resting) {
      return;
    }

    let cancelled = false;
    let timer: ReturnType<typeof setTimeout>;
    let count = progress.current;
    let deleting = erasing.current;
    // When the wait the chain is in, or what was left of it, started.
    let waitFrom = 0;

    const passes = repeat === 'infinite' ? Infinity : Math.max(1, repeat);

    if (count >= total && !deleting && pass.current >= passes) {
      return;
    }

    // Waits `ms`, then does `next`. Every wait in the chain goes through here,
    // so a chain torn down during any of them knows what was left of it.
    const wait = (ms: number, next: () => void) => {
      waitLeft.current = ms;
      waitFrom = performance.now();
      timer = setTimeout(() => {
        if (cancelled) {
          return;
        }

        waitLeft.current = null;
        next();
      }, ms);
    };

    // The line is typed out: hold it, then delete it or clear it for the next
    // pass, unless this was the last one. The pass is counted once the next
    // one starts, so a chain built again during the hold holds and goes on
    // rather than skipping a pass or playing one twice.
    const finish = () => {
      if (pass.current >= passes) {
        return;
      }

      holding.current = true;
      wait(hold, release);
    };

    // The hold is over: delete the line, or clear it for the next pass.
    const release = () => {
      holding.current = false;

      if (erase) {
        deleting = true;
        erasing.current = true;
        step();

        return;
      }

      pass.current += 1;
      count = 0;
      progress.current = 0;
      setShown(0);
      wait(typeDelay, step);
    };

    const step = () => {
      if (deleting) {
        count -= 1;
        progress.current = count;
        setShown(count);

        if (count <= 0) {
          deleting = false;
          erasing.current = false;
          pass.current += 1;
        }

        wait(deleting ? deleteDelay : typeDelay, step);

        return;
      }

      count += 1;
      progress.current = count;
      setShown(count);

      if (count < total) {
        wait(typeDelay, step);

        return;
      }

      finish();
    };

    setShown(count);

    // What was left of the wait it was let go in, if it was in one. Otherwise
    // it is starting, and waits out the `delay`.
    const left = waitLeft.current;

    if (holding.current) {
      // Resumed during the hold between two passes.
      wait(left ?? hold, release);
    } else if (count >= total && !deleting) {
      // Resumed with the line typed out and no hold begun, which is a pass that
      // `repeat` has since been raised past.
      finish();
    } else {
      // The next character, in the direction it was going.
      wait(left ?? (count === 0 ? delay : deleting ? deleteDelay : typeDelay), step);
    }

    return () => {
      cancelled = true;
      clearTimeout(timer);

      if (waitLeft.current !== null) {
        waitLeft.current = Math.max(0, waitLeft.current - (performance.now() - waitFrom));
      }
    };
    // `run.runs` and `source` are listed although nothing above reads them. A
    // second hover starts a new run without changing `started`, and a new run
    // types the line again; and a new string of the same length has to be typed
    // again rather than left standing where the last one finished.
  }, [
    run.started,
    run.runs,
    source,
    paused,
    run.resting,
    reduced,
    total,
    typeDelay,
    deleteDelay,
    delay,
    hold,
    erase,
    repeat
  ]);

  // A caret given as a string is drawn from an attribute too, for the reason
  // the line is: as text, the page's text ended every line in "||", the caret
  // and the room kept for it. One given as an element is drawn as it is.
  const caretText =
    typeof caretChar === 'string' || typeof caretChar === 'number' ? String(caretChar) : null;

  const caretGlyph = (className: string, style?: React.CSSProperties) =>
    caretText === null ? (
      <span className={className} style={style}>
        {caretChar}
      </span>
    ) : (
      <span
        data-text={caretText}
        className={`${className} before:content-[attr(data-text)]`}
        style={style}
      />
    );

  return (
    <div
      ref={(element) => {
        node.current = element;
        run.ref(element);

        if (typeof ref === 'function') {
          ref(element);
        } else if (ref) {
          (ref as React.RefObject<HTMLDivElement | null>).current = element;
        }
      }}
      className={className}
      style={style}
      data-plass-animation="typing"
      data-state={run.state}
      {...mergeProps(props, run.handlers)}
    >
      {/* The line, once, for a reader who is not watching it arrive. It is the
          only copy that is text, so it is also the one a selection copies. */}
      <span className={srOnlyClasses}>{source}</span>
      {/* `relative` so the caret, which is taken out of the flow, still scrolls
          and clips with the text inside a scrolling panel.

          The characters typed so far are generated content drawn from
          `data-text` rather than text, as every other text effect draws its
          line: written out, a finished line was in the page's text twice, once
          in the clipped copy and once here, and that is what a crawler that
          runs the page indexed. */}
      <span
        aria-hidden="true"
        data-text={graphemes.slice(0, shown).join('')}
        className="relative whitespace-pre-wrap before:content-[attr(data-text)]"
      >
        {/* Where the typing is, and taking no room there. An inline caret would
            carry its width along the line and add a place to break inside a
            word, so the box would change as it moved. */}
        {caret
          ? caretGlyph(
              'plass-caret absolute',
              caretResting ? { animationPlayState: 'paused' } : undefined
            )
          : null}
        {/* The characters still to come, and then the caret's room, laid out
            and not drawn, so every frame is laid out as the finished line and
            the server's HTML holds the box as well. The characters are
            generated content rather than text, for the reason `WidthSizer`
            gives: nothing selects them, copies them or finds them by text. */}
        <span
          data-sample={graphemes.slice(shown).join('')}
          className="invisible before:content-[attr(data-sample)]"
        >
          {caret ? caretGlyph('inline-block') : null}
        </span>
      </span>
    </div>
  );
});
