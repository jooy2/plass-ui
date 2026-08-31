'use client';

import * as React from 'react';
import { PlSkeleton } from '../skeleton/PlSkeleton.js';
import { useDefaults } from '../../internal/defaults.js';
import {
  controlSlots,
  cx,
  hasContent,
  metaTextClasses,
  stackGapClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassDensity, PlassSize } from '../../types.js';

/** Which way a change has to go to be good news. */
export type PlStatDirection = 'up' | 'down';

export interface PlStatProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /** What the figure is of. The line above it. */
  label?: React.ReactNode;
  /**
   * The figure itself, already formatted.
   *
   * A node rather than a number, and deliberately: how a figure is written —
   * the currency, the grouping, the decimals, the locale — is the page's
   * decision and `Intl.NumberFormat` already makes it. A component that took a
   * number would have to guess at all four.
   */
  value?: React.ReactNode;
  /** A line under the figure. What it is compared with, usually. */
  description?: React.ReactNode;
  /** A glyph beside the label. */
  icon?: React.ReactNode;
  /**
   * How much it moved, as a percentage. Drawn with an arrow, and coloured by
   * whether that is good news rather than by its sign.
   */
  change?: number;
  /**
   * What the change says, instead of the formatted percentage. For a figure
   * that moved by a count rather than by a proportion — "+1,204 this week".
   */
  changeLabel?: React.ReactNode;
  /**
   * Which way is good news.
   *
   * `up` by default and worth setting on about a third of the figures a
   * dashboard has: for churn, for a bounce rate, for a p95 latency, a rise is
   * the bad one, and a component that painted it green would be reading the
   * number and not the meaning.
   * @default 'up'
   */
  improvesWhen?: PlStatDirection;
  /** Draws a skeleton where the figure will be. */
  loading?: boolean;
  /** @default 'md' */
  size?: PlassSize;
  /** The family the icon takes. @default 'primary' */
  color?: PlassColor;
  /** @default 'default' */
  density?: PlassDensity;
}

/** The figure's own ladder. It is the biggest thing in the box and is meant to be. */
const valueClasses: Record<PlassSize, string> = {
  xs: 'text-xl',
  sm: 'text-2xl',
  md: 'text-3xl',
  lg: 'text-4xl',
  xl: 'text-5xl'
};

function Arrow({ up }: { up: boolean }) {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true" className="size-[1em]">
      <path
        d={up ? 'M8 12V4m0 0L4.5 7.5M8 4l3.5 3.5' : 'M8 4v8m0 0 3.5-3.5M8 12l-3.5-3.5'}
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/**
 * One figure, and what has happened to it.
 *
 * A row of these is the top of every dashboard, and the whole of what makes
 * them worth a component rather than three `<div>`s is the **change**: a number
 * on its own says what things are, and a number with a movement beside it says
 * whether that is going anywhere.
 *
 * The colour of that movement is decided by `improvesWhen` and not by the
 * sign, which is the one thing a naive version of this gets wrong. Churn going
 * up is not good news, and a green arrow on it is a dashboard lying to
 * somebody.
 *
 * It draws **no surface**. A figure sits in a `PlCard` or in a row of them, and
 * a sheet inside a sheet is two sheets.
 */
export const PlStat = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlStatProps>(function PlStat(
  {
    label,
    value,
    description,
    icon,
    change,
    changeLabel,
    improvesWhen = 'up',
    loading = false,
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
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';

  const moved = change !== undefined && change !== 0;
  const up = (change ?? 0) > 0;
  // Good news rather than a positive number. The two are the same thing for
  // revenue and the opposite for churn.
  const good = moved && (improvesWhen === 'up' ? up : !up);

  const hasChange = change !== undefined || hasContent(changeLabel);

  return (
    <div
      ref={ref}
      className={cx(
        'flex flex-col',
        density === 'compact' ? 'gap-0.5' : stackGapClasses[size],
        className
      )}
      style={{ ...controlSlots(color, 0, 'ghost'), ...style }}
      {...props}
    >
      {hasContent(label) || hasContent(icon) ? (
        <div
          className={cx('flex items-center gap-1.5 text-(--plass-muted-fg)', metaTextClasses[size])}
        >
          {hasContent(icon) ? (
            <span
              aria-hidden="true"
              className="flex items-center text-(--p-accent) [&_svg]:size-[1.15em]"
            >
              {icon}
            </span>
          ) : null}
          {label}
        </div>
      ) : null}

      <div className="flex items-baseline gap-2">
        {loading ? (
          <PlSkeleton shape="line" size={size} color={color} width="6ch" />
        ) : (
          <span className={cx('font-semibold text-(--plass-fg) tabular-nums', valueClasses[size])}>
            {value}
          </span>
        )}

        {hasChange && !loading ? (
          <span
            className={cx(
              'flex items-center gap-0.5 font-medium tabular-nums',
              metaTextClasses[size],
              !moved
                ? 'text-(--plass-muted-fg)'
                : good
                  ? 'text-(--plass-success-accent)'
                  : 'text-(--plass-danger-accent)'
            )}
          >
            {moved ? <Arrow up={up} /> : null}
            {changeLabel ?? `${up ? '+' : ''}${change}%`}
          </span>
        ) : null}
      </div>

      {hasContent(description) ? (
        <div className={cx('text-(--plass-muted-fg)', metaTextClasses[size])}>{description}</div>
      ) : null}

      {children}
    </div>
  );
});
