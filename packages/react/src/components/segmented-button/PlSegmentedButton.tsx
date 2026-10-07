'use client';

import * as React from 'react';
import { useCommitChange } from '../../internal/commit-change.js';
import { controlNaming, useDisabled } from '../../internal/form.js';
import { glowPointerMove } from '../../internal/glow.js';
import { useDefaults } from '../../internal/defaults.js';
import { Radio as BaseUIRadio } from '@base-ui/react/radio';
import { RadioGroup as BaseUIRadioGroup } from '@base-ui/react/radio-group';
import {
  controlHeightClasses,
  controlSlots,
  controlTextClasses,
  focusRingInsetClasses,
  forcedCheckedTextClasses,
  forcedFieldEdgeClasses,
  forcedFillClasses,
  gapClasses,
  glassClasses,
  hasContent,
  iconClasses,
  paddingXClasses,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassDensity,
  PlassElevation,
  PlassSize,
  PlassStyleProps,
  PlassVariant
} from '../../types.js';

/** A segment's value. The same restraint `PlSelect` puts on its own. */
export type PlSegmentValue = string | number;

/**
 * What a `PlSegment` inherits from the group around it.
 *
 * `variant`, `size` and `density` are properties of the *set*. A segmented
 * button whose third segment is a size out is not a segmented button.
 */
interface SegmentedButtonContextValue {
  variant: PlassVariant;
  size: PlassSize;
  density: PlassDensity;
  fullWidth: boolean;
  /**
   * Whether the labels of a full-width set together need more than its row,
   * which lets every segment shrink in proportion to what it needs and cut its
   * label short. See `fit` in `PlSegmentedButton`.
   */
  overfull: boolean;
  /**
   * Whether the whole set is disabled, which fades the set and takes every
   * segment's light with it.
   */
  disabled: boolean;
  /**
   * Whether the whole set is read-only, which puts every segment's light out:
   * a segment that cannot be chosen does not answer the pointer.
   */
  readOnly: boolean;
}

const SegmentedButtonContext = /* @__PURE__ */ React.createContext<SegmentedButtonContextValue>({
  variant: 'glass',
  size: 'md',
  density: 'default',
  fullWidth: false,
  overfull: false,
  disabled: false,
  readOnly: false
});

export interface PlSegmentedButtonProps
  extends
    Omit<PlassStyleProps, 'variant'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /**
   * What the groove and the tile riding in it are made of.
   *
   * - `solid` — a groove cut into the sheet with a **tinted-glass key** riding
   *   in it. The loudest, and the one for a control a screen is about to be
   *   steered by.
   * - `glass` — the same groove with a hairline round it and a clear tile
   *   rather than a coloured one. The default.
   * - `ghost` — no groove at all: the segments sit straight on the page and only
   *   the chosen one has a surface.
   * @default 'glass'
   */
  variant?: PlassVariant;
  /** The chosen segment. Use with `onValueChange` for a controlled set. */
  value?: PlSegmentValue | null;
  /** Which starts chosen, for an uncontrolled set. */
  defaultValue?: PlSegmentValue | null;
  onValueChange?: (value: PlSegmentValue | null) => void;
  /**
   * Drop shadow depth of the groove. `0` is the default — a groove is cut into
   * the page, not laid on it.
   * @default 0
   */
  elevation?: PlassElevation;
  /** Disables every segment at once. */
  disabled?: boolean;
  /** Shows which one is chosen but does not let it be changed. */
  readOnly?: boolean;
  /** Identifies the value when a form is submitted. */
  name?: string;
  /**
   * The segments share the full width, an equal part each. A segment whose
   * label needs more than its part keeps the width it needs, and the others
   * share the rest. Labels that together need more than the row end in an
   * ellipsis.
   */
  fullWidth?: boolean;
  children?: React.ReactNode;
}

export interface PlSegmentProps extends Omit<
  React.ComponentPropsWithoutRef<'span'>,
  'value' | 'color'
> {
  /** Identifies the segment. What `onValueChange` reports. */
  value: PlSegmentValue;
  /** Content before the label. Sized in `em`, so it tracks the label. */
  startIcon?: React.ReactNode;
  /** Content after the label — a count, a status dot. */
  endIcon?: React.ReactNode;
  /** Unavailable, but still part of the set. */
  disabled?: boolean;
  children?: React.ReactNode;
}

