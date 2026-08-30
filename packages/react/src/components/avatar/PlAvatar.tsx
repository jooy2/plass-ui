'use client';

import * as React from 'react';
import { Avatar as BaseUIAvatar } from '@base-ui/react/avatar';
import { AvatarGroupContext } from '../../internal/avatar-group.js';
import {
  controlHeightClasses,
  controlSlots,
  controlSquareClasses,
  glassClasses,
  hasContent,
  radiusClasses,
  srOnlyClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassElevation, PlassSize, PlassVariant } from '../../types.js';

/** What Base UI reports about the picture as it loads. */
export type PlAvatarLoadingStatus = 'idle' | 'loading' | 'loaded' | 'error';

/**
 * The crop, not the material.
 *
 * `circle` is the default. A round crop is what a portrait has been for as long
 * as there have been portraits, and an avatar is not a surface — it is a picture
 * laid on one, so it does not owe the radius ladder anything.
 *
 * `square` takes the library's own fillet instead, which is what a logo or a
 * repository icon wants: those are drawn to the edges of a rectangle and a round
 * crop eats them.
 */
export type PlAvatarShape = 'circle' | 'square';

export interface PlAvatarProps extends Omit<React.ComponentPropsWithoutRef<'span'>, 'color'> {
  /**
   * The picture. Until it loads — and forever, if it fails — the fallback is
   * what is drawn, so an avatar is never an empty box.
   */
  src?: string;
  /** Candidate images at other resolutions, as on any `<img>`. */
  srcSet?: string;
  /**
   * What the picture says, for a reader who cannot see it. Defaults to `name`,
   * and to nothing at all when there is no name — an avatar next to the person's
   * own name in a row is decoration, and reading it out says the name twice.
   */
  alt?: string;
  /**
   * Who or what this is. One prop doing three jobs: it names the picture, the
   * initials are derived from it, and it is the sentence a screen reader hears
   * instead of those initials.
   *
   * The initials are the first character of the first word plus the first
   * character of the last — "Jane Doe" is `JD`, "홍길동" is `홍`. That rule is
   * wrong for some names, which is what `initials` is for.
   */
  name?: string;
  /** The initials, written out, for when the rule derived the wrong ones. */
  initials?: string;
  /**
   * The crop.
   * @default 'circle'
   */
  shape?: PlAvatarShape;
  /**
   * What the sheet behind the fallback is made of. Invisible once a picture has
   * loaded, apart from the edge it keeps.
   *
   * `ghost` is the default: a directory is a page of avatars, and a page of
   * saturated circles is a page nobody can read a name off.
   * @default 'ghost'
   */
  variant?: PlassVariant;
  /**
   * The box the picture is drawn in — the control heights, so an avatar and the
   * button beside it in a toolbar are the same height.
   * @default 'md'
   */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /**
   * Drop shadow depth. `0` is the default: an avatar is a picture set into the
   * page rather than a key resting on it.
   * @default 0
   */
  elevation?: PlassElevation;
  /**
   * How long to wait before drawing the fallback, in milliseconds. Set it to
   * roughly the time a cached image takes and the initials stop flashing up in
   * front of a picture that was about to arrive anyway.
   */
  delay?: number;
  /** Anything else the `<img>` needs — `loading`, `crossOrigin`, `referrerPolicy`. */
  imageProps?: Omit<React.ComponentPropsWithoutRef<'img'>, 'src' | 'srcSet' | 'alt'>;
  /** Called as the picture moves between `idle`, `loading`, `loaded` and `error`. */
  onLoadingStatusChange?: (status: PlAvatarLoadingStatus) => void;
  /**
   * The fallback, drawn instead of the initials. An icon, a logo, a single
   * emoji — whatever stands in for this particular thing when there is no
   * picture of it.
   */
  children?: React.ReactNode;
}

/**
 * The initials, sized off the box rather than off the row.
 *
 * Its own ladder and not `controlTextClasses`, because a control's label is
 * measured against the words next to it and this one is measured against the
 * circle around it: roughly 40% of the diameter at every step, which is where
 * two characters fill the width without touching the edge.
 */
const initialsTextClasses: Record<PlassSize, string> = {
  xs: 'text-[0.5625rem]',
  sm: 'text-[0.6875rem]',
  md: 'text-[0.8125rem]',
  lg: 'text-[1rem]',
  xl: 'text-[1.1875rem]'
};

/**
 * The three materials, said the way a *control* says them: an avatar **is** the
 * thing being coloured — a portrait of one particular person — so its sheet
 * takes the tint, exactly as a `PlAlert`'s does and unlike a `PlCard`'s.
 *
 * `solid` carries no gloss line, for the reason a filled `PlButton` carries
 * none: the gradient is the form.
 */
const variantClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'text-(--p-on-solid) [background-image:var(--p-fill)]',
    '[box-shadow:var(--p-elev),var(--p-lift)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    glassClasses,
    'border text-(--p-accent) bg-(--plass-glass)',
    '[border-color:var(--plass-border)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: 'text-(--p-accent) bg-(--p-soft-press) [box-shadow:var(--p-elev)]'
};

const baseClasses = /* @__PURE__ */ [
  'relative inline-flex shrink-0 select-none items-center justify-center overflow-hidden',
  'align-middle leading-none font-semibold tracking-wide whitespace-nowrap',
  // A glyph handed to `children` is drawn against the circle, not against a
  // word, so it is sized off the box like the initials are rather than off the
  // `1.2em` an icon riding on a label takes.
  '[&_svg]:pointer-events-none [&_svg]:size-[55%]',
  transitionClasses
].join(' ');

