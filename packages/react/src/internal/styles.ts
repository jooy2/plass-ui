/**
 * The pieces every Plass component is built out of.
 *
 * None of this is exported from `src/index.ts` — it is the library talking to
 * itself. It lives here for one reason: a `size` of `md` has to be 40px on a
 * PlButton, a PlTextField, a Select and a Chip, and a table copied into eleven
 * files is a table that will disagree with itself by the twelfth.
 *
 * The two things that cannot move out of a component are its variant classes
 * and its layout — those genuinely differ. Heights, radii, type scale, padding
 * tracks, the glass surface, the transition and the colour slots do not.
 *
 * Tailwind only sees class names written out literally, so everything here is a
 * complete class string rather than something assembled at runtime. `@source
 * '.'` in `styles.css` covers this folder in the repository and in `dist/`.
 */

import type * as React from 'react';
import type {
  PlassColor,
  PlassDensity,
  PlassElevation,
  PlassSize,
  PlassVariant
} from '../types.js';

/* ---------------------------------------------------------------------------
 * Scales
 * ------------------------------------------------------------------------- */

/**
 * Corner radius — a moulded fillet rather than a chamfer or a pill.
 *
 * It grows far more slowly than the height does: 33% of an `xs` control, 29% at
 * `md`, 29% at `xl`. That near-constant radius is what makes two controls of
 * different sizes read as two pieces cast in the same mould, which a radius
 * pinned to a percentage of the height does not.
 */
export const radiusClasses: Record<PlassSize, string> = {
  xs: 'rounded-(--plass-radius-xs)',
  sm: 'rounded-(--plass-radius-sm)',
  md: 'rounded-(--plass-radius-md)',
  lg: 'rounded-(--plass-radius-lg)',
  xl: 'rounded-(--plass-radius-xl)'
};

/**
 * The height of a control, and the one number the whole library lines up on:
 * a PlButton, a PlTextField, a Select and a Chip of the same `size` sit on the same
 * baseline in the same row.
 *
 * The ladder is 8px per step, and it starts higher than a dense desktop toolkit
 * would: `md` is 40px, not 32px. A moulded surface needs room to be one — a
 * gradient, a specular highlight and a hairline inside 32px is three effects
 * fighting over eleven pixels of fill. `xs` exists for a table row and is the
 * one step where the gloss is deliberately faint.
 *
 * `lg` at 48px and `xl` at 56px both clear the 44px mobile touch target.
 *
 * Density never touches these.
 */
export const controlHeightClasses: Record<PlassSize, string> = {
  xs: 'h-6',
  sm: 'h-8',
  md: 'h-10',
  lg: 'h-12',
  xl: 'h-14'
};

/** The same numbers as a width, for a control with nothing to pad against. */
export const controlSquareClasses: Record<PlassSize, string> = {
  xs: 'w-6',
  sm: 'w-8',
  md: 'w-10',
  lg: 'w-12',
  xl: 'w-14'
};

/** A control's label. One line, so the leading comes from `leading-none`. */
export const controlTextClasses: Record<PlassSize, string> = {
  xs: 'text-[0.6875rem]',
  sm: 'text-[0.8125rem]',
  md: 'text-[0.875rem]',
  lg: 'text-[1rem]',
  xl: 'text-[1.125rem]'
};

/**
 * The same type scale with an explicit leading, for the controls that hold text
 * which may wrap — a textarea, a select option, a table cell. The line heights
 * have to agree with `controlHeightClasses` or a one-row control would stop
 * lining up with a single-line one.
 */
export const controlTextLeadingClasses: Record<PlassSize, string> = {
  xs: 'text-[0.6875rem]/[1rem]',
  sm: 'text-[0.8125rem]/[1.125rem]',
  md: 'text-[0.875rem]/[1.25rem]',
  lg: 'text-[1rem]/[1.5rem]',
  xl: 'text-[1.125rem]/[1.75rem]'
};

/** Labels, descriptions and error messages: one step below the control's text. */
export const metaTextClasses: Record<PlassSize, string> = {
  xs: 'text-[0.625rem]',
  sm: 'text-[0.6875rem]',
  md: 'text-[0.75rem]',
  lg: 'text-[0.8125rem]',
  xl: 'text-[0.875rem]'
};

