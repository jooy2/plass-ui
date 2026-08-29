'use client';

import * as React from 'react';
import { Button as BaseUIButton } from '@base-ui/react/button';
import { useRender } from '@base-ui/react/use-render';
import { ButtonGroupContext } from '../../internal/button-group.js';
import { Spinner } from '../../internal/icons.js';
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
  readOnlyFilterClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassElevation, PlassSize, PlassStyleProps, PlassVariant } from '../../types.js';

export interface PlButtonProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'button'>, 'color'> {
  /**
   * Drop shadow depth. `1` is the default, because a moulded key **rests on**
   * the sheet rather than lying flush with it. Hover adds a level and pressing
   * removes one, which is what puts the key down against the glass under the
   * finger.
   * @default 1
   */
  elevation?: PlassElevation;
  /** Content placed before the label. Sized in `em`, so it tracks the label. */
  startIcon?: React.ReactNode;
  /** Content placed after the label. */
  endIcon?: React.ReactNode;
  /**
   * Shows a spinner in place of `startIcon` and stops the button from
   * activating, while keeping it focusable and visually unchanged otherwise.
   */
  loading?: boolean;
  /** Inert but not dimmed — the action exists, it just is not available here. */
  readOnly?: boolean;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  /**
   * Renders something other than a `<button>` — an `<a href>` for an action that
   * is really a navigation, or the `Link` a router brings. Base UI's own escape
   * hatch.
   *
   * The surface, the sizes and the press signature are unchanged; what changes
   * is the element they are drawn on, and what it *is* to everything reading the
   * page. A link stays a link: it is announced as one, it is in the list a
   * screen reader can pull up, and a crawler follows it.
   *
   * An `<a>` has no `disabled`, so a button that has to be unavailable stays a
   * `<button>`.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * The scales all come from `internal/styles` — a button's height *is* the
 * library's control height, and the same numbers have to hold on a PlTextField,
 * a Select and a Chip for a mixed row to keep its baseline.
 */
const sizeClasses: Record<PlassSize, string> = {
  xs: `${controlHeightClasses.xs} ${gapClasses.xs} ${radiusClasses.xs} ${controlTextClasses.xs}`,
  sm: `${controlHeightClasses.sm} ${gapClasses.sm} ${radiusClasses.sm} ${controlTextClasses.sm}`,
  md: `${controlHeightClasses.md} ${gapClasses.md} ${radiusClasses.md} ${controlTextClasses.md}`,
  lg: `${controlHeightClasses.lg} ${gapClasses.lg} ${radiusClasses.lg} ${controlTextClasses.lg}`,
  xl: `${controlHeightClasses.xl} ${gapClasses.xl} ${radiusClasses.xl} ${controlTextClasses.xl}`
};

/** With no label there is nothing to pad against, so the button goes square. */
const iconOnlyClasses: Record<PlassSize, string> = {
  xs: `${controlSquareClasses.xs} px-0`,
  sm: `${controlSquareClasses.sm} px-0`,
  md: `${controlSquareClasses.md} px-0`,
  lg: `${controlSquareClasses.lg} px-0`,
  xl: `${controlSquareClasses.xl} px-0`
};

const baseClasses = /* @__PURE__ */ [
  // `relative` because `.plass-glow` hangs its two light layers off `::before`/`::after`.
  'relative inline-flex shrink-0 select-none items-center justify-center',
  'whitespace-nowrap align-middle font-semibold leading-none',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  focusRingClasses,
  iconClasses
].join(' ');

/**
 * The three materials.
 *
 * `solid` is the only one with a `background-image`, and that gradient is the
 * whole of the form: two ends of the family swept across the control, with no
 * highlight over the top of it. A filled control deliberately carries **no**
 * gloss line — an inset white edge on a coloured surface is what reads as
 * lacquer, and the sweep is already saying everything about the shape that
 * needs saying. The hairline belongs to `glass`, which has a real cut edge.
 *
 * `glass` wears the family in its **text** rather than in its sheet, which is
 * why `color="secondary"` is the neutral, quiet button and not a second grey
 * variant nobody would remember the name of.
 */
const restClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'text-(--p-on-solid) [background-image:var(--p-fill)]',
    '[box-shadow:var(--p-elev),var(--p-lift)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    glassClasses,
    'border text-(--p-accent) bg-(--plass-glass)',
    '[border-color:var(--plass-glass-line)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  // Nothing to catch the light on, and nothing to cast a shadow.
  ghost: 'text-(--p-accent) bg-transparent'
};

/**
 * Hover lifts the control and turns the light up; press puts it down and turns
 * the light down. Both are `filter: brightness()` rather than a second set of
 * colours, because the fill is a gradient and a gradient cannot be transitioned
 * — but light falling on one can. The pointer bloom `.plass-glow` draws rides
 * on top of this; the brightness is the state, the bloom is where the pointer
 * is.
 */
const hoverClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'hover:brightness-105',
    'hover:[box-shadow:var(--p-elev-hover),var(--p-lift-hover)]',
    'active:brightness-95',
    'active:[box-shadow:var(--p-elev-press),var(--p-lift-press)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    'hover:bg-(--plass-glass-hover) hover:[border-color:var(--p-line)]',
    'hover:[box-shadow:var(--p-elev-hover),var(--plass-gloss-glass)]',
    'active:bg-(--plass-glass-press)',
    'active:[box-shadow:var(--p-elev-press),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: 'hover:bg-(--p-soft) active:bg-(--p-soft-hover)'
};

