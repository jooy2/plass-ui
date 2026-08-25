import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  focusRingClasses,
  hasContent,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetLineClasses,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetRestClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceSlots
} from '../../internal/styles';
import type { PlassElevation, PlassStyleProps, PlassVariant } from '../../types';

export interface PlCardProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title'> {
  /**
   * Drop shadow depth. `1` is the default: a card is a sheet lying **on** the
   * page wash rather than printed into it, and the small amount of grey under
   * it is what says so.
   * @default 1
   */
  elevation?: PlassElevation;
  /**
   * The card's heading. A plain string is styled as the title; pass a real
   * heading element (`title={<h2>…</h2>}`) when the card belongs in the
   * document outline — it inherits the title's typography rather than the
   * browser's.
   */
  title?: React.ReactNode;
  /** A second line under the title, one step down the type scale and muted. */
  subtitle?: React.ReactNode;
  /**
   * Content pinned to the end of the header row — a menu button, a status
   * chip. Stays on the title's line while the title wraps beside it.
   */
  headerAction?: React.ReactNode;
  /**
   * The bottom area. Laid out as a wrapping row so a pair of buttons needs no
   * wrapper of its own; anything else can bring its own layout.
   */
  footer?: React.ReactNode;
  /**
   * Scores the sheet between sections with a hairline instead of separating
   * them with space. The rules run the full width, so the padding moves from
   * the card onto each section.
   * @default false
   */
  dividers?: boolean;
  /**
   * Inner padding, on the `size` / `density` scale. Turn it off for full-bleed
   * content — an image, a table, a list that draws its own rows.
   * @default true
   */
  padded?: boolean;
  /**
   * Lifts the sheet under the pointer and adds a level of elevation.
   *
   * This is the one place the library allows a `transform`, and the exception
   * is the rule rather than a hole in it: what may not move is the thing under
   * the finger — a key whose label resamples as it scales. A sheet that
   * *holds* content is the other kind of surface, and lifting one is how a
   * pane of glass says it can be picked up.
   *
   * It changes how the card looks and nothing else. A card that is actually
   * clickable has to be a real element: `render={<a href="…" />}` or
   * `render={<button type="button" />}`, so it is focusable, announced, and
   * reachable from a keyboard.
   * @default false
   */
  interactive?: boolean;
  /**
   * Renders something other than a `<div>`: `render={<section />}`,
   * `render={<li />}`, `render={<a href="…" />}`. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  /** The card's body. */
  children?: React.ReactNode;
}

/**
 * The house transition with `transform` added to the property list.
 *
 * `transitionClasses` deliberately leaves it out, because no *control* may be
 * transformed. A card is the other kind of surface, so it writes its own list
 * rather than stacking a `transition-[transform]` on top of the shared one —
 * two `transition-property` declarations of equal specificity resolve by their
 * order in the generated stylesheet, which is not something a component should
 * depend on.
 */
const cardTransitionClasses = [
  '[transition-property:background-color,border-color,box-shadow,color,transform]',
  '[transition-duration:var(--plass-duration)]',
  '[transition-timing-function:var(--plass-ease)]'
].join(' ');

/**
 * Hover lifts the sheet and puts a level of shadow under it; the press sets it
 * back down. Both directions take the house duration, and no `filter` is
 * involved — a card is not a coloured surface, so there is no brightness to
 * turn up.
 */
const interactiveClasses: Record<PlassVariant, string> = {
  solid: [
    'cursor-pointer hover:-translate-y-0.5',
    'hover:[box-shadow:var(--p-elev-hover),var(--plass-gloss-glass)]',
    'active:translate-y-0 active:[box-shadow:var(--p-elev-press),var(--plass-gloss-glass)]'
  ].join(' '),
  glass: [
    'cursor-pointer hover:-translate-y-0.5 hover:bg-(--plass-glass-hover)',
    'hover:[border-color:var(--p-line)]',
    'hover:[box-shadow:var(--p-elev-hover),var(--plass-gloss-glass)]',
    'active:translate-y-0 active:[box-shadow:var(--p-elev-press),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: 'cursor-pointer hover:bg-(--p-soft) active:bg-(--p-soft-hover)'
};

/**
 * The sheet everything else on a screen is grouped onto, with the parts a card
 * is made of laid out on it: a title, a subtitle, a body and a footer.
 *
 * The sections are props rather than compound sub-components — `<Card.Header>`,
 * `<Card.Title>` — for the same reason `PlTextField` takes `label` and
 * `description` as props: the arrangement is fixed, and what a caller wants to
 * decide is what goes in each slot, not what order the slots come in.
 *
 * There is no Base UI primitive under this, and there should not be. A card has
 * no interaction to delegate: it is a surface with a layout, and the moment it
 * becomes something you press it is a `render` away from being a real one.
 */
export const PlCard = React.forwardRef<HTMLDivElement, PlCardProps>(function PlCard(
  {
    variant = 'glass',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 1,
    title,
    subtitle,
    headerAction,
    footer,
    dividers = false,
    padded = true,
    interactive = false,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const insetX = padded ? sheetPaddingXClasses[density][size] : '';
  const insetY = padded ? sheetPaddingYClasses[density][size] : '';
  // Scored, the rules have to reach both edges, so the sheet gives up its
  // padding and every section takes it on instead. Unscored, the sheet keeps
  // its vertical padding and the sections are told apart by a gap.
  const sectionClasses = dividers ? `${insetX} ${insetY}` : insetX;

  const hasHeader = hasContent(title) || hasContent(subtitle) || hasContent(headerAction);

  const header = (
    <>
      {hasContent(title) || hasContent(subtitle) ? (
        <div className={`flex min-w-0 flex-1 flex-col ${sheetHeaderGapClasses[size]}`}>
          {hasContent(title) ? (
            <div className={`plass-title font-semibold ${sheetTitleClasses[size]}`}>{title}</div>
          ) : null}
          {hasContent(subtitle) ? (
            <div className={`text-(--plass-muted-fg) ${metaTextClasses[size]}`}>{subtitle}</div>
          ) : null}
        </div>
      ) : null}
      {hasContent(headerAction) ? <div className="ml-auto shrink-0">{headerAction}</div> : null}
    </>
  );

  const sections = [
    hasHeader ? { key: 'header', className: 'flex items-start gap-3', content: header } : null,
    hasContent(children)
      ? { key: 'content', className: sheetBodyClasses[size], content: children }
      : null,
    hasContent(footer)
      ? {
          key: 'footer',
          className: `flex flex-wrap items-center gap-2 ${sheetBodyClasses[size]}`,
          content: footer
        }
      : null
  ].filter((section) => section !== null);

  const classNames = [
    'flex flex-col',
    radiusClasses[size],
    sheetRestClasses[variant],
    cardTransitionClasses,
    interactive ? `${interactiveClasses[variant]} ${focusRingClasses}` : '',
    dividers ? 'overflow-hidden' : `${insetY} ${sheetSectionGapClasses[size]}`,
    className ?? ''
  ]
    .filter(Boolean)
    .join(' ');

  return useRender({
    render: render ?? <div />,
    ref,
    props: {
      className: classNames,
      style: { ...surfaceSlots(color, elevation), ...style },
      ...props,
      children: sections.map((section, index) => (
        <div
          key={section.key}
          className={[
            sectionClasses,
            section.className,
            dividers && index > 0 ? sheetLineClasses : ''
          ]
            .filter(Boolean)
            .join(' ')}
        >
          {section.content}
        </div>
      ))
    }
  });
});