/**
 * Horizontal padding, and the only thing `density` is allowed to touch. The two
 * tracks are roughly 2:1 so the difference is legible at a glance rather than a
 * two-pixel nudge.
 */
export const paddingXClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'px-2.5', sm: 'px-3', md: 'px-4', lg: 'px-6', xl: 'px-7' },
  compact: { xs: 'px-1.5', sm: 'px-2', md: 'px-2.5', lg: 'px-3.5', xl: 'px-4' }
};

/**
 * A standalone glyph's box: 14, 16, 20, 24 and 28px.
 *
 * Its own ladder rather than a step off `controlHeightClasses`, because an icon
 * is not a control — it is content, and it is measured against the text it sits
 * beside rather than against the row it sits in.
 *
 * `iconClasses` is the other half of the same idea and is not this: that one
 * sizes a glyph *inside* a control, in `em`, so it tracks the label it belongs
 * to. This one is for the glyph that is the whole object.
 */
export const iconSizeClasses: Record<PlassSize, string> = {
  xs: 'size-3.5',
  sm: 'size-4',
  md: 'size-5',
  lg: 'size-6',
  xl: 'size-7'
};

/**
 * A tick box: the square a PlCheckbox draws and the circle a PlRadioGroup draws.
 *
 * Its own ladder rather than a step off `controlHeightClasses`, because a tick
 * is not a control you can put a label inside — it is an indicator next to one,
 * and it is sized against the text beside it rather than against the row.
 */
export const tickSizeClasses: Record<PlassSize, string> = {
  xs: 'size-3.5',
  sm: 'size-4',
  md: 'size-4.5',
  lg: 'size-5',
  xl: 'size-6'
};

/**
 * And its own radius, well below the control ladder's.
 *
 * `--plass-radius-md` is 12px, which on an 18px box is most of the way to a
 * circle — and a checkbox that is round is a radio button. The intent is the
 * same fillet as everywhere else, measured against a much smaller object.
 */
export const tickRadiusClasses: Record<PlassSize, string> = {
  xs: 'rounded-[0.25rem]',
  sm: 'rounded-[0.3125rem]',
  md: 'rounded-[0.375rem]',
  lg: 'rounded-[0.4375rem]',
  xl: 'rounded-[0.5rem]'
};

/**
 * The dot inside a checked radio.
 *
 * Whole pixels at every step rather than a percentage of the ring around it —
 * and, which is the half that was missing, whole pixels *of margin* as well.
 * A diameter can be an exact 7px and still be centred at x.5, because what
 * decides the offset is `(box − border − border − dot) / 2`: a 7px dot inside
 * an 18px ring with a 1px edge sits 4.5px from each side, and a circle whose
 * four sides are antialiased at half coverage reads as "the dot is not
 * centred" even though the box says it is — and reads as *up and to the left*,
 * because that is the way the paint rounds.
 *
 * So every dot here has the same parity as the ring's content box: 12/6, 14/6,
 * 16/8, 18/8, 22/10. The ratio wanders between 38% and 44% as a result, which
 * is the price, and it is invisible next to the thing it buys.
 */
export const tickDotClasses: Record<PlassSize, string> = {
  xs: 'size-1.5',
  sm: 'size-1.5',
  md: 'size-2',
  lg: 'size-2',
  xl: 'size-2.5'
};

/**
 * The line box a tick and its label share.
 *
 * Both the tick's wrapper and the label are measured against it: the wrapper is
 * `h-[1lh]` so the box centres on the label's *first* line rather than on the
 * whole block, and that only lines up if the two agree on what a line is. Left
 * to inherit, `1lh` picks up whatever leading the host page happens to set and
 * the tick drifts a pixel or two off the text beside it.
 *
 * It is `controlTextLeadingClasses` and not a ratio of its own, and that is the
 * whole point of it having moved: a ratio produces a fractional line box at
 * every step but one — 14px of text at 1.4 is a 19.6px line — and an 18px tick
 * centred in 19.6px starts at 0.8px, which drags the ring, its edge and the dot
 * inside it off the pixel grid together. The table's line boxes are whole
 * numbers with the same parity as the ticks that sit in them (16/14, 18/16,
 * 20/18, 24/20, 28/24), so every one of those offsets is a whole pixel.
 *
 * The label needs no leading of its own; it inherits this one, which is the
 * only way the two can be guaranteed to agree.
 */
