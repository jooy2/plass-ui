'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { Toggle as BaseUIToggle } from '@base-ui/react/toggle';
import { ButtonGroupContext } from '../../internal/button-group.js';
import {
  controlHeightClasses,
  controlSlots,
  controlSquareClasses,
  controlTextClasses,
  disabledClasses,
  focusRingClasses,
  gapClasses,
  glassClasses,
  hasContent,
  iconClasses,
  paddingXClasses,
  radiusClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassElevation, PlassSize, PlassStyleProps, PlassVariant } from '../../types.js';

export interface PlToggleProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'button'>, 'color' | 'value'> {
  /**
   * What the key is made of while it is **off**. On is always the colour family
   * asserting itself, whichever material was asked for.
   *
   * - `solid` — the densest clear glass, which fills with the family's gradient
   *   when it goes on. The loudest, for a toggle a screen is steered by.
   * - `glass` — the canonical sheet with a hairline round it. The default.
   * - `ghost` — nothing at all until the pointer arrives or it goes on. What a
   *   toolbar wants.
   * @default 'glass'
   */
  variant?: PlassVariant;
  /** Whether it is on. Use with `onPressedChange` for a controlled toggle. */
  pressed?: boolean;
  /** Whether it starts on, for an uncontrolled one. @default false */
  defaultPressed?: boolean;
  onPressedChange?: (pressed: boolean) => void;
  /** Identifies the toggle inside a `PlToggleGroup`. */
  value?: string;
  /**
   * Drop shadow depth. `0` — the default, and one below a `PlButton`'s — is
   * flat: a toggle is a state rather than an action, and a state does not float
   * off the page waiting to be taken.
   * @default 0
   */
  elevation?: PlassElevation;
  /** Content placed before the label. Sized in `em`, so it tracks the label. */
  startIcon?: React.ReactNode;
  /** Content placed after the label. */
  endIcon?: React.ReactNode;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  /**
   * The label. Left out, the toggle goes square around whatever icon it was
   * given — which is what a toolbar toggle is. An icon-only toggle still needs
   * an `aria-label`.
   */
  children?: React.ReactNode;
}

const sizeClasses: Record<PlassSize, string> = {
  xs: `${controlHeightClasses.xs} ${gapClasses.xs} ${radiusClasses.xs} ${controlTextClasses.xs}`,
  sm: `${controlHeightClasses.sm} ${gapClasses.sm} ${radiusClasses.sm} ${controlTextClasses.sm}`,
  md: `${controlHeightClasses.md} ${gapClasses.md} ${radiusClasses.md} ${controlTextClasses.md}`,
  lg: `${controlHeightClasses.lg} ${gapClasses.lg} ${radiusClasses.lg} ${controlTextClasses.lg}`,
  xl: `${controlHeightClasses.xl} ${gapClasses.xl} ${radiusClasses.xl} ${controlTextClasses.xl}`
};

/** With no label there is nothing to pad against, so the toggle goes square. */
const iconOnlyClasses: Record<PlassSize, string> = {
  xs: `${controlSquareClasses.xs} px-0`,
  sm: `${controlSquareClasses.sm} px-0`,
  md: `${controlSquareClasses.md} px-0`,
  lg: `${controlSquareClasses.lg} px-0`,
  xl: `${controlSquareClasses.xl} px-0`
};

const baseClasses = /* @__PURE__ */ [
  // `relative` because `.plass-glow` hangs its two light layers off
  // `::before`/`::after`.
  'relative inline-flex shrink-0 select-none items-center justify-center',
  'whitespace-nowrap align-middle font-semibold leading-none',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  focusRingClasses,
  iconClasses
].join(' ');

/**
 * Off.
 *
 * The ink is `--plass-muted-fg` in all three, and that is the whole difference
 * from a `PlButton`: a button at rest is an action waiting to be taken, a
 * toggle at rest is a *state that is currently false*. Accent ink on an
 * unpressed toggle would say it was on.
 *
 * None of the three is dyed either. An off toggle is a piece of clear glass —
 * the family arrives with the press and not before it.
 */
const offClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    glassClasses,
    'text-(--plass-muted-fg) bg-(--plass-glass-hover)',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    glassClasses,
    'border text-(--plass-muted-fg) bg-(--plass-glass)',
    '[border-color:var(--plass-glass-line)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: 'text-(--plass-muted-fg) bg-transparent'
};

const offHoverClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'hover:bg-(--plass-glass-press) hover:text-(--plass-fg)',
    'hover:[box-shadow:var(--p-elev-hover),var(--plass-gloss-glass)]',
    'active:[box-shadow:var(--p-elev-press),var(--plass-gloss-glass)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    'hover:bg-(--plass-glass-hover) hover:text-(--plass-fg) hover:[border-color:var(--p-line)]',
    'hover:[box-shadow:var(--p-elev-hover),var(--plass-gloss-glass)]',
    'active:bg-(--plass-glass-press)',
    'active:[box-shadow:var(--p-elev-press),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: 'hover:bg-(--p-soft) hover:text-(--plass-fg) active:bg-(--p-soft-hover)'
};

