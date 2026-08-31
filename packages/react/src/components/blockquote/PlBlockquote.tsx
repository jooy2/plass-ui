'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import {
  glassClasses,
  hasContent,
  metaTextClasses,
  radiusClasses,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassElevation, PlassSize, PlassStyleProps, PlassVariant } from '../../types.js';

/**
 * The props are a `<figure>`'s rather than a `<blockquote>`'s, which is a
 * consequence of where the drawing happens: everything a caller passes lands on
 * the wrapper, and the wrapper is a figure or a div. Both are `HTMLElement`, so
 * an event handler written against one works on the other.
 */
export interface PlBlockquoteProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'figure'>, 'color'> {
  /**
   * Drop shadow depth. `0` is the default — a quote is set *into* a page rather
   * than floating over it, so it is raised even less often than a `PlCard`.
   * @default 0
   */
  elevation?: PlassElevation;
  /**
   * Who said it. Its presence is what turns the quote into a `<figure>` with a
   * `<figcaption>`, which is the markup the HTML spec asks for: an attribution
   * is *about* the quote and is not part of what was said.
   */
  author?: React.ReactNode;
  /**
   * Where it is from — a book, a talk, a page. Rendered inside a `<cite>`, which
   * is the element for the title of a work and, per the spec, never for the name
   * of a person. That is what `author` is.
   */
  source?: React.ReactNode;
  /**
   * URL of the document the quote was taken from. Lands on the `<blockquote>`'s
   * own `cite` attribute, which is machine-readable and shown to nobody — use
   * `source` for the part a reader should see.
   */
  cite?: string;
  /**
   * The mark drawn before the quote. Omit it for the house glyph, pass a node to
   * replace it, pass `false` to take it away — the same three-way spelling
   * `PlAlert` uses for the same idea.
   */
  icon?: React.ReactNode | false;
  /** What was said. */
  children?: React.ReactNode;
}

/**
 * The quote itself, one step above body copy with the leading opened up.
 *
 * The sizes are `sheetTitleClasses`', because a quote is set at a heading's
 * scale — but the leading is not: a title is a line or two and a quote is a
 * paragraph somebody has to read, so it gets the air a paragraph needs.
 */
const quoteTextClasses: Record<PlassSize, string> = {
  xs: 'text-[0.75rem]/[1.25rem]',
  sm: 'text-[0.8125rem]/[1.375rem]',
  md: 'text-[0.9375rem]/[1.625rem]',
  lg: 'text-[1.0625rem]/[1.875rem]',
  xl: 'text-[1.25rem]/[2.125rem]'
};

/**
 * The rule down the leading edge, and the one thing every variant has.
 *
 * `border-s`, not `border-l`: the rule belongs on the side the text starts on,
 * which is the right edge under RTL. Its width is the one number here that does
 * not come off a ladder — a quote rule is 2px at every size, because it is a
 * mark in the margin rather than a part of the type.
 */
const ruleClasses = 'border-s-2 [border-inline-start-color:var(--p-accent)]';

/**
 * The three materials, said the way a *container* says them — the sheet is never
 * dyed, exactly as on a `PlCard`. A quote holds somebody else's words, and words
 * on a tinted pane are words on a background nobody chose them against. The
 * family reaches the rule and stops.
 *
 * `ghost` is the default and the one that belongs in running prose: a rule in
 * the margin and nothing else, which is what a quote has looked like since long
 * before there were surfaces to put one on.
 */
const variantClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    glassClasses,
    'bg-(--plass-glass-press)',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  // `border-s-2` again, after `border`, so the hairline on the other three edges
  // does not flatten the rule back to a pixel.
  glass: /* @__PURE__ */ [
    glassClasses,
    'border border-s-2 bg-(--plass-glass)',
    '[border-color:var(--plass-glass-line)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: 'bg-transparent'
};

/**
 * The quotation mark: a pair of commas turned up, drawn rather than typed.
 *
 * A real `“` would be set in whatever face the page uses and would change shape,
 * weight and baseline with it — and at 2em it is the largest single glyph in the
 * component, so it changing is the most visible thing that could. This is one
 * drawing at one weight, and it lives here rather than in `internal/icons.tsx`
 * because exactly one component draws it.
 */
function QuoteMarkIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M6.4 3.6c-2.3.9-3.7 2.8-3.7 5.1 0 2 1.2 3.3 2.8 3.3 1.4 0 2.5-1 2.5-2.4 0-1.3-.9-2.2-2.1-2.2-.2 0-.4 0-.6.1.3-1 1.1-1.8 2.2-2.3l-1.1-1.6ZM13.3 3.6c-2.3.9-3.7 2.8-3.7 5.1 0 2 1.2 3.3 2.8 3.3 1.4 0 2.5-1 2.5-2.4 0-1.3-.9-2.2-2.1-2.2-.2 0-.4 0-.6.1.3-1 1.1-1.8 2.2-2.3l-1.1-1.6Z"
        fill="currentColor"
      />
    </svg>
  );
}

/**
 * Somebody else's words, set apart from your own.
 *
 * There is no Base UI primitive under this and there should not be: a quote has
 * no state, no keyboard contract and nothing to interact with. What it has is
 * markup that is easy to get wrong, and getting it right is most of the point.
 *
 * **Nothing is drawn on the `<blockquote>` itself.** The surface, the rule and
 * the padding all belong to the element around it, and that is not tidiness —
 * `blockquote` is one of the handful of tags a host stylesheet still styles by
 * name. VitePress's `.vp-doc blockquote` sets a grey `border-left`, a
 * `padding-left` and a `color`, all at a specificity a one-class utility cannot
 * outrank, so a rule drawn on the quote itself would silently come out grey and
 * a pixel too thin. Moving the drawing onto a wrapper is what lets the docs undo
 * VitePress's version without also undoing this one.
 *
 * The wrapper is a `<figure>` when there is an attribution and a `<div>` when
 * there is not, because the HTML spec is explicit that the attribution goes
 * *outside* the blockquote — a name inside it claims the speaker said their own
 * name — and a `<figure>` with no `<figcaption>` in it is a figure of nothing.
 */
export const PlBlockquote = /* @__PURE__ */ React.forwardRef<HTMLElement, PlBlockquoteProps>(
  function PlBlockquote(
    {
      variant = 'ghost',
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      elevation = 0,
      author,
      source,
      cite,
      icon,
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

    const attributed = hasContent(author) || hasContent(source);
    const glyph = icon === undefined ? <QuoteMarkIcon /> : icon;

    const shellClasses = [
      'flex flex-col text-(--plass-fg)',
      ruleClasses,
      // The corners on the ruled edge stay square: a 2px rule that curves away
      // from the text it marks is a bracket, not a margin rule.
      variant === 'ghost' ? '' : `${radiusClasses[size]} rounded-s-none`,
      variantClasses[variant],
      sheetPaddingXClasses[density][size],
      sheetPaddingYClasses[density][size],
      transitionClasses,
      className ?? ''
    ]
      .filter(Boolean)
      .join(' ');

    const quote = (
      <blockquote cite={cite} className={quoteTextClasses[size]}>
        {hasContent(glyph) ? (
          // The mark tracks the quote's own type scale at twice its size, so one
          // drawing is the right size at every step of the ladder.
          <span
            aria-hidden="true"
            className="mb-1 block size-[2em] text-(--p-soft-press) [&>svg]:size-full"
          >
            {glyph}
          </span>
        ) : null}
        {children}
      </blockquote>
    );

    const shellStyle = { ...surfaceSlots(color, elevation), ...style };

    if (!attributed) {
      return (
        <div
          ref={ref as React.Ref<HTMLDivElement>}
          className={shellClasses}
          style={shellStyle}
          {...props}
        >
          {quote}
        </div>
      );
    }

    return (
      <figure ref={ref} className={shellClasses} style={shellStyle} {...props}>
        {quote}

        <figcaption
          className={[
            'mt-2 flex flex-wrap items-baseline gap-x-1.5 text-(--plass-muted-fg)',
            metaTextClasses[size]
          ].join(' ')}
        >
          {hasContent(author) ? (
            <span className="font-medium text-(--plass-fg)">
              {/* An em dash, the way an attribution has been set since print, and
                `aria-hidden` because a screen reader announcing "em dash" before
                a name is reading the typography rather than the text. */}
              <span aria-hidden="true">— </span>
              {author}
            </span>
          ) : null}
          {/* `<cite>` arrives italic from the browser's own stylesheet. The library
            has one type scale and italics are not on it. */}
          {hasContent(source) ? <cite className="not-italic">{source}</cite> : null}
        </figcaption>
      </figure>
    );
  }
);
