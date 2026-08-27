import * as React from 'react';
import { iconSizeClasses } from '../../internal/styles.js';
import type { PlassColor, PlassSize } from '../../types.js';

/**
 * The same five lengths as `iconSizeClasses`, as a font size.
 *
 * Written out rather than inherited: an icon set hands back an `<svg>` sized in
 * `em` about as often as one sized in `px`, and the only way both come out right
 * is for the box's own font size to *be* the box. `text-[length:inherit]` would
 * take the surrounding paragraph's, which is the one size the box deliberately
 * is not.
 */
const glyphFontClasses: Record<PlassSize, string> = {
  xs: 'text-[0.875rem]',
  sm: 'text-[1rem]',
  md: 'text-[1.25rem]',
  lg: 'text-[1.5rem]',
  xl: 'text-[1.75rem]'
};

export interface PlIconProps extends Omit<React.ComponentPropsWithoutRef<'span'>, 'color'> {
  /**
   * The glyph. An `<svg>` element, an `<img>`, a component from an icon set, or
   * a character — whatever is passed is laid into a box of the right size and
   * given a colour to inherit.
   *
   * It is a prop rather than `children` on purpose. An icon set hands you an
   * element you did not draw, and the two things you always want to change about
   * it — how big it is and what colour it is — are the two you cannot reach once
   * it is a child of something. As a prop it is content the icon *sizes*, not
   * content the icon merely wraps.
   */
  icon: React.ReactNode;
  /**
   * The box the glyph is drawn in: 14, 16, 20, 24 and 28px. Its own ladder
   * rather than the control heights, because an icon is not a control.
   * @default 'md'
   */
  size?: PlassSize;
  /**
   * Semantic colour role, or `inherit` — the default — to take the colour of
   * whatever the icon sits in.
   *
   * `inherit` and not `primary`, which is the one place this prop departs from
   * every other component in the library. An icon is content, and the
   * overwhelmingly common case is an icon inside something that has already
   * decided what colour its content is: a `PlButton`'s label, a muted caption, a
   * `PlAlert`'s own family. An icon that arrived pre-dyed would have to be turned
   * off again at every one of those.
   * @default 'inherit'
   */
  color?: PlassColor | 'inherit';
  /**
   * What the icon says, for a reader who cannot see it.
   *
   * Without it the icon is hidden from the accessibility tree entirely, which is
   * the right default: the overwhelming majority of icons sit next to a word that
   * already says the same thing, and reading both out loud is worse than reading
   * one. Pass this only when the glyph is carrying meaning on its own.
   */
  label?: string;
}

/**
 * A glyph at a known size, in a known colour.
 *
 * The library draws no icons of its own beyond the handful its components need —
 * an icon set is a decision that belongs to the app, not to the component
 * library it installs. What this does is give whatever icon the app chose the
 * same two axes everything else here has.
 *
 * The box is `inline-flex` with the glyph told to fill it, and `font-size` is
 * set to the same length — so an `<svg>` with its own `width`, an `<svg>` sized
 * in `em`, and a bare character all come out the same size. That is the whole
 * component: a box, a length written twice, and a colour.
 *
 * There is no `variant` and no `elevation`. An icon is not a surface: it is ink,
 * and the only thing the design language has to say about ink is which family it
 * is drawn in.
 */
export const PlIcon = React.forwardRef<HTMLSpanElement, PlIconProps>(function PlIcon(
  { icon, size = 'md', color = 'inherit', label, className, style, ...props },
  ref
) {
  const classNames = [
    'inline-flex shrink-0 items-center justify-center align-middle',
    iconSizeClasses[size],
    // The glyph fills the box however it was authored. `[font-size:100%]` on the
    // box itself would be a no-op; what makes an em-sized drawing come out right
    // is the box being an em, which `size-*` and this pair together arrange.
    '[&>svg]:block [&>svg]:size-full [&>img]:block [&>img]:size-full',
    `leading-none ${glyphFontClasses[size]}`,
    color === 'inherit' ? '' : 'text-(--p-accent)',
    className ?? ''
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <span
      ref={ref}
      className={classNames}
      style={
        (color === 'inherit'
          ? style
          : { '--p-accent': `var(--plass-${color}-accent)`, ...style }) as React.CSSProperties
      }
      // An icon with something to say is an `img` with a name; one without is
      // furniture. There is no third case, and `role="img"` on a decorative glyph
      // is the most common way a screen reader ends up saying "graphic".
      role={label ? 'img' : undefined}
      aria-label={label}
      aria-hidden={label ? undefined : true}
      {...props}
    >
      {icon}
    </span>
  );
});