/**
 * On.
 *
 * The same two answers the chosen segment of a `PlSegmentedButton` gives,
 * because they are the same claim: `solid` takes the family's gradient and the
 * on-fill ink, the other two light the sheet and leave the label in the accent.
 *
 * A toggle that is on is **not** a toggle that is elevated. The elevation is the
 * same in both states and only the colour moves, because "on" is a fact about
 * the thing beside the toggle rather than about how far the key is off the page.
 */
const onClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'text-(--p-on-solid) [background-image:var(--p-fill)]',
    '[box-shadow:var(--p-elev),var(--p-lift)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    glassClasses,
    'border text-(--p-accent) bg-(--p-soft)',
    '[border-color:var(--p-line-hover)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: 'text-(--p-accent) bg-(--p-soft)'
};

const onHoverClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'hover:brightness-105 hover:[box-shadow:var(--p-elev-hover),var(--p-lift-hover)]',
    'active:brightness-95 active:[box-shadow:var(--p-elev-press),var(--p-lift-press)]'
  ].join(' '),
  glass: 'hover:bg-(--p-soft-hover) active:bg-(--p-soft-press)',
  ghost: 'hover:bg-(--p-soft-hover) active:bg-(--p-soft-press)'
};

/**
 * A button that stays down.
 *
 * The difference from a `PlSwitch` is what the press *is*: a switch changes a
 * setting and the change is the point; a toggle changes the state of the thing
 * beside it — bold on the selected words, the grid on the canvas, the filter on
 * the list. The difference from a `PlCheckbox` is that this one is a control
 * rather than an answer, so it never goes in a form.
 *
 * Base UI's Toggle owns `aria-pressed` and the controlled/uncontrolled pair.
 * What is left here is the surface, and the rule that off is neutral.
 */
export const PlToggle = /* @__PURE__ */ React.forwardRef<HTMLButtonElement, PlToggleProps>(
  function PlToggle(
    {
      variant: variantProp,
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      elevation: elevationProp,
      pressed,
      defaultPressed,
      onPressedChange,
      value,
      startIcon,
      endIcon,
      fullWidth = false,
      disabled: disabledProp,
      className,
      style,
      children,
      onPointerMove,
      ...props
    },
    ref
  ) {
    // A `PlToggleGroup` and a `PlButtonGroup` publish the same context, so a
    // toggle picks up the set it is in either way. Its own prop still wins.
    const defaults = useDefaults();
    const group = React.useContext(ButtonGroupContext);
    const variant = variantProp ?? group?.variant ?? 'glass';
    const size = sizeProp ?? group?.size ?? defaults.size ?? 'md';
    const color = colorProp ?? group?.color ?? defaults.color ?? 'primary';
    const density = densityProp ?? group?.density ?? defaults.density ?? 'default';
    const elevation = elevationProp ?? group?.elevation ?? 0;
    const disabled = disabledProp ?? group?.disabled ?? false;

    const iconOnly = !hasContent(children);

    return (
      <BaseUIToggle
        ref={ref}
        value={value}
        pressed={pressed}
        defaultPressed={defaultPressed}
        onPressedChange={(next) => onPressedChange?.(next)}
        disabled={disabled}
        className={(state) =>
          [
            baseClasses,
            sizeClasses[size],
            iconOnly ? iconOnlyClasses[size] : paddingXClasses[density][size],
            // Deliberately an if/else rather than stacked `data-*` variants: two
            // Tailwind variants of equal specificity resolve by their order in
            // the generated stylesheet, and `pressed` and `disabled` would
            // collide.
            disabled
              ? disabledClasses[variant]
              : state.pressed
                ? `${onClasses[variant]} ${onHoverClasses[variant]}`
                : `${offClasses[variant]} ${offHoverClasses[variant]}`,
            disabled ? '' : 'plass-glow cursor-pointer',
            fullWidth ? 'w-full' : '',
            className ?? ''
          ]
            .filter(Boolean)
            .join(' ')
        }
        style={{ ...controlSlots(color, elevation, variant), ...style }}
        onPointerMove={(event) => {
          // Feeds the two light layers in `styles.css`, exactly as `PlButton`
          // does — written straight to the element because this fires at
          // pointer rate.
          const element = event.currentTarget;
          element.style.setProperty('--p-mx', `${event.nativeEvent.offsetX}px`);
          element.style.setProperty('--p-my', `${event.nativeEvent.offsetY}px`);
          onPointerMove?.(event);
        }}
        {...props}
      >
        {startIcon}
        {children}
        {endIcon}
      </BaseUIToggle>
    );
  }
);
