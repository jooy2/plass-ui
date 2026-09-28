'use client';

/**
 * The label in the field's own top edge — `labelPlacement="notch"`, and the
 * `float` that rests inside the field until it is wanted there.
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
 *
 * **A `float` label is the same legend.** It comes down into the field by its
 * own position and font size, and the legend folds to nothing under it so the
 * edge closes over where the gap was. What decides that it rests is a relation
 * between the frame's focus, the control's emptiness and whether a popup is
 * open, which is plain CSS in `styles.css` under "The float label" rather than
 * a state this component holds: an input says it is empty through
 * `:placeholder-shown` before any script has run, and so does a select's
 * trigger through `data-placeholder`. This file hands that stylesheet its
 * numbers and its hooks.
 */

import * as React from 'react';
import { cx, hasContent, metaTextClasses, radiusClasses, transitionClasses } from './styles.js';
import type { PlassDensity, PlassFieldLabelPlacement, PlassSize, PlassVariant } from '../types.js';

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
 *
 * Less `--p-notch-grow`, which is how much thicker than the hairline the edge
 * is drawn at that moment. A legend is laid out from the inside of its
 * fieldset's border, so the pixel focus adds to the edge would otherwise push
 * the label a pixel along with it, and the name would shift each time the
 * field took or lost the focus.
 */
const insetClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: {
    xs: 'ms-[calc(0.5rem_-_var(--p-notch-grow,0px))]',
    sm: 'ms-[calc(0.625rem_-_var(--p-notch-grow,0px))]',
    md: 'ms-[calc(0.75rem_-_var(--p-notch-grow,0px))]',
    lg: 'ms-[calc(1.25rem_-_var(--p-notch-grow,0px))]',
    xl: 'ms-[calc(1.5rem_-_var(--p-notch-grow,0px))]'
  },
  compact: {
    xs: 'ms-[calc(0.5rem_-_var(--p-notch-grow,0px))]',
    sm: 'ms-[calc(0.625rem_-_var(--p-notch-grow,0px))]',
    md: 'ms-[calc(0.75rem_-_var(--p-notch-grow,0px))]',
    lg: 'ms-[calc(0.875rem_-_var(--p-notch-grow,0px))]',
    xl: 'ms-[calc(1rem_-_var(--p-notch-grow,0px))]'
  }
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
 * What the stylesheet lays a `float` label out with, per size.
 *
 * - `--p-notch-pad` is `padClasses` as a length. A floating legend carries it
 *   as the label's margin rather than as its own padding, because the legend
 *   folds to nothing while the label rests, and padding is the one part of a
 *   box that cannot fold.
 * - `--p-notch-leading` is `metaTextClasses` as a length. The label's line
 *   box stays that tall at every font size it passes through, so the legend,
 *   and the edge drawn across its middle, never move while the word grows.
 * - `--p-float-y` is half of `controlHeightClasses`: the middle of the
 *   control's first line, measured from the edge, which is where a single-line
 *   field's text sits and, by the multiline padding, where a textarea's first
 *   row does too.
 * - `--p-float-text` is `controlTextClasses`, the size the value is written in.
 */
const floatClasses: Record<PlassSize, string> = {
  xs: '[--p-notch-pad:0.125rem] [--p-notch-leading:0.625rem] [--p-float-y:0.75rem] [--p-float-text:0.6875rem]',
  sm: '[--p-notch-pad:0.125rem] [--p-notch-leading:0.6875rem] [--p-float-y:1rem] [--p-float-text:0.8125rem]',
  md: '[--p-notch-pad:0.25rem] [--p-notch-leading:0.75rem] [--p-float-y:1.25rem] [--p-float-text:0.875rem]',
  lg: '[--p-notch-pad:0.25rem] [--p-notch-leading:0.8125rem] [--p-float-y:1.5rem] [--p-float-text:1rem]',
  xl: '[--p-notch-pad:0.25rem] [--p-notch-leading:0.875rem] [--p-float-y:1.75rem] [--p-float-text:1.125rem]'
};

