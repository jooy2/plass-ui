'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useRender } from '@base-ui/react/use-render';
import { cx, radiusClasses } from '../../internal/styles.js';
import type { PlassSize } from '../../types.js';

/**
 * How the media inside is fitted to the box, spelled the way CSS spells it.
 *
 * These are `object-fit`'s own values rather than a nicer set of words, for the
 * reason the library keeps `aspect-ratio`'s own syntax below: inventing
 * `fill-the-box` would only make a reader look up which CSS it maps to.
 */
export type PlAspectFit = 'cover' | 'contain' | 'fill' | 'none';

export interface PlAspectRatioProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * The proportion the box holds, written the way CSS writes it — a number
   * (`1.5`) or a ratio (`'16 / 9'`). Both reach `aspect-ratio` untouched.
   * @default 1
   */
  ratio?: number | string;
  /**
   * How a single piece of media inside is fitted. Applies to an `img`, a
   * `video`, a `canvas`, an `svg` or an `iframe` that is a direct child; those
   * are stretched to the full box and then fitted. Anything else is laid out
   * normally and this prop does not reach it.
   * @default 'cover'
   */
  fit?: PlAspectFit;
  /**
   * Rounds the corners to the `size` step of the house radius ladder.
   *
   * Off by default. A layout component draws nothing, and a photograph with its
   * corners cut is a decision about the photograph — but it is such a common one
   * that making the caller reach for a `className` would be perverse.
   * @default false
   */
  rounded?: boolean;
  /**
   * Which step of the radius ladder `rounded` uses.
   *
   * `size` here is the size of the *sheet* — there is no height and no type
   * scale on a box whose whole job is a proportion.
   * @default 'md'
   */
  size?: PlassSize;
  /**
   * Renders something other than a `<div>`: `render={<figure />}`,
   * `render={<a href="…" />}`. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * The media a `fit` reaches, stretched to the box first.
 *
 * Written out one selector at a time rather than as a comma list, because
 * Tailwind only ever sees class names that appear literally in the source and a
 * grouped arbitrary variant is one string it has to parse rather than match.
 *
 * `iframe` takes the sizing and not the fit: an embed lays its own content out
 * and `object-fit` has nothing to act on.
 */
const stretchClasses = /* @__PURE__ */ [
  '[&>img]:size-full',
  '[&>video]:size-full',
  '[&>canvas]:size-full',
  '[&>svg]:size-full',
  '[&>iframe]:size-full',
  '[&>picture]:size-full',
  '[&>picture>img]:size-full'
].join(' ');

const fitClasses: Record<PlAspectFit, string> = {
  cover: '[&>img]:object-cover [&>video]:object-cover [&>picture>img]:object-cover',
  contain: '[&>img]:object-contain [&>video]:object-contain [&>picture>img]:object-contain',
  fill: '[&>img]:object-fill [&>video]:object-fill [&>picture>img]:object-fill',
  none: '[&>img]:object-none [&>video]:object-none [&>picture>img]:object-none'
};

/**
 * A box that keeps a proportion whatever width it is given.
 *
 * It draws nothing — no sheet, no hairline, no shadow — which is what puts it
 * in `layout` beside `PlContainer` and `PlGrid` rather than in `surfaces`. What
 * it does is reserve the space: a card whose image arrives late does not reflow
 * the page around it, and a row of thumbnails is a row of one shape.
 *
 * The proportion is CSS's own `aspect-ratio`, so a caller who already knows
 * `16 / 9` has nothing to translate. `fit` is the one convenience on top: the
 * media inside is stretched to the box and then fitted, which is the pair of
 * declarations every use of this component would otherwise start with.
 */
export const PlAspectRatio = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlAspectRatioProps>(
  function PlAspectRatio(
    {
      ratio = 1,
      fit = 'cover',
      rounded = false,
      size: sizeProp,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';

    const classNames = cx(
      // `overflow-hidden` is not decoration: without it a `cover` image spills
      // out of the proportion it was just given, and the box would only be
      // reserving space rather than holding anything to it.
      'relative block w-full overflow-hidden',
      stretchClasses,
      fitClasses[fit],
      rounded ? radiusClasses[size] : '',
      className
    );

    return useRender({
      render,
      ref,
      props: {
        className: classNames,
        style: { aspectRatio: ratio, ...style },
        children,
        ...props
      }
    });
  }
);