/* ---------------------------------------------------------------------------
 * The groove and the tile
 * ------------------------------------------------------------------------- */

/**
 * The groove carries `--plass-well`, the one inset shadow in the library and
 * the same one a `solid` field is drawn with. A segmented button, a slider's
 * rail and a filled text field are the same idea: something recessed that holds
 * a value.
 */
const troughClasses: Record<PlassVariant, string> = {
  solid: `${glassClasses} bg-(--plass-glass-press) p-1 [box-shadow:var(--p-elev),var(--plass-well)] ${forcedFieldEdgeClasses}`,
  glass: `${glassClasses} border bg-(--plass-glass) p-1 [border-color:var(--plass-glass-line)] [box-shadow:var(--p-elev),var(--plass-well)]`,
  ghost: ''
};

/**
 * The tile that slides.
 *
 * `solid` makes it the family's gradient with that family's tinted shadow under
 * it — a key of tinted glass riding in a groove, which is the design language's
 * own sentence with nothing added. The other two lift a pane of clear glass
 * instead and leave the label in the accent.
 *
 * The gradient is a layer of its own, `.plass-fill`, lit once the tile has been
 * placed under its first segment, so a first choice fades the fill in where it
 * lands. As the tile's own background it arrived in one frame, since the tile is
 * mounted by that choice and no browser eases a gradient in from nothing.
 */
const tileClasses: Record<PlassVariant, string> = {
  solid:
    'plass-fill data-[placed]:[--p-fill-on:1] [box-shadow:var(--plass-shadow-1),var(--p-lift)]',
  glass: `${glassClasses} bg-(--plass-glass-press) [box-shadow:var(--plass-shadow-1),var(--plass-gloss-glass)]`,
  ghost: `${glassClasses} bg-(--plass-glass-press) [box-shadow:var(--plass-shadow-1),var(--plass-gloss-glass)]`
};

/** What the chosen label is written in, which is the other half of the tile. */
const checkedTextClasses: Record<PlassVariant, string> = {
  solid: 'data-[checked]:text-(--p-on-solid)',
  glass: 'data-[checked]:text-(--p-accent)',
  ghost: 'data-[checked]:text-(--p-accent)'
};

/**
 * One choice in a segmented button.
 *
 * It has no `size`, no `color` and no `variant` of its own: all three belong to
 * the set, which is the only place they can be set once and mean the same thing
 * for every segment.
 */