export const tickRowTextClasses = controlTextLeadingClasses;

/**
 * The same two tracks again, as raw lengths.
 *
 * These exist for one element: a table cell. `<td>` and `<th>` are among the
 * very few tags that host stylesheets still style by name — VitePress's
 * `.vp-doc td`, Tailwind Typography's `.prose td`, every CSS framework ever —
 * and all of those are two-class selectors that a one-class utility cannot
 * outrank. A table therefore writes its cell padding inline, where nothing can
 * reach it.
 *
 * Keep these in step with `paddingXClasses`. They are the same numbers: the
 * Tailwind spacing scale is 0.25rem per step.
 */
export const paddingXValues: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: '0.625rem', sm: '0.75rem', md: '1rem', lg: '1.5rem', xl: '1.75rem' },
  compact: { xs: '0.375rem', sm: '0.5rem', md: '0.625rem', lg: '0.875rem', xl: '1rem' }
};

/** Between a control's own parts — an icon and its label. */
export const gapClasses: Record<PlassSize, string> = {
  xs: 'gap-1',
  sm: 'gap-1.5',
  md: 'gap-2',
  lg: 'gap-2.5',
  xl: 'gap-3'
};

/** Between a label, the control under it and the text under that. */
export const stackGapClasses: Record<PlassSize, string> = {
  xs: 'gap-1',
  sm: 'gap-1.5',
  md: 'gap-1.5',
  lg: 'gap-2',
  xl: 'gap-2'
};

/* ---------------------------------------------------------------------------
 * Sheets
 *
 * A control holds one line of text at a fixed height, which is what every
 * ladder above is about. A *sheet* — a Card, an Accordion section, an Alert, a
 * Modal — holds a heading, a paragraph and a footer, and all three of them
 * wrap. That is a different problem, and these tables are its answer.
 *
 * A sheet's subtitle deliberately has no table of its own: it is
 * `metaTextClasses`, the same step below the body that a field's description
 * sits on.
 * ------------------------------------------------------------------------- */

/**
 * A sheet's own padding, which is not a control's.
 *
 * `paddingXClasses` is the room a label needs beside the edge of the key it is
 * printed on. This is the margin a sheet keeps around whatever it is holding,
 * and it is bigger, because the thing inside is a paragraph rather than a word.
 * Both axes are offered separately: a sheet with hairlines between its sections
 * gives its vertical padding away to them.
 */
export const sheetPaddingXClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'px-2.5', sm: 'px-3.5', md: 'px-5', lg: 'px-6', xl: 'px-7' },
  compact: { xs: 'px-2', sm: 'px-2.5', md: 'px-3.5', lg: 'px-4', xl: 'px-5' }
};

export const sheetPaddingYClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'py-2.5', sm: 'py-3.5', md: 'py-5', lg: 'py-6', xl: 'py-7' },
  compact: { xs: 'py-2', sm: 'py-2.5', md: 'py-3.5', lg: 'py-4', xl: 'py-5' }
};

/**
 * A sheet's heading: one step above the body, on the same ladder the controls
 * use, so a card's title lines up with the buttons that end up inside it.
 */
export const sheetTitleClasses: Record<PlassSize, string> = {
  xs: 'text-[0.75rem]/[1rem]',
  sm: 'text-[0.8125rem]/[1.125rem]',
  md: 'text-[0.9375rem]/[1.25rem]',
  lg: 'text-[1.0625rem]/[1.5rem]',
  xl: 'text-[1.25rem]/[1.75rem]'
};

/**
 * Body copy: the control type scale with the leading opened up, because a
 * label is one line and a body is a paragraph.
 */
export const sheetBodyClasses: Record<PlassSize, string> = {
  xs: 'text-[0.6875rem]/[1rem]',
  sm: 'text-[0.75rem]/[1.125rem]',
  md: 'text-[0.8125rem]/[1.375rem]',
  lg: 'text-[0.9375rem]/[1.5rem]',
  xl: 'text-[1.0625rem]/[1.75rem]'
};

