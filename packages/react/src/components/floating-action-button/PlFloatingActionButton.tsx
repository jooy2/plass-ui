'use client';

import * as React from 'react';
import { PlButton, type PlButtonProps } from '../button/PlButton.js';
import { PlIconButton } from '../icon-button/PlIconButton.js';
import { useDefaults } from '../../internal/defaults.js';
import { cx, toLength } from '../../internal/styles.js';
import type { PlassCorner, PlassElevation, PlassSize, PlassVariant } from '../../types.js';

export interface PlFloatingActionButtonProps extends Omit<
  PlButtonProps,
  'children' | 'startIcon' | 'endIcon'
> {
  /** The glyph. Sized in `em` against the button, exactly as a `startIcon` is. */
  icon: React.ReactNode;
  /**
   * What the button does, in words.
   *
   * Required, and the one prop here that is. It is the accessible name whether
   * or not the words are drawn — a floating button is a disc with a mark in it
   * nine times out of ten, and an unnamed one is the most common accessibility
   * defect this pattern ships with.
   */
  label: string;
  /**
   * Draws the label beside the glyph.
   *
   * Worth turning on for the action a first-time reader would not guess from a
   * glyph, and worth turning off again once they would.
   * @default false
   */
  extended?: boolean;
  /**
   * Which corner of the window it sits in.
   * @default 'bottom-end'
   */
  corner?: PlassCorner;
  /**
   * How far it stands off the two edges it is against. A number is pixels.
   * @default '1.5rem'
   */
  offset?: number | string;
  /**
   * Whether it pins itself to the window at all.
   *
   * On by default, because that is what this component is. Turn it off to put
   * the same button somewhere of your own — the end of a card, a toolbar — and
   * keep the shape and the shadow.
   * @default true
   */
  floating?: boolean;
  /** @default 'solid' */
  variant?: PlassVariant;
  /**
   * One step up the ladder from a `PlButton`'s default.
   * @default 'lg'
   */
  size?: PlassSize;
  /**
   * How far off the page. `3` — the top of the ladder — and unlike every other
   * default in the library it is not a compromise: this is the one control that
   * genuinely floats over the content rather than resting on it.
   * @default 3
   */
  elevation?: PlassElevation;
}

/** Which two edges the corner is against, as logical insets. */
const insets: Record<PlassCorner, [block: 'Start' | 'End', inline: 'Start' | 'End']> = {
  'top-start': ['Start', 'Start'],
  'top-end': ['Start', 'End'],
  'bottom-start': ['End', 'Start'],
  'bottom-end': ['End', 'End']
};

const DEFAULT_OFFSET = '1.5rem';

/**
 * The one action a screen is about, floating over it.
 *
 * It is a [PlButton](./button) in a corner, and everything that makes it one is
 * the button's: the three materials, the elevation ladder, the pointer light,
 * `loading`, `readOnly` and `disabled`. What this adds is the **pinning**, the
 * shape, and one rule.
 *
 * **`label` is required and is always the accessible name.** A floating button
 * is a disc with a mark in it nine times out of ten, and `extended` decides
 * only whether the words are also drawn — never whether they exist. An icon
 * with no name is the defect this pattern ships with everywhere else.
 *
 * The icon-only form is a **disc**, which is [PlIconButton](./icon-button)'s
 * deliberate exception to the radius rule: the flat run along a control's edge
 * is there for a line of text to sit on, and a glyph has no line of text. The
 * extended form is **not** a pill for exactly that reason — it has words along
 * its edge, so it takes the house fillet like every other labelled control.
 *
 * **One per screen.** Two floating buttons in one corner is two primary
 * actions, which is none; and a screen whose main action is already a button in
 * the content does not want a second copy of it in the corner.
 */
export const PlFloatingActionButton = /* @__PURE__ */ React.forwardRef<
  HTMLButtonElement,
  PlFloatingActionButtonProps
>(function PlFloatingActionButton(
  {
    icon,
    label,
    extended = false,
    corner = 'bottom-end',
    offset,
    floating = true,
    variant = 'solid',
    size: sizeProp,
    elevation = 3,
    className,
    style,
    ...props
  },
  ref
) {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'lg';

  const [block, inline] = insets[corner];
  const distance = toLength(offset) ?? DEFAULT_OFFSET;

  // Inline and logical. Logical because a corner is `start`/`end` here as
  // everywhere, and inline because a caller's `offset` is a value rather than a
  // class — and because an inline declaration is the one form that wins over a
  // utility deterministically.
  const pinned: React.CSSProperties = floating
    ? ({
        position: 'fixed',
        [`insetBlock${block}`]: distance,
        [`insetInline${inline}`]: distance
      } as React.CSSProperties)
    : {};

  const shared = {
    ref,
    variant,
    size,
    elevation,
    className: cx(floating ? 'z-30' : '', className),
    style: { ...pinned, ...style },
    ...props
  };

  return extended ? (
    <PlButton {...shared} startIcon={icon}>
      {label}
    </PlButton>
  ) : (
    <PlIconButton {...shared} icon={icon} label={label} />
  );
});