export const PlSegment = /* @__PURE__ */ React.forwardRef<HTMLElement, PlSegmentProps>(
  function PlSegment(
    {
      value,
      startIcon,
      endIcon,
      disabled: disabledProp = false,
      className,
      children,
      onPointerMove,
      ...props
    },
    ref
  ) {
    const {
      variant,
      size,
      density,
      fullWidth,
      overfull,
      disabled: setDisabled,
      readOnly
    } = React.useContext(SegmentedButtonContext);
    const disabled = useDisabled(disabledProp);
    // Base UI disables every segment of a disabled set, and the set puts out
    // their light as well as its own. A read-only set keeps its segments
    // enabled but puts their light out too, since none of them can be chosen.
    const lit = !disabled && !setDisabled && !readOnly;

    return (
      <BaseUIRadio.Root
        ref={ref}
        value={value}
        disabled={disabled}
        // The hook the tile is measured from. A ref per segment would mean keeping
        // an array in step with however the caller composed them — through a
        // `.map()`, through a fragment, through a component of their own — and one
        // attribute is the version of that which cannot fall out of step.
        data-segment=""
        className={[
          // `z-10` and a stacking context of its own: the tile is painted behind
          // the segments, and without this it would cover the label it is under.
          'relative z-10 inline-flex cursor-pointer items-center justify-center select-none',
          'font-semibold whitespace-nowrap',
          '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
          controlHeightClasses[size],
          controlTextClasses[size],
          gapClasses[size],
          paddingXClasses[density][size],
          // Round, and one of only three places the library allows it — for the
          // same reason a switch's track is: this is not a sheet lying on the
          // page, it is a tile riding in a groove cut into one.
          'rounded-full',
          transitionClasses,
          iconClasses,
          // The interaction light. It is on the segment and not on the groove,
          // because a groove is not pressed — the tile in it is.
          lit ? 'plass-glow' : '',
          // And its colour follows where the segment is standing rather than
          // what the set is made of. A chosen segment rides the tile, which on
          // `solid` is a coloured fill and takes white light; an unchosen one
          // sits on the trough, which is a sheet, and white light on a
          // near-white sheet is invisible. The set's own slots are inherited,
          // so only the second case has anything to say.
          'not-data-[checked]:[--p-glow:var(--p-soft)]',
          'not-data-[checked]:[--p-flash:var(--p-soft-hover)]',
          // Darkened under the pointer only while the segment can be pressed:
          // Base UI marks a disabled segment, and every segment of a disabled
          // set, with `data-disabled`, and every segment of a read-only set
          // with `data-readonly`, and either still matches `:hover`. The guard
          // makes the rule outrank the chosen label's colour, so it names the
          // unchosen segments as well.
          'text-(--plass-muted-fg) not-data-[checked]:not-data-[disabled]:not-data-[readonly]:hover:text-(--plass-fg)',
          checkedTextClasses[variant],
          forcedCheckedTextClasses,
          // Inset rather than offset — an offset ring on a segment inside a groove
          // is drawn on top of its neighbours.
          focusRingInsetClasses,
          'data-[disabled]:cursor-not-allowed',
          // Faded of its own only in a set that is not disabled: a disabled set
          // is already drawn at half, and a second fade would draw its
          // segments at a quarter.
          setDisabled ? '' : 'data-[disabled]:opacity-50',
          'data-[readonly]:cursor-default',
          // A full-width segment takes an equal part, or more when its label
          // needs it, since its minimum width is its content's. Only when the
          // labels together need more than the row does every segment start
          // from what it needs and shrink in proportion to it, its label cut
          // short with an ellipsis.
          !fullWidth ? 'shrink-0' : overfull ? 'min-w-0 flex-[1_1_auto]' : 'flex-1 shrink-0',
          className ?? ''
        ]
          .filter(Boolean)
          .join(' ')}
        onPointerMove={glowPointerMove(lit, onPointerMove)}
        {...props}
      >
        {hasContent(startIcon) ? (
          <span className="flex h-[1lh] shrink-0 items-center">{startIcon}</span>
        ) : null}
        {fullWidth ? (
          // The label's own box, so it can be cut short, and so the set can
          // read how much of it a cut segment hides.
          <span data-segment-label="" className="min-w-0 truncate">
            {children}
          </span>
        ) : (
          children
        )}
        {hasContent(endIcon) ? (
          <span className="flex h-[1lh] shrink-0 items-center">{endIcon}</span>
        ) : null}
      </BaseUIRadio.Root>
    );
  }
);

/**
 * Two or more choices in one pill, exactly one of them taken.
 *
 * Underneath it is a radio group, and that is the whole accessibility argument:
 * a segmented button *is* "exactly one of these", so it gets
 * `role="radiogroup"`, one tab stop for the set, arrow keys within it, and
 * `aria-checked` on the one that is taken. Building it out of `aria-pressed`
 * toggles — which is what a row of buttons would give — would announce four
 * independent switches, three of which happen to be off.
 *
 * The tile slides because its `left`, `top`, `width` and `height` are measured
 * off the chosen segment and animated. Nothing is transformed: the tile is an
 * empty box, and no label is resampled while it travels. That is what lets the
 * house no-transform rule survive a component whose entire point is that
 * something moves.
 *
 * `left`, not `inset-inline-start`: `offsetLeft` is a distance from the left
 * edge and stays one under RTL, and pairing a physical measurement with a
 * logical property is what would break the direction.
 */
export const PlSegmentedButton = /* @__PURE__ */ React.forwardRef<
  HTMLDivElement,
  PlSegmentedButtonProps
