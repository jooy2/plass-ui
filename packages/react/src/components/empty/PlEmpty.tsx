'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import {
  controlSlots,
  cx,
  hasContent,
  metaTextClasses,
  sheetPaddingYClasses,
  sheetTitleClasses,
  stackGapClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassDensity, PlassSize } from '../../types.js';

export interface PlEmptyProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'title'
> {
  /**
   * The glyph or drawing above the words. Sized off `size`, so an icon set at
   * `1em` fills it without being told a number.
   */
  icon?: React.ReactNode;
  /** The one line that says what is not here. */
  title?: React.ReactNode;
  /** What to do about it. One or two sentences, never a paragraph. */
  description?: React.ReactNode;
  /** The way out — usually one `PlButton`. */
  actions?: React.ReactNode;
  /** @default 'md' */
  size?: PlassSize;
  /**
   * The family the glyph takes.
   *
   * `secondary` by default, which is the whole difference between an empty
   * state and an alert: nothing has gone wrong. Reach for `danger` when
   * something has, and `success` for the end of a flow — which is what turns
   * this into the "your order is confirmed" screen without a second component.
   * @default 'secondary'
   */
  color?: PlassColor;
  /** @default 'default' */
  density?: PlassDensity;
}

/** How big the glyph is. Its own ladder — it is a picture, not a control. */
const iconSizeClasses: Record<PlassSize, string> = {
  xs: 'text-2xl',
  sm: 'text-3xl',
  md: 'text-4xl',
  lg: 'text-5xl',
  xl: 'text-6xl'
};

/**
 * The place where there is nothing.
 *
 * An empty list, a search that found nothing, a filter that excluded
 * everything, a flow that has finished. All four are the same arrangement — a
 * mark, a line, a sentence, a way out — which is why they are one component and
 * not four, and why `color` is what tells them apart: `secondary` is "nothing
 * here yet", `danger` is "something went wrong", `success` is "you are done".
 *
 * It **draws no surface**. An empty state is always inside something — a card,
 * a table, a panel — and a sheet inside a sheet is two sheets. What it decides
 * is the arrangement and the space around it.
 *
 * The one thing worth getting right is the **way out**. A screen that says
 * "No projects" and stops is a dead end; the same screen with a "New project"
 * button is the best moment in the whole flow to offer one.
 */
export const PlEmpty = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlEmptyProps>(
  function PlEmpty(
    {
      icon,
      title,
      description,
      actions,
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'secondary';
    const density = densityProp ?? defaults.density ?? 'default';

    return (
      <div
        ref={ref}
        className={cx(
          'flex flex-col items-center justify-center text-center',
          stackGapClasses[size],
          sheetPaddingYClasses[density][size],
          className
        )}
        style={{ ...controlSlots(color, 0, 'ghost'), ...style }}
        {...props}
      >
        {hasContent(icon) ? (
          <span
            aria-hidden="true"
            className={cx(
              'flex items-center justify-center text-(--p-accent) [&_svg]:size-[1em]',
              iconSizeClasses[size]
            )}
          >
            {icon}
          </span>
        ) : null}

        {hasContent(title) ? (
          <p className={cx('font-semibold text-(--plass-fg)', sheetTitleClasses[size])}>{title}</p>
        ) : null}

        {hasContent(description) ? (
          <p className={cx('max-w-prose text-(--plass-muted-fg)', metaTextClasses[size])}>
            {description}
          </p>
        ) : null}

        {children}

        {hasContent(actions) ? (
          <div className={cx('flex flex-wrap items-center justify-center gap-2')}>{actions}</div>
        ) : null}
      </div>
    );
  }
);
