'use client';

import * as React from 'react';
import { useLabels } from '../../internal/labels.js';
import { useRender } from '@base-ui/react/use-render';
import { ExternalLinkIcon, LinkIcon } from '../../internal/icons.js';
import {
  controlTextLeadingClasses,
  focusRingClasses,
  srOnlyClasses
} from '../../internal/styles.js';
import { safeRel } from '../../internal/link.js';
import type { PlassColor, PlassSize } from '../../types.js';

/**
 * When the line under a link is drawn.
 *
 * `always` is the default, and the reason is `color`: a link takes no colour
 * family unless one is asked for, so with the line off there would be nothing
 * at all distinguishing it from the sentence it sits in. That is also why this
 * is not a boolean — "no underline" is a real choice for a link in a nav bar or
 * a footer, where position already says what it is, and it should have to be
 * spelled out rather than fallen into.
 */
export type PlTextLinkUnderline = 'always' | 'hover' | 'none';

export interface PlTextLinkProps extends Omit<React.ComponentPropsWithoutRef<'a'>, 'color'> {
  /** Where the link goes. */
  href: string;
  /**
   * When the underline is drawn.
   * @default 'always'
   */
  underline?: PlTextLinkUnderline;
  /**
   * Semantic colour role. Unlike every control in the library this has **no
   * default** — a link in a paragraph is usually the paragraph's own colour
   * with a line under it, and a component that arrived pre-dyed is one a page
   * has to undo.
   */
  color?: PlassColor;
  /**
   * The type scale. Also no default: a link inside a sentence is the size of
   * the sentence. Set it for a link that stands on its own.
   */
  size?: PlassSize;
  /**
   * Opens the link in a new tab, with the `rel` that keeps the new page from
   * reaching back into this one.
   *
   * A window changing under the reader is the one thing about a link that
   * cannot be seen before it happens, so this also turns `icon` on by default
   * and adds a line for a screen reader.
   * @default false
   */
  newTab?: boolean;
  /**
   * The mark after the label. `true` draws the arrow leaving its box when
   * `newTab` is on and the chain otherwise, `false` draws nothing, and a node
   * of your own replaces the glyph.
   *
   * Left out, it follows `newTab`.
   *
   * It is `icon` rather than `endIcon`, and the difference from every other
   * component's is the reason: this one is about the link's *destination*, and
   * it has an opinion — a link that takes over the window says so unless it is
   * told not to. An `endIcon` elsewhere is a node and nothing else.
   */
  icon?: React.ReactNode | boolean;
  /**
   * A mark before the label — a favicon, a file type, a lock.
   *
   * A plain node with no opinion, unlike `icon` above: nothing is drawn here
   * unless something is put here. It rides on the label at the same size,
   * separated by the same quarter-em, so a link with one in front of it still
   * sits inside a sentence.
   */
  startIcon?: React.ReactNode;
  /**
   * What a screen reader hears after the label on a `newTab` link. Never drawn.
   * @default '(opens in a new tab)'
   */
  newTabLabel?: string;
  /**
   * Renders something other than an `<a>` — the `Link` a router brings, most of
   * the time.
   *
   * **An `href` on what comes back wins.** A router's `Link` does not pass its
   * address through; it *resolves* one — a locale prefix, a base path, a typed
   * route — and hands the anchor the result. So when the element carries an
   * `href` of its own, this component's is not merged over it, and the router
   * keeps what it worked out. Written the other way round, every localised link
   * in an app silently lost its prefix.
   *
   * The element having none is the ordinary case (`render={<a />}`), and there
   * the `href` above is used.
   */
  render?: useRender.RenderProp;
  /** The label. */
  children?: React.ReactNode;
}

/**
 * Whether the line is drawn, and — with the colour below — the only two things
 * about a link that a prop changes. Everything else about the line is in
 * `styles.css`, under `.plass-link`.
 *
 * Every utility here is written through `[&.plass-link]`, which doubles the
 * component's own class into the selector and takes it to two classes. That is
 * not decoration: `<a>` is, with `<td>`, one of the two tags a host stylesheet
 * still styles by name — `.prose a`, `.vp-doc a`, every CSS framework — and all
 * of those are a class plus a type, which outranks a plain utility. A link that
 * lost its colour and its line inside a `.prose` block would have lost the only
 * two things it is.
 *
 * Hover deliberately leaves the *text* colour alone. A link inside running
 * prose that changes colour under the pointer drags the reader's eye off the
 * line they were reading — the same rule the library applies to a control's
 * label, on the one component that lives inside a sentence.
 */
const underlineClasses: Record<PlTextLinkUnderline, string> = {
  always: '[&.plass-link]:underline',
  hover: '[&.plass-link]:no-underline [&.plass-link]:hover:underline',
  // Nothing to hover, on purpose. A link with no line and no colour is a link
  // whose surroundings are saying what it is.
  none: '[&.plass-link]:no-underline'
};

/**
 * Only two properties move, so this is written out rather than taken from
 * `transitionClasses` — the house list has no `text-decoration-color` in it,
 * and adding one there would put a property on every control in the library
 * that no control draws.
 */
