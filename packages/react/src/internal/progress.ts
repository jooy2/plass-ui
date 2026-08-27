/**
 * What the progress indicators share.
 *
 * A bar, and — as they arrive — a ring and a row of plates: different shapes
 * answering one question, how far along is this and is it moving at all. So
 * everything that is *not* the shape belongs here: the colour slots, the size
 * ladders, and the arithmetic that turns `value`/`min`/`max` into a fraction.
 *
 * What is left in each component is the shape, which is the point: it is the
 * only thing that genuinely differs.
 */

import type * as React from 'react';
import type { PlassColor, PlassSize } from '../types.js';

/**
 * The props every indicator takes.
 *
 * Declared once and extended rather than written out per shape, because the
 * whole claim being made is that these are one component in several shapes: a
 * `value` of `null` has to mean the same thing on a bar as on anything that
 * follows it, or they are separate components that happen to share a prefix.
 */
export interface PlassProgressProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'children'
> {
  /**
   * How far along, between `min` and `max`.
   *
   * `null` — the default — is the indeterminate case: something is happening
   * and nobody knows how much of it is left. That is the default on purpose. An
   * indicator that has not been told a value should say so rather than draw an
   * empty bar, which is a claim that no progress has been made.
   * @default null
   */
  value?: number | null;
  /** @default 0 */
  min?: number;
  /** @default 100 */
  max?: number;
  /** A name for what is loading. Read out with the value by a screen reader. */
  label?: React.ReactNode;
  /**
   * Shows the value as text beside the shape. A percentage of the range unless
   * `format` says otherwise.
   * @default false
   */
  showValue?: boolean;
  /**
   * How to format the value when it is shown — `Intl.NumberFormat` options, so
   * bytes and currencies work as well as plain numbers. Without it the value is
   * a percentage of `min`…`max`, which is the only formatting that holds for a
   * range nobody described.
   */
  format?: Intl.NumberFormatOptions;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
}

/**
 * The slots an indicator reads.
 *
 * An indicator **is** the coloured thing — unlike a PlBox, which holds other
 * people's content — so it gets `--p-fill`, the family's own gradient, and the
 * filled part of a bar is made of exactly the same material as the button that
 * submits the form it is in.
 *
 * There is no elevation ladder and no `--p-lift` here, on purpose. An indicator
 * is cut *into* the surface it sits on, the way a groove is, and a groove does
 * not float.
 */
export function progressSlots(color: PlassColor): React.CSSProperties {
  return {
    '--p-fill': `var(--plass-${color}-fill)`,
    '--p-accent': `var(--plass-${color}-accent)`,
    '--p-soft': `var(--plass-${color}-soft)`,
    '--p-soft-press': `var(--plass-${color}-soft-press)`
  } as React.CSSProperties;
}

/**
 * How thick the linear groove is.
 *
 * Its own ladder rather than a fraction of `controlHeightClasses`: a bar is not
 * a control you can put a label inside, and at `md` it wants to be the weight
 * of a rule between two paragraphs rather than a quarter of a button.
 *
 * They are `PlSlider`'s rail thicknesses, and deliberately: a rail and a bar are
 * the same channel, one of which you drag and one of which you watch.
 */
export const barThicknessClasses: Record<PlassSize, string> = {
  xs: 'h-1',
  sm: 'h-1.5',
  md: 'h-1.5',
  lg: 'h-2',
  xl: 'h-2.5'
};

/**
 * The groove an indicator is cut into, and the transition that fills it.
 *
 * `--plass-track` is the one neutral ink the library grooves with — a
 * PlSlider's rail and a PlSwitch's off track are the same colour — so a form
 * with a slider, a switch and a progress bar in it is made of one material
 * rather than three.
 *
 * The fill is `--p-fill`, and it is a `background-image` rather than a colour
 * because that is what a Plass fill *is*: a gradient that turns in hue. Which is
 * also why the movement is on `width` and never on the paint: a gradient cannot
 * be transitioned, and a length can.
 */
export const trackClasses = 'bg-(--plass-track)';

/** The bar's own duration, one step slower than a control's, so a fill reads as travel. */
export const fillTransitionClasses =
  '[transition:width_var(--plass-duration-slow)_var(--plass-ease)]';

/**
 * `value` as a fraction of the range, or `null` when there is nothing to say.
 *
 * The clamp is not defensive programming for its own sake — `value` usually
 * arrives from a division somewhere, and a bar that renders 140% wide because
 * one request finished twice is a worse bug than a bar that sits full.
 */
export function progressFraction(
  value: number | null | undefined,
  min: number,
  max: number
): number | null {
  if (value === null || value === undefined || Number.isNaN(value)) {
    return null;
  }

  if (max <= min) {
    return null;
  }

  return Math.min(1, Math.max(0, (value - min) / (max - min)));
}

/**
 * What the value reads as, both on screen and to a screen reader.
 *
 * Base UI's own default is `${value}%`, which is right only when the range
 * happens to be 0–100 — "3%" for step 3 of 4 is worse than saying nothing. So
 * the percentage is computed from the fraction, and a caller who passed
 * `format` gets Base UI's formatted string instead, because at that point they
 * have said what the number means.
 */
export function progressText(
  fraction: number | null,
  formatted: string | null,
  hasFormat: boolean
): string | null {
  if (fraction === null) {
    return null;
  }

  return hasFormat ? formatted : `${Math.round(fraction * 100)}%`;
}

/**
 * The same string, shaped for Base UI's `getAriaValueText`.
 *
 * `undefined` when there is no value, which hands the indeterminate case back
 * to Base UI — it already announces indeterminate progress, and re-inventing
 * that here would be one more English string the library has to own.
 */
export function progressAriaText(
  fraction: number | null,
  hasFormat: boolean
): ((formatted: string | null) => string) | undefined {
  if (fraction === null) {
    return undefined;
  }

  return (formatted) => progressText(fraction, formatted, hasFormat) ?? '';
}
