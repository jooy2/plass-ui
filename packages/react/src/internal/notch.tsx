'use client';

/**
 * The label in the field's own top edge — `labelPlacement="notch"`.
 *
 * One module because every field-shaped control in the library draws the same
 * notch: a PlTextField, a PlSelect's trigger, a PlCombobox, a PlNumberField, a
 * PlFilePicker's drop zone and every picker that goes through `internal/picker`
 * have to be indistinguishable along their top edge or a form looks like two
 * forms stacked on each other.
 *
 * **The cut is real.** A `<legend>` takes a segment out of its `<fieldset>`'s
 * border, and that is the only way to open a gap in a line without knowing what
 * is behind it. The usual trick — a label with the page's own background colour
 * painted over the border — cannot work here twice over: a library that does
 * not paint the page has no idea what colour it is, and a Plass field is
 * translucent, so a patch of flat colour would read as a patch of flat colour.
 *
 * **The fieldset is a sibling of the control rather than the control itself.**
 * Half the shells this is drawn on are `<button>`s — a Select's trigger, a file
 * picker's drop zone — and a button cannot contain a fieldset. So the frame
 * below wraps the shell, the shell is drawn exactly as it always was, and the
 * edge is laid over it with its own border. The shell's own border goes
 * transparent for the length of it; `notchShellStyle` is that one declaration,
 * written inline because it has to beat a `hover:` and a `disabled` rule that
 * are already in the class string.
 */

import * as React from 'react';
import { cx, metaTextClasses, radiusClasses, transitionClasses } from './styles.js';
import type { PlassDensity, PlassSize, PlassVariant } from '../types.js';

/**
 * How far the edge is lifted above the control, which is **half the label's
 * line box**: a legend's border is drawn across its own middle, so lifting the
 * frame by half the label puts the cut exactly on the control's top edge.
 *
 * The label is `leading-none`, so its line box is its font size and these are
 * half of `metaTextClasses` — 10, 11, 12, 13 and 14px.
 */
const riseClasses: Record<PlassSize, string> = {
  xs: '-top-[5px]',
  sm: '-top-[5.5px]',
  md: '-top-[6px]',
  lg: '-top-[6.5px]',
  xl: '-top-[7px]'
};

/** The same lift, kept in the layout so the label does not run into whatever is above it. */
const riseGapClasses: Record<PlassSize, string> = {
  xs: 'mt-[5px]',
  sm: 'mt-[5.5px]',
  md: 'mt-[6px]',
  lg: 'mt-[6.5px]',
  xl: 'mt-[7px]'
};

/**
 * Where the cut starts, measured from the control's start edge.
 *
 * `paddingX - padClasses`, so that the label's first letter lands on the same
 * line as the value under it — a name sitting over its own field rather than
 * over the corner. The floor is the corner radius: a notch that starts inside
 * the curve takes a bite out of the arc instead of out of a straight line,
 * which is what pushes the compact track's labels a few pixels past their
 * values at the small end. A corner is not a place a label can go.
 */
const insetClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'ms-2', sm: 'ms-2.5', md: 'ms-3', lg: 'ms-5', xl: 'ms-6' },
  compact: { xs: 'ms-2', sm: 'ms-2.5', md: 'ms-3', lg: 'ms-3.5', xl: 'ms-4' }
};

/** The air either side of the label, inside the cut. Tighter at the two small sizes. */
const padClasses: Record<PlassSize, string> = {
  xs: 'px-0.5',
  sm: 'px-0.5',
  md: 'px-1',
  lg: 'px-1',
  xl: 'px-1'
};

/**
 * The edge the notch is cut into, at rest.
 *
 * Only `glass` has a hairline, which is the whole of the difference: `solid` is
 * a well with no edge to cut and `ghost` has no surface at all, so on those two
 * the label simply rests on the top of the box and nothing is taken out from
 * under it. The alternative — refusing the notch to two of the three variants —
 * would give a form that mixes them two different label baselines.
 *
 * Hover and focus are read off the frame rather than off this element, because
 * the thing being hovered is the control and the edge is only drawing for it.
 */
const edgeRestClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'border border-transparent',
    'group-focus-within/field:[border-color:var(--p-ring)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    'border [border-color:var(--plass-border)]',
    'group-hover/field:[border-color:var(--p-line)]',
    'group-focus-within/field:[border-color:var(--p-ring)]'
  ].join(' '),
  ghost: /* @__PURE__ */ [
    'border border-transparent',
    'group-focus-within/field:[border-color:var(--p-ring)]'
  ].join(' ')
};

/** The same three, held still: read-only keeps the edge and answers nothing. */
const edgeReadOnlyClasses: Record<PlassVariant, string> = {
  solid: 'border border-transparent',
  glass: 'border [border-color:var(--plass-border)]',
  ghost: 'border border-transparent'
};

/**
 * Unavailable, and dimmed to the same degree the shell beside it is — the edge
 * is a sibling of the control rather than a child, so it does not inherit the
 * half-opacity that `disabledClasses` puts on the shell and has to say it.
 */
