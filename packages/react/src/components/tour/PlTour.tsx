'use client';

import * as React from 'react';
import { Popover as BaseUIPopover } from '@base-ui/react/popover';
import { PlButton } from '../button/index.js';
import { useDefaults } from '../../internal/defaults.js';
import { CloseIcon } from '../../internal/icons.js';
import { useLabels } from '../../internal/labels.js';
import { inflate, spotlightPath, type PlassSpot } from '../../internal/tour.js';
import {
  cx,
  focusRingClasses,
  glassClasses,
  hasContent,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceSlots
} from '../../internal/styles.js';
import type { PlassAlign, PlassColor, PlassDensity, PlassSide, PlassSize } from '../../types.js';

/**
 * What a step is about.
 *
 * Three forms, and the first is the one to reach for. A **ref** is checked by
 * the compiler and survives a rename; a **selector** is a string that can stop
 * matching the moment somebody renames a class, and the tour would go on
 * running with the hole over an empty piece of background. The selector is here
 * because it is the only form that works when the target belongs to something
 * this page does not render — a third-party widget, a page rendered by a
 * framework's router — and the **getter** is for the case where finding it is
 * more than one query.
 */
export type PlTourTarget =
  string | React.RefObject<Element | null> | (() => Element | null | undefined);

/** One stop on the tour. */
export interface PlTourStep {
  /**
   * What this step is about. Left out, the step is centred over the page with
   * nothing cut out of the dimming — which is what a welcome step and a closing
   * step are.
   */
  target?: PlTourTarget;
  /** The step's heading. */
  title?: React.ReactNode;
  /** What it says. */
  content?: React.ReactNode;
  /** Which edge of the target the card sits on. @default 'bottom' */
  side?: PlassSide;
  /** Where along that edge. @default 'center' */
  align?: PlassAlign;
  /**
   * How far the cut-out is grown past the target, in pixels.
   *
   * A control with a focus ring wants a few, so the ring is inside the light
   * rather than cut in half by its edge; a whole panel wants none.
   * @default 6
   */
  padding?: number;
  /** The cut-out's corner radius, in pixels. Defaults to the size's own. */
  radius?: number;
}

/** The parts of a tour a caller can reach past the card itself. */
export interface PlTourClassNames {
  /**
   * The dimming, which is a sibling of the card rather than something inside
   * it and so has no other way in.
   */
  mask?: string;
  /** The heading. */
  title?: string;
  /** The body. */
  content?: string;
  /** The × in the corner. */
  close?: string;
  /** The row holding the counter and the buttons. */
  footer?: string;
}

export interface PlTourProps {
  /** The stops, in order. */
  steps: readonly PlTourStep[];
  /** Whether the tour is running. Pass it with `onOpenChange` to control one. */
  open?: boolean;
  /** Whether it starts running, when the tour keeps that itself. @default false */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Which stop, counted from `0`. Pass it with `onStepChange` to control one. */
  step?: number;
  /** Which one it starts on, when the tour keeps that itself. @default 0 */
  defaultStep?: number;
  onStepChange?: (step: number) => void;
  /** Called when the last step's button is pressed, before the tour closes. */
  onFinish?: () => void;
  /**
   * Dims the page and cuts the target out of the dimming.
   *
   * Off, the card is the only thing the tour draws, which is right for a tour
   * over a page the reader is meant to keep working in.
   * @default true
   */
  mask?: boolean;
  /** Draws the Skip button beside the counter. @default true */
  skippable?: boolean;
  /** Whether Escape and the × end the tour. @default true */
  dismissible?: boolean;
  /** Scrolls each target into view as the tour reaches it. @default true */
  scrollIntoView?: boolean;
  /** The Previous button. Defaults to the locale's word. */
  previousLabel?: React.ReactNode;
  /** The Next button. */
  nextLabel?: React.ReactNode;
  /** What Next becomes on the last step. */
  doneLabel?: React.ReactNode;
  /** The Skip button. */
  skipLabel?: React.ReactNode;
  /** Type scale and the card's width. */
  size?: PlassSize;
  /** Semantic colour role: the buttons, the focus ring and the ring round the light. */
  color?: PlassColor;
  /** The card's padding. Never the type scale. */
  density?: PlassDensity;
  /** Class names for the card. */
  className?: string;
  /** Class names for the parts around it. */
  classNames?: PlTourClassNames;
}