/** Between a sheet's sections, when there are no hairlines to separate them. */
export const sheetSectionGapClasses: Record<PlassSize, string> = {
  xs: 'gap-1.5',
  sm: 'gap-2',
  md: 'gap-3',
  lg: 'gap-3.5',
  xl: 'gap-4'
};

/**
 * The hairline that scores a sheet into sections — a card's body from its
 * footer, one accordion fold from the next, one table row from the next.
 *
 * `--plass-divider` and **not** the `--plass-glass-line` the sheet's own edge is
 * drawn in, which is what this used to be. The edge line is white light caught
 * on a cut edge, and it reads because what is behind it is the page wash. The
 * same white laid *across* the middle of the sheet has the sheet behind it
 * instead, and a white line on a 62%-white pane over a near-white page is not a
 * line — which is why a light-mode list, card or table had no visible structure
 * at all unless the host page happened to be drawing its own.
 */
export const sheetLineClasses = 'border-t [border-color:var(--plass-divider)]';

/** Title to subtitle. Tight — they are one block of text, not two sections. */
export const sheetHeaderGapClasses: Record<PlassSize, string> = {
  xs: 'gap-0.5',
  sm: 'gap-0.5',
  md: 'gap-1',
  lg: 'gap-1',
  xl: 'gap-1.5'
};

/* ---------------------------------------------------------------------------
 * Surface
 * ------------------------------------------------------------------------- */

/**
 * Glass: a translucent fill over a heavily blurred backdrop.
 *
 * The blur is the whole material. Plass is not trying to let you read what is
 * behind a sheet — it is trying to make the sheet look thick, which is why the
 * radius is 22px and not the 8–10px a frosted-acrylic language would use.
 * Below about 14px the surface stops being glass and becomes a white box with
 * an alpha on it.
 *
 * `-webkit-backdrop-filter` is written alongside the standard property because
 * Safari still needs it, and Tailwind will not add it for an arbitrary value.
 */
export const glassClasses =
  '[backdrop-filter:var(--plass-blur)] [-webkit-backdrop-filter:var(--plass-blur)]';

/**
 * The house transition.
 *
 * One duration and one curve, applied the same way in both directions — a key
 * going down and a key coming back up are the same spring. `background-image`
 * is in the list because a gradient fill is the thing being changed on a solid
 * surface, and `filter` because that is what hover and press actually move.
 *
 * There is no `transform` in the list and none should be added to a *control*:
 * scaling a key resamples its label, and text that shimmers under the cursor
 * undoes the restraint everything else is spending effort on. A surface that
 * holds content rather than being pressed — a Card — may lift, and does.
 */
export const transitionClasses = [
  '[transition-property:background-color,background-image,border-color,box-shadow,color,filter]',
  '[transition-duration:var(--plass-duration)]',
  '[transition-timing-function:var(--plass-ease)]'
].join(' ');

/**
 * The focus ring, written as the `outline` shorthand rather than Tailwind's
 * `outline-2` + colour pair: the utilities route the style through
 * `--tw-outline-style`, which any `outline-none` on the element (ours or a
 * consumer's) would zero out.
 *
 * An `outline` and not a `ring`, which is the other way this could be drawn:
 * Tailwind's `ring-*` is a `box-shadow`, and every Plass surface already spends
 * its `box-shadow` on the elevation, the tinted glow and the gloss line. A ring
 * would have to be spliced into that chain in each of the three variants, and
 * the first one that forgot would silently lose its focus ring.
 *
 * **It is flush.** The offset used to be 2px, and a 2px gap is the one thing a
 * ring must not have on a control that already draws an edge of its own: a
 * field, a select, a tick, a switch. The eye reads the field's hairline, then a
 * band of page, then the ring — three concentric rectangles where there is one
 * object, and the control looks as though it has come loose from the ring
 * around it. At offset 0 the outline sits directly on the outside of the edge
 * and the edge simply thickens and takes the family's colour, which is what
 * "this one is focused" should look like.
 *
 * Nothing is lost on a control with no edge either: the outline is still drawn
 * entirely *outside* the border box, so on a filled key it is a rim against the
 * page rather than a band over the fill.
 */