const edgeDisabledClasses: Record<PlassVariant, string> = {
  solid: 'border border-transparent opacity-50',
  glass: /* @__PURE__ */ [
    'border [border-color:var(--plass-border)] opacity-50',
    'forced-colors:[border-color:GrayText]'
  ].join(' '),
  ghost: 'border border-transparent opacity-50'
};

/**
 * **Focus is the edge thickening, not a ring.**
 *
 * The ring everywhere else in the library is an `outline`, and an outline is a
 * rectangle: on a notched field it would run straight through the label sitting
 * on the edge. So the edge that is already drawn goes to 2px and takes the
 * family's colour, which is what the flush ring was built to look like in the
 * first place — the design language's own words for it are that the edge
 * "simply thickens and takes the family's colour". Here it literally does, and
 * the legend keeps its segment out of it.
 *
 * The width is `:focus-visible` while the colour above is `:focus-within`, so a
 * field that was clicked into reads as active and a field that was tabbed to
 * reads as focused, exactly as the two rules on the shell do today.
 */
const edgeFocusClasses = /* @__PURE__ */ [
  'group-has-[:focus-visible]/field:[border-width:2px]',
  'group-has-[:focus-visible]/field:forced-colors:[border-color:Highlight]'
].join(' ');

/**
 * What the shell gives up while the edge is drawing for it.
 *
 * Inline rather than a class: every field's shell already carries a
 * `border-color` at rest, another on hover, another on focus and another when
 * disabled, and a utility added on top of those would be one more declaration
 * of the same property at the same specificity — whichever of them Tailwind
 * happened to emit last would win. The border itself stays, transparent, so the
 * control's inside is the same size it was.
 */
export const notchShellStyle: React.CSSProperties = { borderColor: 'transparent' };

export interface FieldNotchProps {
  /**
   * Whether to draw one at all. `false` renders the shell and nothing else, so
   * a call site wraps its control once and unconditionally rather than writing
   * the whole thing out twice — which is what keeps the two placements from
   * drifting into two controls.
   */
  notched: boolean;
  size: PlassSize;
  density: PlassDensity;
  variant: PlassVariant;
  /** Unavailable — the edge dims with the control. */
  disabled?: boolean;
  /** Shown but not editable — the edge stays and stops answering. */
  readOnly?: boolean;
  /**
   * The whole edge, when it is not a field's hairline — width, style, colour and
   * every state, replacing the three maps above.
   *
   * A PlFilePicker's drop zone is the one caller that needs it: its edge is 2px
   * and dashed in all three variants, and it has a state no field has, a file
   * being dragged over the box. Passed as one resolved string rather than added
   * to the maps, for the reason every component in this library resolves its own
   * states with an if/else — two utilities for one property at one specificity
   * are settled by the order Tailwind happened to emit them in.
   */
  edgeClassName?: string;
  /**
   * The element that names the control, ready to render: a `Field.Label` for a
   * field that has one, or the `<span>` an `aria-labelledby` points at. The
   * same element the stacked placement renders, so the two cannot drift.
   */
  label: React.ReactNode;
  /** The control's shell, drawn exactly as it is without a notch. */
  children: React.ReactNode;
}

/**
 * Lays the notched edge over a control's shell.
 *
 * The frame is what the edge is positioned against and what hover and focus are
 * read from, so the shell has to be inside it — and the shell is rendered
 * untouched, which is the point: a notch is a decision about the label, not a
 * second way of drawing a field.
 */
export function FieldNotch({
  notched,
  size,
  density,
  variant,
  disabled = false,
  readOnly = false,
  edgeClassName,
  label,
  children
}: FieldNotchProps) {
  if (!notched) {
    return <>{children}</>;
  }

  return (
    <div className={cx('group/field relative flex w-full', riseGapClasses[size])}>
      {children}

      {/* `role="presentation"` because this is a border with a word in it and
          not a group of controls: the fieldset would otherwise put every field
          on the form inside a group of one, and a screen reader would announce
          the label twice — once as the group's name and once as the control's.
          What is inside the legend keeps its own semantics, which is where the
          real label is. */}
      <fieldset
        role="presentation"
        className={cx(
          'pointer-events-none absolute inset-x-0 bottom-0 m-0 min-w-0 p-0',
          riseClasses[size],
          radiusClasses[size],
          transitionClasses,
          edgeClassName ??
            (disabled
              ? edgeDisabledClasses[variant]
              : readOnly
                ? edgeReadOnlyClasses[variant]
                : `${edgeRestClasses[variant]} ${edgeFocusClasses}`)
        )}
      >
        <legend
          className={cx(
            // `pointer-events-auto` puts the label back in reach of a pointer:
            // clicking the name of a field is one of the two ways a person
            // focuses it, and the frame around it is inert on purpose.
            'pointer-events-auto font-semibold leading-none',
            metaTextClasses[size],
            insetClasses[density][size],
            padClasses[size],
            disabled ? 'text-(--plass-muted-fg)' : 'text-(--plass-fg)'
          )}
        >
          {label}
        </legend>
      </fieldset>
    </div>
  );
}