/**
 * How far a resting label moves along from where it sits on the edge, so that
 * it starts where the value does: `paddingXClasses - insetClasses -
 * padClasses`. Nothing on the default track, where the inset was worked out
 * from the padding in the first place; a little back towards the start on the
 * compact one, where the corner pushed the notch past the text.
 */
const floatShiftClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: '', sm: '', md: '', lg: '', xl: '' },
  compact: {
    xs: '[--p-float-x:-0.25rem]',
    sm: '[--p-float-x:-0.25rem]',
    md: '[--p-float-x:-0.375rem]',
    lg: '[--p-float-x:-0.25rem]',
    xl: '[--p-float-x:-0.25rem]'
  }
};

/**
 * The hook a resting label reads the control's emptiness through, on the
 * element that has one to give: an `<input>`, whose `:placeholder-shown` says
 * so, or a select's trigger, whose `data-placeholder` does. An input with no
 * placeholder of its own is given a blank one, since `:placeholder-shown`
 * never matches an input that has none.
 */
export const floatControlClassName = 'plass-float-control';

/**
 * What a resting label stands in for, which steps aside while the label is
 * there: the placeholder written in a trigger, a picker's words for nothing
 * chosen. An input's own placeholder is reached through the control's
 * `::placeholder` instead.
 */
export const floatPlaceholderClassName = 'plass-float-placeholder';

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
 *
 * The extra pixel is also written to `--p-notch-grow`, which the legend's
 * inset takes back off, so the edge thickens inward and the label stays where
 * it was.
 */
const edgeFocusClasses = /* @__PURE__ */ [
  'group-has-[:focus-visible]/field:[border-width:2px]',
  'group-has-[:focus-visible]/field:[--p-notch-grow:1px]',
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

/**
 * What a control's `labelPlacement` comes to once its label and its start are
 * known.
 *
 * `notched` is whether the edge is cut at all: for `notch` and for `float`, and
 * only where there is a label, since a notch with nothing in it is a gap in the
 * edge for no reason. `float` is whether the label may also come down into the
 * control, which it cannot where the control draws something at its start —
 * `startTaken` — because that is where it would rest.
 */
export function resolveNotch(
  placement: PlassFieldLabelPlacement,
  label: React.ReactNode,
  startTaken: boolean
): { notched: boolean; float: boolean } {
  const notched = placement !== 'top' && hasContent(label);

  return { notched, float: notched && placement === 'float' && !startTaken };
}

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
   * The label comes down into the control while it is empty and idle —
   * `labelPlacement="float"` on a control with nothing drawn at its start.
   * The caller decides both halves of that, since only it knows what its start
   * holds, and passes `notched` as well: a floating label is in the notch for
   * as long as it is not resting.
   */
  float?: boolean;
  /**
   * Whether the control holds nothing, from a component that knows and has no
   * control that can say so itself — a picker's trigger. Left out, the control
   * marked with `floatControlClassName` says it.
   */
  empty?: boolean;
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
  float = false,
  empty,
  label,
  children
}: FieldNotchProps) {
  if (!notched) {
    return <>{children}</>;
  }

  return (
    <div
      className={cx(
        'group/field relative flex w-full',
        riseGapClasses[size],
        float && `plass-notch-float ${floatClasses[size]} ${floatShiftClasses[density][size]}`
      )}
      data-empty={(float && empty) || undefined}
    >
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
            // A floating legend carries its air on the label instead, and none
            // of its own — not even the 2px the browser gives every legend —
            // or it could not fold to nothing. See `floatClasses`.
            float ? 'px-0' : padClasses[size],
            disabled ? 'text-(--plass-muted-fg)' : 'text-(--plass-fg)'
          )}
        >
          {label}
        </legend>
      </fieldset>
    </div>
  );
}