export const focusRingClasses =
  'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:[outline-offset:0px]';

/** The same ring, drawn by whichever descendant actually takes focus. */
export const focusWithinRingClasses =
  'has-[:focus-visible]:[outline:2px_solid_var(--p-ring)] has-[:focus-visible]:[outline-offset:0px]';

/**
 * The same ring again, turned inward.
 *
 * For an element that is *inside* something that clips — a segment in a
 * groove, a tab on a rail, a row in a sheet with rounded corners, an accordion
 * header in a scored pane. A ring drawn outside those is a ring with its top or
 * its bottom sliced off by the container's own overflow, so it is drawn just
 * inside the edge instead. Same width, same colour, same absence of a gap.
 */
export const focusRingInsetClasses =
  'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:[outline-offset:-2px]';

/** Icons track their label rather than carrying a size of their own. */
export const iconClasses = '[&_svg]:pointer-events-none [&_svg]:size-[1.2em] [&_svg]:shrink-0';

/**
 * Text for a screen reader and nobody else.
 *
 * Not `hidden`, not `display:none` and not `opacity:0` — the first two take the
 * text off the accessibility tree along with the screen, and the third leaves a
 * clickable ghost the size of the words. A 1px clipped box is the one form that
 * is invisible to a sighted reader and present to every other kind.
 */
export const srOnlyClasses =
  'absolute size-px overflow-hidden whitespace-nowrap [clip-path:inset(50%)]';

/* ---------------------------------------------------------------------------
 * Colour slots
 *
 * These are inline styles rather than Tailwind arbitrary properties on purpose:
 * Tailwind only sees class names that appear literally in the source, so the
 * alternative is one hardcoded `[--p-fill:var(--plass-primary-fill)]` per
 * family per component. Generating the slots keeps adding a colour family down
 * to one entry in `PlassColor` plus its tokens in `styles.css`.
 * ------------------------------------------------------------------------- */

/**
 * The tinted lift — the shadow a control casts in its own colour, and the
 * single loudest thing in the design language.
 *
 * It is deliberately **not** part of the elevation ladder, and it does not
 * scale with `elevation`. Elevation says how far a surface is off the page;
 * this says what the surface is made of, and a `danger` button one step higher
 * is not a redder piece of glass. The two are composed in the same `box-shadow`
 * and each one moves on its own.
 *
 * It reads `--p-tint` and not `--p-glow`: the tint is the family colour bleeding
 * into a shadow *under* the control, the glow is the light that arrives *on* it
 * with the pointer. Two different lights, two different slots.
 */
const lift = '0 6px 16px -4px var(--p-tint)';
const liftHover = '0 10px 24px -6px var(--p-tint)';
/* Pressed, the control is against the sheet and its tint has nowhere to fall. */
const liftPress = '0 2px 6px -2px var(--p-tint)';

/**
 * Every slot a control reads.
 *
 * The three elevation slots are resolved here rather than in CSS because
 * hovering adds a level and pressing removes one, and doing that arithmetic in
 * a stylesheet would mean four ladders instead of one.
 *
 * `variant` is taken for one reason: the two interaction-light slots switch
 * with it. Light thrown onto a filled surface is white; onto a tinted or a bare
 * one it has to be the family's own soft tint, or there is nothing for it to
 * show up against.
 */
export function controlSlots(
  color: PlassColor,
  elevation: PlassElevation,
  variant: PlassVariant
): React.CSSProperties {
  const onFill = variant === 'solid';

  return {
    '--p-fill': `var(--plass-${color}-fill)`,
    '--p-on-solid': `var(--plass-${color}-on-solid)`,
    '--p-accent': `var(--plass-${color}-accent)`,
    '--p-tint': `var(--plass-${color}-tint)`,
    '--p-soft': `var(--plass-${color}-soft)`,
    '--p-soft-hover': `var(--plass-${color}-soft-hover)`,
    '--p-soft-press': `var(--plass-${color}-soft-press)`,
    '--p-line': `var(--plass-${color}-line)`,
    '--p-line-hover': `var(--plass-${color}-line-hover)`,
    '--p-ring': `var(--plass-${color}-ring)`,
    '--p-glow': onFill ? 'var(--plass-glow-on-fill)' : `var(--plass-${color}-soft)`,
    '--p-flash': onFill ? 'var(--plass-flash-on-fill)' : `var(--plass-${color}-soft-hover)`,
    '--p-elev': `var(--plass-shadow-${elevation})`,
    '--p-elev-hover': `var(--plass-shadow-${Math.min(elevation + 1, 4)})`,
    '--p-elev-press': `var(--plass-shadow-${Math.max(elevation - 1, 0)})`,
    '--p-lift': lift,
    '--p-lift-hover': liftHover,
    '--p-lift-press': liftPress
  } as React.CSSProperties;
}