/**
 * The default fallback: a shoulders-and-head silhouette, drawn here rather than
 * in `internal/icons` because this is the only component that needs it.
 *
 * It exists so that `<PlAvatar />` with nothing at all is still an avatar. A box
 * with no picture, no name and no glyph in it is indistinguishable from a
 * component that failed to render.
 */
function PersonIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
      <path d="M12 12a4.5 4.5 0 1 0 0-9 4.5 4.5 0 0 0 0 9Z" />
      <path d="M12 14.25c-4.28 0-7.75 2.42-7.75 5.4 0 .75.6 1.35 1.35 1.35h12.8c.75 0 1.35-.6 1.35-1.35 0-2.98-3.47-5.4-7.75-5.4Z" />
    </svg>
  );
}

/**
 * The first character of the first word, plus the first of the last.
 *
 * `Array.from` rather than `[0]`, so a name that starts with an emoji or with
 * any character outside the basic plane is not cut in half between its two code
 * units. `normalize('NFC')` first, so a name whose accents arrived decomposed —
 * which is what a macOS filename and a good many APIs hand you — yields `Ä`
 * rather than a bare `A`.
 *
 * One word gives one character on purpose. Korean, Japanese and Chinese names
 * are a single token, and two of their characters at 40px is a smudge where one
 * is a name.
 */
function initialsOf(name: string): string {
  const words = name.normalize('NFC').trim().split(/\s+/).filter(Boolean);

  if (words.length === 0) {
    return '';
  }

  const first = Array.from(words[0])[0] ?? '';
  const last = words.length > 1 ? (Array.from(words[words.length - 1])[0] ?? '') : '';

  return (first + last).toLocaleUpperCase();
}

/**
 * A picture of a person or a thing, at a known size, that is never an empty box.
 *
 * Three things can be drawn in it and exactly one of them is at a time: the
 * picture, if `src` is given and it loads; otherwise whatever stands in for it —
 * `children`, or `initials`, or the initials derived from `name`; and failing
 * all of those, a silhouette. Which one is showing is Base UI's `Avatar` to
 * decide, because "has the image loaded" is a question with four answers and a
 * race in the middle of it.
 *
 * It carries no status dot of its own. An avatar with a green mark on it is a
 * `PlBadge` with an avatar in it, and inventing a second spelling for that would
 * give the library two of them.
 */
export const PlAvatar = /* @__PURE__ */ React.forwardRef<HTMLSpanElement, PlAvatarProps>(
  function PlAvatar(
    {
      src,
      srcSet,
      alt,
      name,
      initials,
      shape: shapeProp,
      variant: variantProp,
      size: sizeProp,
      color: colorProp,
      elevation: elevationProp,
      delay,
      imageProps,
      onLoadingStatusChange,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    /*
     * A `PlAvatarGroup` around this avatar sets the axes once for the stack. The
     * avatar's own prop still wins, which is what lets one face in a row be
     * marked out from the rest, and with no group around it the fallbacks are
     * the defaults they always were.
     */
    const group = React.useContext(AvatarGroupContext);
    const shape = shapeProp ?? group?.shape ?? 'circle';
    const variant = variantProp ?? group?.variant ?? 'ghost';
    const size = sizeProp ?? group?.size ?? 'md';
    const color = colorProp ?? group?.color ?? 'primary';
    const elevation = elevationProp ?? group?.elevation ?? 0;

    const derived = name ? initialsOf(name) : '';
    const label = alt ?? name;

    // `children` beats the initials beats the silhouette. Only the last of the
    // three has nothing to say, which is what decides whether the fallback needs
    // the name spelled out beside it.
    const stand = hasContent(children) ? children : (initials ?? derived) || <PersonIcon />;
    const speaks = hasContent(children) || Boolean(initials ?? derived);

    const classNames = [
      baseClasses,
      controlHeightClasses[size],
      controlSquareClasses[size],
      initialsTextClasses[size],
      shape === 'circle' ? 'rounded-full' : radiusClasses[size],
      variantClasses[variant],
      className ?? ''
    ]
      .filter(Boolean)
      .join(' ');

    return (
      <BaseUIAvatar.Root
        ref={ref}
        className={classNames}
        style={{ ...controlSlots(color, elevation, variant), ...style }}
        {...props}
      >
        {src ? (
          <BaseUIAvatar.Image
            src={src}
            srcSet={srcSet}
            // Empty rather than absent: an avatar beside the person's own name is
            // decoration, and `alt` left off is what makes a screen reader read
            // the file name out instead.
            alt={label ?? ''}
            className="size-full object-cover"
            onLoadingStatusChange={onLoadingStatusChange}
            {...imageProps}
          />
        ) : null}

        <BaseUIAvatar.Fallback
          delay={src ? delay : undefined}
          className="flex size-full items-center justify-center"
        >
          {/* `JD` read out loud is two letters, not a person. When there is a name
            it becomes the fallback's accessible name and the initials are left
            as the picture they are standing in for. */}
          {label && speaks ? <span className={srOnlyClasses}>{label}</span> : null}
          <span aria-hidden={label && speaks ? true : undefined} className="contents">
            {stand}
          </span>
        </BaseUIAvatar.Fallback>
      </BaseUIAvatar.Root>
    );
  }
);