/**
 * Read-only keeps the shape, the colour and the edge but goes flat, loses its
 * lift and drains most of the saturation.
 */
const readOnlyClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'cursor-default text-(--p-on-solid) [background-image:var(--p-fill)]',
    `shadow-none ${readOnlyFilterClasses}`
  ].join(' '),
  glass: /* @__PURE__ */ [
    glassClasses,
    'cursor-default border text-(--p-accent) bg-(--plass-glass)',
    '[border-color:var(--plass-glass-line)]',
    `[box-shadow:var(--plass-gloss-glass)] ${readOnlyFilterClasses}`
  ].join(' '),
  ghost: `cursor-default text-(--p-accent) bg-transparent ${readOnlyFilterClasses}`
};

export const PlButton = /* @__PURE__ */ React.forwardRef<HTMLButtonElement, PlButtonProps>(
  function PlButton(
    {
      variant: variantProp,
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      elevation: elevationProp,
      startIcon,
      endIcon,
      loading = false,
      readOnly = false,
      fullWidth = false,
      disabled: disabledProp,
      render,
      className,
      style,
      children,
      onClick,
      onPointerMove,
      ...props
    },
    ref
  ) {
    /*
     * A `PlButtonGroup` around this button sets the axes once for the set. The
     * button's own prop still wins — a row of secondary actions with one danger
     * button in it is a real thing — and with no group around it the fallbacks
     * are the defaults they always were.
     */
    const group = React.useContext(ButtonGroupContext);
    const variant = variantProp ?? group?.variant ?? 'solid';
    const size = sizeProp ?? group?.size ?? 'md';
    const color = colorProp ?? group?.color ?? 'primary';
    const density = densityProp ?? group?.density ?? 'default';
    const elevation = elevationProp ?? group?.elevation ?? 1;
    const disabled = disabledProp ?? group?.disabled ?? false;

    const iconOnly = !hasContent(children);
    // `disabled` and `readOnly` change how the button looks; `loading` only stops
    // it from firing.
    const inert = loading || readOnly;
    const interactive = !disabled && !inert;

    const classNames = [
      baseClasses,
      sizeClasses[size],
      iconOnly ? iconOnlyClasses[size] : paddingXClasses[density][size],
      // Deliberately an if/else rather than stacked `data-*` variants: two
      // Tailwind variants of equal specificity resolve by their order in the
      // generated stylesheet, which is not something a component should depend on.
      disabled
        ? disabledClasses[variant]
        : readOnly
          ? readOnlyClasses[variant]
          : restClasses[variant],
      interactive ? `${hoverClasses[variant]} cursor-pointer` : '',
      // The interaction light. Every variant takes it, because it is about where
      // the pointer is rather than about what the surface is made of — the two
      // colour slots behind it are what switch with the variant.
      interactive ? 'plass-glow' : '',
      loading ? 'cursor-progress' : '',
      fullWidth ? 'w-full' : '',
      className ?? ''
    ]
      .filter(Boolean)
      .join(' ');

    /*
     * `render` deliberately steps around Base UI's PlButton rather than being handed
     * to it. Told to render a non-`<button>`, that component puts `role="button"`
     * on whatever it was given — which is right for a `<div>` and wrong for the
     * case this prop exists for: an `<a href>` under a `role="button"` stops being
     * a link to everything that reads the page, and the link list, the status bar
     * and the crawler all lose it.
     *
     * What Base UI's PlButton adds over a bare `<button>` is its disabled handling,
     * and `disabled` is the one thing that cannot travel to an `<a>` anyway.
     */
    return useRender({
      render: render ?? <BaseUIButton disabled={disabled} />,
      ref,
      props: {
        className: classNames,
        style: { ...controlSlots(color, elevation, variant), ...style },
        'aria-disabled': inert || undefined,
        'aria-busy': loading || undefined,
        'data-loading': loading || undefined,
        'data-readonly': readOnly || undefined,
        onClick: (event: React.MouseEvent<HTMLElement>) => {
          if (inert) {
            event.preventDefault();
            event.stopPropagation();
            return;
          }
          onClick?.(event as React.MouseEvent<HTMLButtonElement>);
        },
        onPointerMove: (event: React.PointerEvent<HTMLElement>) => {
          // Feeds the two light layers in `styles.css`. Written straight to the
          // element rather than held in state: this fires at pointer rate, and a
          // `setState` here would re-render the tree on every mouse move. Reading
          // `offsetX/offsetY` costs nothing — no `getBoundingClientRect`, so no
          // forced layout. Icons carry `pointer-events: none`, so the offsets are
          // always relative to the button itself.
          //
          // It runs while a finger is down too, which is what makes the light
          // follow a drag on a touch screen — there is no hover there, and the
          // `:active` layer is the one doing the work.
          const element = event.currentTarget;
          element.style.setProperty('--p-mx', `${event.nativeEvent.offsetX}px`);
          element.style.setProperty('--p-my', `${event.nativeEvent.offsetY}px`);
          onPointerMove?.(event as React.PointerEvent<HTMLButtonElement>);
        },
        ...props,
        children: (
          <>
            {loading ? <Spinner /> : startIcon}
            {children}
            {endIcon}
          </>
        )
      }
    });
  }
);