const transition = /* @__PURE__ */ [
  '[transition-property:color,text-decoration-color]',
  '[transition-duration:var(--plass-duration)]',
  '[transition-timing-function:var(--plass-ease)]'
].join(' ');

const baseClasses = /* @__PURE__ */ [
  // Both a style hook and the specificity. `styles.css` doubles this class to
  // write the parts of the line that never vary — its thickness, its offset,
  // its colour — above whatever the host page says about an `<a>`, and every
  // utility that *does* vary is written through it for the same reason.
  'plass-link',
  'cursor-pointer',
  // The glyph rides on the label at just under its cap height, rather than at
  // the `1.2em` an icon inside a control takes: this one sits in a sentence,
  // and an icon as tall as the line spaces the words around it apart.
  '[&_svg]:pointer-events-none [&_svg]:inline [&_svg]:size-[0.95em] [&_svg]:shrink-0',
  transition,
  focusRingClasses,
  'focus-visible:rounded-[0.25rem]'
].join(' ');

/**
 * A link, in a sentence or on its own.
 *
 * Everything about it is deliberately smaller than a PlButton. It has no
 * surface, no height of its own and no colour unless asked — what it has is a
 * line under it, which is the one mark a reader already knows means "this goes
 * somewhere".
 *
 * The three things it does that a bare `<a>` does not: it draws that line on a
 * schedule (`always`, or only under the pointer), it marks a link that opens a
 * new tab both visibly and for a screen reader, and it takes `render`, so the
 * `Link` a router brings can wear all of it.
 */
export const PlTextLink = /* @__PURE__ */ React.forwardRef<HTMLAnchorElement, PlTextLinkProps>(
  function PlTextLink(
    {
      href,
      underline = 'always',
      color,
      size,
      newTab = false,
      icon,
      startIcon,
      newTabLabel: newTabLabelProp,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const labels = useLabels();
    const newTabLabel = newTabLabelProp ?? labels.newTab;

    // `icon` left out follows `newTab`, which is the whole reason it is not a
    // plain boolean with a `false` default: a link that takes over the window
    // should say so, and a caller should have to ask for the silent version.
    const mark = icon ?? newTab;
    const glyph = mark === true ? newTab ? <ExternalLinkIcon /> : <LinkIcon /> : mark;

    const classNames = [
      baseClasses,
      size ? controlTextLeadingClasses[size] : '',
      underlineClasses[underline],
      color ? '[&.plass-link]:text-(--p-accent)' : '[&.plass-link]:text-inherit',
      className ?? ''
    ]
      .filter(Boolean)
      .join(' ');

    /*
     * The two line colours and the focus ring, as slots.
     *
     * `--p-ring` is set even when no family was asked for, because the ring is
     * written as the `outline` shorthand and an undefined `var()` inside it
     * makes the browser drop the whole declaration — an uncoloured link would
     * lose its focus ring entirely rather than fall back to something plainer.
     *
     * The line rests at 45% of whatever the text is and goes to the full colour
     * on hover, so it works the same on an inherited colour as on an accent one.
     */
    const slots = {
      '--p-underline': 'color-mix(in oklab, currentColor 45%, transparent)',
      '--p-underline-hover': 'currentColor',
      '--p-ring': `var(--plass-${color ?? 'primary'}-ring)`,
      ...(color ? { '--p-accent': `var(--plass-${color}-accent)` } : null)
    } as React.CSSProperties;

    /*
     * Whether the caller's own element already knows where it goes.
     *
     * A router's `Link` resolves an address rather than forwarding one, and
     * what it resolves reaches the anchor through its own render — so merging
     * this component's `href` on top of it throws that work away and puts the
     * raw string back. Only an element is checked: a render *function* builds
     * its element from the props it is handed, which is the other half of the
     * same contract.
     */
    const rendersItsOwnHref =
      React.isValidElement(render) && (render.props as { href?: string }).href !== undefined;

    /*
     * `rel` is merged rather than replaced — see `internal/link.ts` for why
     * that is a security decision rather than a convenience.
     */
    const { rel: askedFor, ...rest } = props;
    const rel = safeRel(newTab ? '_blank' : undefined, askedFor);

    return useRender({
      render: render ?? <a />,
      ref,
      props: {
        ...(rendersItsOwnHref ? null : { href }),
        target: newTab ? '_blank' : undefined,
        className: classNames,
        style: { ...slots, ...style },
        children: (
          <>
            {startIcon ? <span className="me-[0.25em]">{startIcon}</span> : null}
            {children}
            {glyph ? <span className="ms-[0.25em]">{glyph}</span> : null}
            {/* Drawn for nobody and read to everybody: the arrow says "new tab"
                only to a reader who can see it. The space is a real text node,
                so the accessible name comes out as two words rather than as the
                label with a bracket stuck to the end of it. */}
            {newTab ? (
              <>
                {' '}
                <span className={srOnlyClasses}>{newTabLabel}</span>
              </>
            ) : null}
          </>
        ),
        ...rest,
        // After the spread on purpose: this is the merge above, not an override
        // for a caller to win.
        rel
      }
    });
  }
);
