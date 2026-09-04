'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { useDefaults } from '../../internal/defaults.js';
import {
  controlSlots,
  cx,
  glassClasses,
  hasContent,
  metaTextClasses,
  radiusClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassSize, PlassVariant } from '../../types.js';

/**
 * How the artwork is framed, which is the one question this component exists to
 * answer.
 *
 * - `bare` — drawn as it was given, at the height `size` asks for and whatever
 *   width that comes to. No plate, no crop, no padding. The default, and the
 *   only one that is correct for a mark drawn with its own background, its own
 *   margin, or the product's name set into it.
 * - `plate` — an app icon: a tile with the artwork inset in it and the corners
 *   cut to the house radius. What a mark drawn as a bare glyph needs before it
 *   can sit next to anything else.
 * - `circle` — the same tile, round. For the products whose icon is a disc.
 */
export type PlAppLogoShape = 'bare' | 'plate' | 'circle';

export interface PlAppLogoProps extends Omit<React.ComponentPropsWithoutRef<'span'>, 'color'> {
  /**
   * The mark. An `<img>`, an inline `<svg>`, a `PlIcon` — whatever the product's
   * artwork actually is.
   */
  children?: React.ReactNode;
  /** A picture to draw as the mark, instead of `children`. */
  src?: string;
  /**
   * What the picture says, for a reader who cannot see it.
   *
   * Leave it empty when `name` is set: the wordmark beside the mark already
   * says the product's name, and a picture that repeats it is a screen reader
   * saying it twice.
   */
  alt?: string;
  /** The product's name, set beside the mark. */
  name?: React.ReactNode;
  /** A line under the name — an environment, a tenant, a plan. */
  description?: React.ReactNode;
  /** How the artwork is framed. @default 'bare' */
  shape?: PlAppLogoShape;
  /**
   * What the plate is made of. Only read when `shape` is not `bare`.
   * @default 'solid'
   */
  variant?: PlassVariant;
  /** The height of the mark, and the type scale of the name beside it. @default 'md' */
  size?: PlassSize;
  /** The family the plate takes. @default 'primary' */
  color?: PlassColor;
  /**
   * Renders something other than a `<span>`. A logo is nearly always the way
   * back to the front page, so `render={<a href="/" />}` is the ordinary case.
   */
  render?: useRender.RenderProp;
}

/**
 * The mark's height. `md` is 32px, which sits inside a `md` header's 64px floor
 * with room either side rather than filling it.
 */
const markClasses: Record<PlassSize, string> = {
  xs: 'h-5',
  sm: 'h-6',
  md: 'h-8',
  lg: 'h-10',
  xl: 'h-12'
};

/** The same numbers as a square, which is what a plate is. */
const plateClasses: Record<PlassSize, string> = {
  xs: 'size-5',
  sm: 'size-6',
  md: 'size-8',
  lg: 'size-10',
  xl: 'size-12'
};

/** The name beside it: a wordmark, so heavier and larger than a label. */
const nameClasses: Record<PlassSize, string> = {
  xs: 'text-sm',
  sm: 'text-base',
  md: 'text-lg',
  lg: 'text-xl',
  xl: 'text-2xl'
};

/** The gap between the mark and the words. */
const gapClasses: Record<PlassSize, string> = {
  xs: 'gap-1.5',
  sm: 'gap-2',
  md: 'gap-2.5',
  lg: 'gap-3',
  xl: 'gap-3.5'
};

/** What a plate is made of, per variant. The same three materials as everywhere. */
const plateVariantClasses: Record<PlassVariant, string> = {
  solid: '[background-image:var(--p-fill)] text-(--p-on-solid) [box-shadow:var(--p-lift)]',
  glass: `${glassClasses} bg-(--plass-glass) text-(--p-accent) border [border-color:var(--plass-glass-line)]`,
  ghost: 'bg-(--p-soft) text-(--p-accent)'
};

/**
 * A product's mark, and its name beside it.
 *
 * The whole component is the **framing**, which is the one thing a logo needs
 * and the one thing every project gets wrong twice: `bare` is the default
 * because a mark drawn with its own background, its own margin, or the
 * product's name set into it must not be put on a plate or cropped to a circle.
 * `plate` and `circle` are for a mark drawn as a bare glyph, which cannot sit
 * next to anything else until it has been given an edge.
 *
 * It is not a [PlAvatar](./avatar). An avatar is a picture of a person or a
 * thing and is always a circle or a fillet, with initials behind it when the
 * picture fails; a logo is artwork the product owns, it has no fallback worth
 * inventing, and its shape is a decision somebody already made.
 *
 * **With a `name`, the mark is decorative.** The wordmark beside it already
 * says what the product is called, and a picture that says it again is a screen
 * reader reading the name twice. That is why `alt` is a prop rather than
 * something derived from `name`.
 *
 * A logo is nearly always the way back to the front page. `render={<a href="/"
 * />}` makes it one without changing anything about how it is drawn.
 */
export const PlAppLogo = /* @__PURE__ */ React.forwardRef<HTMLSpanElement, PlAppLogoProps>(
  function PlAppLogo(
    {
      children,
      src,
      alt = '',
      name,
      description,
      shape = 'bare',
      variant = 'solid',
      size: sizeProp,
      color: colorProp,
      render,
      className,
      style,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';

    const plated = shape !== 'bare';
    const hasWords = hasContent(name) || hasContent(description);

    const mark = src ? (
      // `w-auto` and not `size-full`: a wordmark is wider than it is tall and
      // cropping it to a square is the failure this component is here to avoid.
      <img src={src} alt={alt} className={plated ? 'size-[70%] object-contain' : 'h-full w-auto'} />
    ) : (
      children
    );

    return useRender({
      render,
      ref,
      props: {
        className: cx(
          'inline-flex items-center text-(--plass-fg) [&_svg]:h-full [&_svg]:w-auto',
          gapClasses[size],
          className
        ),
        style: { ...controlSlots(color, 1, variant), ...style },
        children: (
          <>
            <span
              // Decorative once the name is written out beside it, so the
              // product is announced once rather than twice.
              aria-hidden={hasContent(name) ? true : undefined}
              className={cx(
                'flex shrink-0 items-center justify-center overflow-hidden',
                plated ? plateClasses[size] : markClasses[size],
                plated ? plateVariantClasses[variant] : '',
                shape === 'circle' ? 'rounded-full' : plated ? radiusClasses[size] : ''
              )}
            >
              {mark}
            </span>

            {hasWords ? (
              <span className="flex min-w-0 flex-col">
                {hasContent(name) ? (
                  <span className={cx('truncate font-semibold', nameClasses[size])}>{name}</span>
                ) : null}
                {hasContent(description) ? (
                  <span className={cx('truncate text-(--plass-muted-fg)', metaTextClasses[size])}>
                    {description}
                  </span>
                ) : null}
              </span>
            ) : null}
          </>
        ),
        ...props
      }
    });
  }
);