/** How wide the card is allowed to get — a `PlPopover`'s own ladder. */
const maxWidthClasses: Record<PlassSize, string> = {
  xs: 'max-w-56',
  sm: 'max-w-64',
  md: 'max-w-80',
  lg: 'max-w-96',
  xl: 'max-w-lg'
};

/** The buttons on the card, one rung under the card's own scale. */
const buttonSizes: Record<PlassSize, PlassSize> = {
  xs: 'xs',
  sm: 'xs',
  md: 'sm',
  lg: 'sm',
  xl: 'md'
};

/** The cut-out's corner radius, matching the radius ladder in pixels. */
const holeRadius: Record<PlassSize, number> = {
  xs: 6,
  sm: 8,
  md: 10,
  lg: 12,
  xl: 14
};

/** The card. The same frosted sheet a `PlPopover` draws, at the same elevation. */
const popupClasses = /* @__PURE__ */ [
  glassClasses,
  'relative flex flex-col',
  'border text-(--plass-fg) bg-(--plass-glass-press)',
  '[border-color:var(--plass-glass-line)]',
  '[box-shadow:var(--plass-shadow-3),var(--plass-gloss-glass)]',
  '[outline:none]',
  '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

/** The × in the corner, the same one a `PlPopover` draws. */
const closeButtonClasses = /* @__PURE__ */ [
  'flex size-[1.6em] shrink-0 cursor-pointer items-center justify-center',
  'rounded-full text-(--plass-muted-fg)',
  '[&_svg]:size-[1.1em] [&_svg]:shrink-0',
  '[transition:background-color_var(--plass-duration)_var(--plass-ease),color_var(--plass-duration)_var(--plass-ease)]',
  'hover:bg-(--p-soft) hover:text-(--plass-fg)',
  focusRingClasses
].join(' ');

/** Whatever the step is pointing at, in whichever of the three forms it came. */
function resolve(target: PlTourTarget | undefined): Element | null {
  if (target === undefined) {
    return null;
  }

  if (typeof target === 'string') {
    return document.querySelector(target);
  }

  if (typeof target === 'function') {
    return target() ?? null;
  }

  return target.current ?? null;
}

/**
 * A guided walk over a page that already exists — the three things a new reader
 * has to be shown once, pointed at where they actually are.
 *
 * It is [`PlHowToSteps`](../surfaces/how-to-steps) turned inside out. That
 * component puts the instructions *in* the page and the reader follows them;
 * this one leaves the page as it is and stands over it. So a step says what it
 * is about rather than describing it: what a tour points at is already on
 * screen, and a second copy inside the card is a second copy to keep in step.
 *
 * ```tsx
 * <PlTour
 *   defaultOpen
 *   steps={[
 *     { target: filterRef, title: 'Narrow the list', content: 'Type here…' },
 *     { target: '#export', title: 'Take it with you', side: 'left' }
 *   ]}
 * />
 * ```
 *
 * **The dimming takes the pointer and the light does not.** The scrim is one
 * element clipped to the whole viewport with the target cut out of it, and a
 * clipped-away region is not hit-tested — so the control being pointed at can
 * be used and nothing else can. That is the difference between a tour and a
 * dialog with a picture of a control in it, and it falls out of the geometry
 * rather than being a second mechanism that has to agree with it.
 */
export function PlTour({
  steps,
  open,
  defaultOpen = false,
  onOpenChange,
  step,
  defaultStep = 0,
  onStepChange,
  onFinish,
  mask = true,
  skippable = true,
  dismissible = true,
  scrollIntoView = true,
  previousLabel,
  nextLabel,
  doneLabel,
  skipLabel,
  size: sizeProp,
  color: colorProp,
  density: densityProp,
  className,
  classNames
}: PlTourProps) {
  const defaults = useDefaults();
  const labels = useLabels();
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';

  const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen);
  const [uncontrolledStep, setUncontrolledStep] = React.useState(defaultStep);

  const running = open ?? uncontrolledOpen;
  const index = Math.min(step ?? uncontrolledStep, Math.max(0, steps.length - 1));
  const current: PlTourStep | undefined = steps[index];

  /**
   * Where the light is, tagged with the step it was measured for.
   *
   * Tagged rather than bare, because the step changes a frame before the effect
   * re-measures: an untagged rectangle would put the *last* step's hole around
   * the next step's card for one paint, which is exactly the flicker a tour is
   * supposed to be too calm for.
   */
  const [measured, setMeasured] = React.useState<{ at: number; spot: PlassSpot } | null>(null);

  const setOpen = (next: boolean) => {
    if (open === undefined) {
      setUncontrolledOpen(next);
    }

    onOpenChange?.(next);
  };

  const goTo = (next: number) => {
    if (step === undefined) {
      setUncontrolledStep(next);
    }

    onStepChange?.(next);
  };

  const target = current?.target;
  const padding = current?.padding ?? 6;

  /**
   * Where the target is, re-read on anything that could move it.
   *
   * A tour runs over a live page. Something below it can finish loading, an
   * image can arrive, the window can be resized — and the light would be left
   * over a piece of empty background. The scroll listener is what makes the
   * cut-out follow rather than pinning the page, because the page is not
   * pinned: the reader is meant to be able to use what is being pointed at.
   */
  React.useEffect(() => {
    if (!running) {
      return undefined;
    }

    const element = resolve(target);

    // Nothing to measure — a welcome step, or a target that is not on the page
    // yet. The measurement is tagged with the step it was taken for, so the one
    // left over from the step before is already not this step's.
    if (!(element instanceof HTMLElement)) {
      return undefined;
    }

    if (scrollIntoView) {
      element.scrollIntoView({ block: 'center', inline: 'nearest', behavior: 'smooth' });
    }

    let frame = 0;

    const read = () => {
      frame = 0;

      const rect = element.getBoundingClientRect();

      setMeasured({
        at: index,
        spot: inflate(
          { top: rect.top, left: rect.left, width: rect.width, height: rect.height },
          padding
        )
      });
    };

    // Coalesced to one read per frame: a scroll fires far more often than the
    // page paints, and each read is a forced layout.
    const schedule = () => {
      if (frame === 0) {
        frame = requestAnimationFrame(read);
      }
    };

    read();

    const observer = typeof ResizeObserver === 'undefined' ? null : new ResizeObserver(schedule);

    observer?.observe(element);
    window.addEventListener('scroll', schedule, { passive: true, capture: true });
    window.addEventListener('resize', schedule, { passive: true });

    return () => {
      if (frame !== 0) {
        cancelAnimationFrame(frame);
      }

      observer?.disconnect();
      window.removeEventListener('scroll', schedule, true);
      window.removeEventListener('resize', schedule);
    };
  }, [running, target, padding, index, scrollIntoView]);

  if (steps.length === 0) {
    return null;
  }

  const spot = running && measured?.at === index ? measured.spot : null;
  const first = index === 0;
  const last = index === steps.length - 1;

  const finish = () => {
    onFinish?.();
    setOpen(false);
  };

  const insetX = sheetPaddingXClasses[density][size];
  const insetY = sheetPaddingYClasses[density][size];
  const buttonSize = buttonSizes[size];
  const hasHeader = hasContent(current?.title) || hasContent(current?.content);

  return (
    <BaseUIPopover.Root
      open={running}
      onOpenChange={(next, details) => {
        if (!next && !dismissible && details.reason === 'escape-key') {
          details.cancel();

          return;
        }

        // Using the page is exactly what a tour is for, so neither a press
        // outside the card nor the focus leaving it ends one. Escape, the ×
        // and the card's own buttons do.
        if (!next && (details.reason === 'outside-press' || details.reason === 'focus-out')) {
          details.cancel();

          return;
        }

        setOpen(next);
      }}
    >
      <BaseUIPopover.Portal>
        {/*
          Inside the portal with the card rather than beside the tour, and it
          has to be: `position: fixed` is relative to the nearest ancestor with
          a transform, a filter or a `backdrop-filter` — and a backdrop filter
          is what every glass surface in this library is made of. A mask left
          where the tour was written would be contained by the `PlCard` around
          it, at a size and an origin that have nothing to do with the
          viewport the clip is measured against.
        */}
        {running && mask ? (
          <div
            aria-hidden="true"
            data-testid="plass-tour-mask"
            className={cx(
              'plass-portal fixed inset-0 z-(--plass-z-portal)',
              'bg-(--plass-scrim) [backdrop-filter:blur(2px)] [-webkit-backdrop-filter:blur(2px)]',
              '[transition:opacity_var(--plass-duration-slow)_var(--plass-ease)]',
              classNames?.mask
            )}
            style={{
              clipPath: spotlightPath(spot, current?.radius ?? holeRadius[size])
            }}
          />
        ) : null}

        <BaseUIPopover.Positioner
          className="plass-portal z-(--plass-z-portal) [outline:none]"
          side={current?.side ?? 'bottom'}
          align={current?.align ?? 'center'}
          sideOffset={10}
          collisionPadding={12}
          // A getter rather than an element: the target is found on whatever
          // the page looks like right now, and it is a different one every step.
          anchor={() => resolve(current?.target)}
        >
          <BaseUIPopover.Popup
            className={cx(
              popupClasses,
              radiusClasses[size],
              sheetBodyClasses[size],
              sheetSectionGapClasses[size],
              maxWidthClasses[size],
              insetX,
              insetY,
              className
            )}
            style={surfaceSlots(color, 3)}
          >
            {hasHeader ? (
              <div className="flex items-start gap-3">
                <div className={cx('flex min-w-0 flex-1 flex-col', sheetHeaderGapClasses[size])}>
                  {hasContent(current?.title) ? (
                    <BaseUIPopover.Title
                      className={cx(
                        'm-0 font-semibold',
                        sheetTitleClasses[size],
                        classNames?.title
                      )}
                    >
                      {current?.title}
                    </BaseUIPopover.Title>
                  ) : null}
                  {hasContent(current?.content) ? (
                    <BaseUIPopover.Description className={cx('m-0 min-w-0', classNames?.content)}>
                      {current?.content}
                    </BaseUIPopover.Description>
                  ) : null}
                </div>

                {dismissible ? (
                  <button
                    type="button"
                    aria-label={labels.close}
                    onClick={() => setOpen(false)}
                    className={cx(closeButtonClasses, classNames?.close)}
                  >
                    <CloseIcon />
                  </button>
                ) : null}
              </div>
            ) : null}

            <div className={cx('flex items-center gap-2', classNames?.footer)}>
              {/* Two numbers rather than a sentence. "3 of 7" is a string that
                  has to be translated and a word order that differs by
                  language; the count itself does not. */}
              <span
                className={cx(
                  'shrink-0 tabular-nums text-(--plass-muted-fg)',
                  metaTextClasses[size]
                )}
              >
                {index + 1} / {steps.length}
              </span>

              <div className="ms-auto flex items-center gap-2">
                {skippable && !last ? (
                  <PlButton
                    size={buttonSize}
                    variant="ghost"
                    color="secondary"
                    onClick={() => setOpen(false)}
                  >
                    {skipLabel ?? labels.skip}
                  </PlButton>
                ) : null}
                {!first ? (
                  <PlButton
                    size={buttonSize}
                    variant="ghost"
                    color={color}
                    onClick={() => goTo(index - 1)}
                  >
                    {previousLabel ?? labels.previous}
                  </PlButton>
                ) : null}
                <PlButton
                  size={buttonSize}
                  color={color}
                  onClick={() => (last ? finish() : goTo(index + 1))}
                >
                  {last ? (doneLabel ?? labels.done) : (nextLabel ?? labels.next)}
                </PlButton>
              </div>
            </div>
          </BaseUIPopover.Popup>
        </BaseUIPopover.Positioner>
      </BaseUIPopover.Portal>
    </BaseUIPopover.Root>
  );
}