/**
 * The same slots for a surface that **holds** content rather than being
 * pressed: a Box, a Card, a PlTextField's shell, a popup.
 *
 * There is no `--p-fill` and no `--p-lift` here, and that is the point. A
 * container's sheet is the undyed glass, because what it holds arrives with its
 * own colours and tinting the sheet under them puts every one on a background
 * it was not chosen against. The family shows up in the hairline, the focus
 * ring and the caret, and the glass stays clear.
 */
export function surfaceSlots(color: PlassColor, elevation: PlassElevation): React.CSSProperties {
  return {
    '--p-accent': `var(--plass-${color}-accent)`,
    '--p-soft': `var(--plass-${color}-soft)`,
    '--p-soft-hover': `var(--plass-${color}-soft-hover)`,
    '--p-soft-press': `var(--plass-${color}-soft-press)`,
    '--p-line': `var(--plass-${color}-line)`,
    '--p-line-hover': `var(--plass-${color}-line-hover)`,
    '--p-ring': `var(--plass-${color}-ring)`,
    '--p-elev': `var(--plass-shadow-${elevation})`,
    '--p-elev-hover': `var(--plass-shadow-${Math.min(elevation + 1, 4)})`,
    '--p-elev-press': `var(--plass-shadow-${Math.max(elevation - 1, 0)})`
  } as React.CSSProperties;
}

/* ---------------------------------------------------------------------------
 * Shared state treatments
 * ------------------------------------------------------------------------- */

/**
 * Disabled is **the light going out.** The key keeps its shape, its colour and
 * its place in the layout, and stops catching any light: no gloss, no tinted
 * lift, no shadow, most of the saturation gone and half the opacity with it.
 *
 * Opacity is doing real work here rather than standing in for a decision, which
 * is the usual complaint against it. On a page made of translucent sheets, a
 * surface that has gone part-transparent is a surface the page is showing
 * *through* — it has stopped being an object. That reads as unavailable in a
 * way a grey swatch does not, and it is the one state in the library that uses
 * the axis.
 */
export const disabledClasses: Record<PlassVariant, string> = {
  solid: [
    'cursor-not-allowed text-(--p-on-solid) [background-image:var(--p-fill)]',
    'opacity-50 saturate-[0.35] shadow-none'
  ].join(' '),
  glass: [
    glassClasses,
    'cursor-not-allowed border text-(--plass-fg) bg-(--plass-glass)',
    '[border-color:var(--plass-border)]',
    'opacity-50 saturate-[0.35] shadow-none'
  ].join(' '),
  ghost: 'cursor-not-allowed bg-transparent text-(--p-accent) opacity-50 saturate-[0.35]'
};

/**
 * Read-only keeps the colour and the edge, goes flat and drains most of the
 * saturation — a label that happens to be control-shaped. It is not dimmed:
 * the value is still there to be read and copied, which is the whole difference
 * from `disabled`.
 *
 * The cursor is left to the component. A read-only button stops being something
 * you click; a read-only field is still something you select text out of.
 */
export const readOnlyFilterClasses = 'saturate-[0.55]';

/**
 * The sheet a **container** is drawn on — a PlCard, a PlAccordion, a PlTable, a
 * PlModal's panel. Everything that holds other people's content rather than
 * being pressed.
 *
 * The three variants say what they say everywhere else, read as a *material*
 * rather than as an appearance, and the ladder between them is opacity:
 *
 * - `solid` — the clear glass at its most opaque. The sheet you cannot see the
 *   page through, for a panel that has to sit forward of everything around it.
 *   No border, because a slab that dense has no edge left to catch light on.
 * - `glass` — the canonical Plass sheet, and the default on every container:
 *   translucent, blurred, a white hairline round it and the light lying along
 *   its top edge.
 * - `ghost` — no sheet at all. For a container inside a container, where a
 *   second bordered rectangle is a second rectangle.
 *
 * None of the three is dyed, and there is no `--p-fill` in `surfaceSlots` to
 * dye them with. What a container holds arrives with its own colours; the
 * family reaches the hairline, the focus ring and the caret and stops.
 */
