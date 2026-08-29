'use client';

import * as React from 'react';
import { Radio as BaseUIRadio } from '@base-ui/react/radio';
import { RadioGroup as BaseUIRadioGroup } from '@base-ui/react/radio-group';
import {
  controlHeightClasses,
  controlSlots,
  controlTextClasses,
  focusRingInsetClasses,
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
}

const SegmentedButtonContext = /* @__PURE__ */ React.createContext<SegmentedButtonContextValue>({
  variant: 'glass',
  size: 'md',
  density: 'default',
  fullWidth: false
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
  /** The segments share the full width, each taking an equal part of it. */
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
  solid: `${glassClasses} bg-(--plass-glass-press) p-1 [box-shadow:var(--p-elev),var(--plass-well)]`,
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
 */
const tileClasses: Record<PlassVariant, string> = {
  solid: '[background-image:var(--p-fill)] [box-shadow:var(--plass-shadow-1),var(--p-lift)]',
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
    { value, startIcon, endIcon, disabled = false, className, children, ...props },
    ref
  ) {
    const { variant, size, density, fullWidth } = React.useContext(SegmentedButtonContext);

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
          'relative z-10 inline-flex shrink-0 cursor-pointer items-center justify-center select-none',
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
          'text-(--plass-muted-fg) hover:text-(--plass-fg)',
          checkedTextClasses[variant],
          // Inset rather than offset — an offset ring on a segment inside a groove
          // is drawn on top of its neighbours.
          focusRingInsetClasses,
          'data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50',
          'data-[readonly]:cursor-default',
          fullWidth ? 'flex-1' : '',
          className ?? ''
        ]
          .filter(Boolean)
          .join(' ')}
        {...props}
      >
        {hasContent(startIcon) ? (
          <span className="flex h-[1lh] shrink-0 items-center">{startIcon}</span>
        ) : null}
        {children}
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
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    value: valueProp,
    defaultValue = null,
    onValueChange,
    disabled = false,
    readOnly = false,
    name,
    fullWidth = false,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const [uncontrolled, setUncontrolled] = React.useState<PlSegmentValue | null>(defaultValue);
  const controlled = valueProp !== undefined;
  const value = controlled ? valueProp : uncontrolled;

  const rootRef = React.useRef<HTMLDivElement>(null);
  const tileRef = React.useRef<HTMLSpanElement>(null);

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

    // A tile that has only just mounted has nowhere to travel *from*, so its
    // first placement is instant however it was asked for — that is what makes
    // the first choice of an empty set appear under the segment rather than
    // fly in from the left edge.
    const instant = !animate || !tile.hasAttribute('data-ready');

    if (instant) {
      tile.removeAttribute('data-ready');
    }

    // `offsetLeft`/`offsetTop` are measured from the offsetParent's padding
    // edge, and `left`/`top` on an absolutely positioned child resolve against
    // the same box — so the groove's own padding is already accounted for and
    // must not be subtracted again.
    tile.style.setProperty('--p-seg-x', `${active.offsetLeft}px`);
    tile.style.setProperty('--p-seg-y', `${active.offsetTop}px`);
    tile.style.setProperty('--p-seg-w', `${active.offsetWidth}px`);
    tile.style.setProperty('--p-seg-h', `${active.offsetHeight}px`);

    if (instant) {
      // Reading a layout property commits the four writes above while the
      // duration is still 0ms, so turning the transition back on cannot
      // animate a move that has already happened.
      void tile.offsetWidth;
    }

    tile.setAttribute('data-ready', '');
  }, []);

  // Before the browser paints, or the tile is visibly at nothing for a frame.
  React.useLayoutEffect(() => {
    measure(true);
  }, [measure, value, variant, size, density, fullWidth, children]);

  React.useEffect(() => {
    const root = rootRef.current;

    if (!root) {
      return;
    }

    const observer = new ResizeObserver(() => measure(false));

    observer.observe(root);

    return () => observer.disconnect();
  }, [measure]);

  const context = React.useMemo(
    () => ({ variant, size, density, fullWidth }),
    [variant, size, density, fullWidth]
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
        {...props}
      >
        {/* Rendered only once something is chosen. An empty set has no tile to
              slide, and mounting it on the first choice is what makes that first
              choice appear in place rather than fly in from the left edge. */}
        {value !== null && value !== undefined ? (
          <span
            ref={tileRef}
            aria-hidden="true"
            className={[
              'pointer-events-none absolute rounded-full',
              'top-(--p-seg-y) left-(--p-seg-x) h-(--p-seg-h) w-(--p-seg-w)',
              tileClasses[variant],
              '[transition-property:left,top,width,height]',
              '[transition-timing-function:var(--plass-ease)]',
              // Nothing until the first measurement has landed; the house
              // duration from then on.
              '[transition-duration:0ms] data-[ready]:[transition-duration:var(--plass-duration)]'
            ].join(' ')}
          />
        ) : null}

        {children}
      </BaseUIRadioGroup>
    </SegmentedButtonContext.Provider>
  );
});