>(function PlSegmentedButton(
  {
    variant = 'glass',
    size: sizeProp,
    color: colorProp,
    density: densityProp,
    elevation = 0,
    value: valueProp,
    defaultValue = null,
    onValueChange,
    disabled: disabledProp = false,
    readOnly = false,
    name,
    fullWidth = false,
    className,
    style,
    children,
    'aria-label': ariaLabel,
    'aria-labelledby': ariaLabelledBy,
    ...props
  },
  ref
) {
  const defaults = useDefaults();
  const disabled = useDisabled(disabledProp);
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';

  const [uncontrolled, setUncontrolled] = React.useState<PlSegmentValue | null>(defaultValue);
  const controlled = valueProp !== undefined;
  const value = controlled ? valueProp : uncontrolled;

  const rootRef = React.useRef<HTMLDivElement>(null);
  const tileRef = React.useRef<HTMLSpanElement>(null);

  const [overfull, setOverfull] = React.useState(false);

  /**
   * Whether the labels of a full-width set together need more than its row.
   *
   * What each segment needs is its width now and what its label hides: the
   * label's `scrollWidth` past its `clientWidth`, which is nothing while it
   * fits. In a row they fit, the segments fill it exactly, and the answer is
   * no; in one they overrun, it is yes whichever way the segments are laid
   * out, so the answer cannot flip the layout it was read from.
   */
  const fit = React.useCallback(() => {
    const root = rootRef.current;

    if (!root || !fullWidth) {
      setOverfull(false);

      return;
    }

    const style = getComputedStyle(root);
    const room = root.clientWidth - parseFloat(style.paddingLeft) - parseFloat(style.paddingRight);
    let need = 0;

    root.querySelectorAll<HTMLElement>('[data-segment]').forEach((segment) => {
      const label = segment.querySelector<HTMLElement>('[data-segment-label]');

      need +=
        segment.getBoundingClientRect().width +
        (label ? Math.max(0, label.scrollWidth - label.clientWidth) : 0);
    });

    // A pixel of slack for the rounding in `clientWidth` and `scrollWidth`.
    setOverfull(need > room + 1);
  }, [fullWidth]);

  /**
   * Whether the set has been committed. A tile drawn with it is lit from its
   * first frame, as a ticked box is, and the attribute goes on as the tile is
   * inserted, before anything can read a style off it. One that a first choice
   * mounts later is lit by `measure`, which fades its fill in.
   */
  const committedRef = React.useRef(false);

  React.useEffect(() => {
    committedRef.current = true;
  }, []);

  /** The frame that turns the tile's transition back on, while one is pending. */
  const readyFrameRef = React.useRef(0);

  const attachTile = React.useCallback((node: HTMLSpanElement | null) => {
    tileRef.current = node;

    if (node && !committedRef.current) {
      node.setAttribute('data-placed', '');
    }
  }, []);

  /**
   * Writes the chosen segment's box onto the tile as four custom properties.
   *
   * Written straight to the element rather than held in state, the way
   * PlButton writes the pointer position: a `setState` here would re-render
   * the whole set on every resize, and nothing in the tree depends on the
   * numbers except four CSS declarations.
   *
   * `animate` is what separates the two callers. A value change is the thing
   * this component exists to animate; a resize is the container moving under a
   * tile that was already in the right place, and animating that is a tile
   * that lags behind the window being dragged.
   */
  const measure = React.useCallback((animate: boolean) => {
    const root = rootRef.current;
    const tile = tileRef.current;

    if (!root || !tile) {
      return;
    }

    const active = root.querySelector<HTMLElement>('[data-segment][data-checked]');

    if (!active) {
      return;
    }

    // Every read before the first write, so the measurement costs the one
    // layout the commit or the resize already owes and not one per number.
    //
    // `offsetLeft`/`offsetTop` are measured from the offsetParent's padding
    // edge, and `left`/`top` on an absolutely positioned child resolve against
    // the same box — so the groove's own padding is already accounted for and
    // must not be subtracted again.
    const x = active.offsetLeft;
    const y = active.offsetTop;
    const width = active.offsetWidth;
    const height = active.offsetHeight;

    // A tile that has only just mounted has nowhere to travel *from*, so its
    // first placement is instant however it was asked for — that is what makes
    // the first choice of an empty set appear under the segment rather than
    // fly in from the left edge.
    const instant = !animate || !tile.hasAttribute('data-ready');

    if (instant) {
      cancelAnimationFrame(readyFrameRef.current);
      tile.removeAttribute('data-ready');
    }

    tile.style.setProperty('--p-seg-x', `${x}px`);
    tile.style.setProperty('--p-seg-y', `${y}px`);
    tile.style.setProperty('--p-seg-w', `${width}px`);
    tile.style.setProperty('--p-seg-h', `${height}px`);

    // Lights the fill of a `solid` tile a first choice mounted. The reads above
    // resolved the tile's style without it, so the fill fades in from there. A
    // tile the set was drawn with, and a later call, find it lit and change
    // nothing.
    tile.setAttribute('data-placed', '');

    if (instant) {
      // The duration goes back on in the next frame rather than now, so the
      // browser draws this move at 0ms first and the transition has nothing
      // left to animate. Reading a layout property here would commit the move
      // at once, at the cost of a second layout in the middle of a commit.
      //
      // One frame is enough from either caller. A resize is reported after
      // this frame's callbacks have run, so the next frame's come after this
      // one is drawn. A commit finds the tile not ready when it has only just
      // been mounted, and no browser eases a box out of the `auto` it was a
      // moment before, or when a resize has just placed it, and then it was
      // drawn in place a frame ago.
      readyFrameRef.current = requestAnimationFrame(() => {
        tile.setAttribute('data-ready', '');
      });
    }
  }, []);

  React.useEffect(() => () => cancelAnimationFrame(readyFrameRef.current), []);

  // Before the browser paints, or the tile is visibly at nothing for a frame.
  // Not on every render a parent does, which hands the set new `children` each
  // time: only on a commit that changed the choice, a prop the segments are
  // sized by, or the segments themselves. See `internal/commit-change.ts`.
  useCommitChange(
    rootRef,
    [value, variant, size, density, fullWidth],
    () => {
      fit();
      measure(true);
    },
    tileRef
  );

  React.useEffect(() => {
    const root = rootRef.current;

    if (!root) {
      return;
    }

    const observer = new ResizeObserver(() => {
      fit();
      measure(false);
    });

    observer.observe(root);

    return () => observer.disconnect();
  }, [fit, measure]);

  const context = React.useMemo(
    () => ({ variant, size, density, fullWidth, overfull, disabled, readOnly }),
    [variant, size, density, fullWidth, overfull, disabled, readOnly]
  );

  return (
    <SegmentedButtonContext.Provider value={context}>
      <BaseUIRadioGroup
        ref={(node: HTMLDivElement | null) => {
          rootRef.current = node;
          if (typeof ref === 'function') {
            ref(node);
          } else if (ref) {
            ref.current = node;
          }
        }}
        value={value}
        onValueChange={(next) => {
          const chosen = (next ?? null) as PlSegmentValue | null;

          if (!controlled) {
            setUncontrolled(chosen);
          }
          onValueChange?.(chosen);
        }}
        disabled={disabled}
        readOnly={readOnly}
        name={name}
        className={[
          // `relative` is load-bearing twice over: it is what makes the groove
          // the segments' offsetParent, and what the tile is positioned in.
          'relative inline-flex items-center rounded-full',
          troughClasses[variant],
          transitionClasses,
          readOnly ? 'saturate-[0.55]' : '',
          disabled ? 'opacity-50 saturate-[0.35]' : '',
          fullWidth ? 'flex w-full' : '',
          className ?? ''
        ]
          .filter(Boolean)
          .join(' ')}
        style={{ ...controlSlots(color, elevation, variant), ...style }}
        // Base UI names the set by the legend of a `PlFieldset` around it. An
        // `aria-label` names it in the legend's place, and a caller's
        // `aria-labelledby` outranks both.
        {...controlNaming(ariaLabel, ariaLabelledBy)}
        {...props}
      >
        {/* Rendered only once something is chosen. An empty set has no tile to
              slide, and mounting it on the first choice is what makes that first
              choice appear in place rather than fly in from the left edge. */}
        {value !== null && value !== undefined ? (
          <span
            ref={attachTile}
            aria-hidden="true"
            className={[
              'pointer-events-none absolute rounded-full',
              'top-(--p-seg-y) left-(--p-seg-x) h-(--p-seg-h) w-(--p-seg-w)',
              tileClasses[variant],
              // The tile is the only thing that says which segment is chosen,
              // and forced-colours mode would otherwise paint it out.
              forcedFillClasses,
              '[transition-property:left,top,width,height]',
              '[transition-timing-function:var(--plass-ease)]',
              // Nothing until the first measurement has landed, and nothing
              // under reduced motion; the house duration from then on.
              '[transition-duration:0ms] motion-safe:data-[ready]:[transition-duration:var(--plass-duration)]'
            ].join(' ')}
          />
        ) : null}

        {children}
      </BaseUIRadioGroup>
    </SegmentedButtonContext.Provider>
  );
});