export const sheetRestClasses: Record<PlassVariant, string> = {
  solid: [
    glassClasses,
    'text-(--plass-fg) bg-(--plass-glass-press)',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  glass: [
    glassClasses,
    'border text-(--plass-fg) bg-(--plass-glass)',
    '[border-color:var(--plass-glass-line)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: 'text-(--plass-fg) bg-transparent'
};

/**
 * The shell a field-shaped control is drawn on — a PlTextField's box and a
 * Select's trigger, which have to be indistinguishable or a form looks like two
 * different forms stacked on each other.
 *
 * The three variants say what they say everywhere else, with one deliberate
 * difference: `solid` is not a moulded key. What a field holds is user data,
 * and a caret, a text selection and a placeholder all have to stay legible on
 * top of it, which they are not on a gradient fill. So a `solid` field is the
 * **well** — the glass at its most opaque with an inset shadow falling into it,
 * the one shadow in the library that points downward — and the colour family
 * shows up in the hairline, the ring and the caret instead.
 *
 * The edge is `--plass-border` and not the sheet's own `--plass-glass-line`,
 * which is the same correction a PlCheckbox's tick, a PlRadio's ring and a
 * PlTabs rail already carry, made for the third time and for the last: white
 * light on a cut edge is a claim about the page wash behind the pane, and a
 * field is very often *not* on the page — it is on a card, and a white hairline
 * round a 76%-white box on a white card is a field a reader cannot see the
 * shape of. A neutral hairline reads on both, and it means every edge on a form
 * — the tick beside the field, the switch under it, the rail over it — is one
 * line rather than two kinds of line that only agree on one background.
 */
export const fieldRestClasses: Record<PlassVariant, string> = {
  solid: [
    glassClasses,
    'text-(--plass-fg) bg-(--plass-glass-press)',
    '[box-shadow:var(--p-elev),var(--plass-well)]',
    'hover:bg-(--plass-glass-hover)',
    'focus-within:bg-(--plass-glass-press)'
  ].join(' '),
  glass: [
    glassClasses,
    'border text-(--plass-fg) bg-(--plass-glass-hover)',
    '[border-color:var(--plass-border)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]',
    'hover:bg-(--plass-glass-press) hover:[border-color:var(--p-line)]',
    'focus-within:bg-(--plass-glass-press) focus-within:[border-color:var(--p-line-hover)]'
  ].join(' '),
  // No surface until it is wanted — the field in a table cell that only looks
  // like a field once you go near it.
  ghost: [
    'text-(--plass-fg) bg-transparent',
    'hover:bg-(--p-soft)',
    'focus-within:bg-(--p-soft-hover)'
  ].join(' ')
};

/** The same three, held still. */
export const fieldReadOnlyClasses: Record<PlassVariant, string> = {
  solid: [
    glassClasses,
    'text-(--plass-fg) bg-(--plass-glass-press)',
    `[box-shadow:var(--plass-well)] ${readOnlyFilterClasses}`
  ].join(' '),
  glass: [
    glassClasses,
    'border text-(--plass-fg) bg-(--plass-glass-hover)',
    '[border-color:var(--plass-border)]',
    `[box-shadow:var(--plass-gloss-glass)] ${readOnlyFilterClasses}`
  ].join(' '),
  ghost: `text-(--plass-fg) bg-transparent ${readOnlyFilterClasses}`
};

/** `false`, `null`, `undefined` and `''` all mean "this slot is not filled". */
export function hasContent(node: React.ReactNode): boolean {
  return node !== undefined && node !== null && node !== false && node !== '';
}

/** Joins class name fragments, dropping the empty ones. */
export function cx(...parts: Array<string | false | null | undefined>): string {
  return parts.filter(Boolean).join(' ');
}
