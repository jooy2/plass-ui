'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { Checkbox as BaseUICheckbox } from '@base-ui/react/checkbox';
import { Field } from '@base-ui/react/field';
import {
  controlSlots,
  cx,
  focusRingClasses,
  glassClasses,
  hasContent,
  metaTextClasses,
  tickRadiusClasses,
  tickRowTextClasses,
  tickSizeClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassFieldClassNames, PlassSize } from '../../types.js';

/**
 * Base UI's own props, minus the ones this component owns: `className` and
 * `style` land on the field wrapper rather than on the tick, and `render` would
 * replace the tick with something that is no longer a checkbox.
 */
type BaseCheckboxProps = Omit<
  React.ComponentPropsWithoutRef<typeof BaseUICheckbox.Root>,
  'className' | 'style' | 'render' | 'children'
>;

export interface PlCheckboxProps extends BaseCheckboxProps {
  /** Classes on the parts a `className` does not reach. */
  classNames?: PlassFieldClassNames;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** The text beside the tick. Wired to it by Base UI's Field. */
  label?: React.ReactNode;
  /** Helper text under the label. */
  description?: React.ReactNode;
  /** Error message below. Its presence also turns the checkbox invalid. */
  error?: React.ReactNode;
  /**
   * Forces the invalid state without a message — for when an external form
   * library owns the validity. Defaults to whether `error` has content.
   */
  invalid?: boolean;
  /** Class names for the field wrapper, not for the tick itself. */
  className?: string;
  style?: React.CSSProperties;
}

/**
 * The tick.
 *
 * Unchecked it is a small pane of clear glass with a hairline round it — the
 * same material a `glass` button is. Checked it fills with the family's
 * gradient, which is the one place this library expresses a state by swapping
 * the whole surface rather than shifting it a step: "on" and "off" are not two
 * strengths of the same thing.
 */
const tickBaseClasses = /* @__PURE__ */ [
  'relative inline-flex shrink-0 items-center justify-center border',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  focusRingClasses
].join(' ');

/**
 * No gloss line on a tick, and no tinted lift under it.
 *
 * `--plass-gloss-glass` is a 1px white edge along the top of a pane. On a 40px
 * button that reads as light catching a cut edge; on an 18px square it is a
 * bevel drawn at a twentieth of the object and it turns into a grey smudge.
 * The tinted lift goes for the same reason from the other direction — a
 * `0 6px 16px` shadow under an 18px box is a shadow bigger than the box.
 *
 * The material stays. It is only the two decorations that go.
 *
 * The edge is `--plass-border` rather than the sheet's own `--plass-glass-line`,
 * and that is not a slip. The glass hairline is white light on a translucent
 * pane, which is invisible the moment the tick is set on a light card rather
 * than on the page wash — and a tick nobody can see is a control nobody can
 * find. A neutral hairline reads on both.
 */
const restClasses = /* @__PURE__ */ [
  glassClasses,
  'cursor-pointer bg-(--plass-glass) [border-color:var(--plass-border)]',
  'hover:bg-(--plass-glass-hover) hover:[border-color:var(--p-line)]',
  // `data-checked` rather than `:checked`: the visible tick is a `<span>`, and
  // the real input is hidden beside it.
  'data-[checked]:[background-image:var(--p-fill)] data-[checked]:text-(--p-on-solid)',
  'data-[checked]:[border-color:transparent] data-[checked]:hover:brightness-105',
  'data-[indeterminate]:[background-image:var(--p-fill)] data-[indeterminate]:text-(--p-on-solid)',
  'data-[indeterminate]:[border-color:transparent]'
].join(' ');

const readOnlyClasses = /* @__PURE__ */ [
  glassClasses,
  'cursor-default bg-(--plass-glass) [border-color:var(--plass-border)]',
  'saturate-[0.55]',
  'data-[checked]:[background-image:var(--p-fill)] data-[checked]:text-(--p-on-solid)',
  'data-[checked]:[border-color:transparent]'
].join(' ');

/** Disabled is the light going out, exactly as it is on a PlButton. */
const disabledTickClasses = /* @__PURE__ */ [
  glassClasses,
  'cursor-not-allowed bg-(--plass-glass) [border-color:var(--plass-border)]',
  'opacity-50 saturate-[0.35]',
  'data-[checked]:[background-image:var(--p-fill)] data-[checked]:text-(--p-on-solid)',
  'data-[checked]:[border-color:transparent]',
  'data-[indeterminate]:[background-image:var(--p-fill)] data-[indeterminate]:text-(--p-on-solid)'
].join(' ');

/**
 * The mark is drawn at 70% of the box, so it never touches the corners.
 *
 * **It draws itself on rather than appearing.** The tick used to arrive whole,
 * on the same frame the box filled, and a glyph that arrives whole is a glyph
 * that was not put there by the click — it reads as a swap. The stroke is dashed
 * at exactly its own length and slid out of view by exactly that, so the state
 * is one number and the change between the two is the pen travelling along the
 * path it will end up occupying. Nothing moves that was not going to be there,
 * and no `transform` is involved, which is the point: this is the way to animate
 * a mark in a library that will not scale one.
 *
 * `pathLength="1"` is what makes it one number rather than a measurement. It
 * renormalises the path to a length of 1 whatever its real geometry is, so the
 * tick and the dash — 11.3 and 7 user units — take the same two classes, and a
 * change to either `d` cannot silently leave the dash the wrong length.
 *
 * The indicator is kept mounted so the mark can travel back out again. Base UI
 * would otherwise unmount it as soon as the box is cleared, and it waits for
 * animations on the indicator itself rather than on the `<path>` inside it, so
 * an exit would be cut off on its first frame.
 */
const markClasses = /* @__PURE__ */ [
  'flex size-[70%] items-center justify-center',
  '[&_path]:[stroke-dasharray:1] [&_path]:[stroke-dashoffset:0]',
  '[&_path]:[transition:stroke-dashoffset_var(--plass-duration)_var(--plass-ease)]',
  'motion-reduce:[&_path]:[transition-duration:0ms]',
  // `data-unchecked` rather than the absence of `data-checked`: an
  // indeterminate box carries neither, and its dash is drawn too.
  'data-[unchecked]:[&_path]:[stroke-dashoffset:1]'
].join(' ');

function CheckMark() {
  return (
    <svg viewBox="0 0 12 12" fill="none" aria-hidden="true" className="size-full">
      <path
        d="M2 6.2 4.6 8.8 10 3.4"
        pathLength={1}
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function DashMark() {
  return (
    <svg viewBox="0 0 12 12" fill="none" aria-hidden="true" className="size-full">
      <path
        d="M2.5 6h7"
        pathLength={1}
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
      />
    </svg>
  );
}

/**
 * A single yes/no, or one member of a set of them.
 *
 * `label`, `description` and `error` are props rather than children for the same
 * reason they are on PlTextField: the arrangement is fixed and what a caller
 * wants to decide is what goes in each slot. `children` is not accepted at all —
 * anything a checkbox has to say belongs in one of the three.
 */
export const PlCheckbox = /* @__PURE__ */ React.forwardRef<HTMLElement, PlCheckboxProps>(
  function PlCheckbox(
    {
      size: sizeProp,
      color: colorProp,
      label,
      description,
      error,
      invalid,
      disabled = false,
      readOnly = false,
      className,
      classNames,
      style,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';

    const hasError = hasContent(error);
    const isInvalid = invalid ?? hasError;
    // Invalid re-points the whole slot family at `danger`, so the tick, the ring
    // and the message all turn over together.
    const family: PlassColor = isInvalid ? 'danger' : color;

    const tickClasses = cx(
      tickBaseClasses,
      tickSizeClasses[size],
      tickRadiusClasses[size],
      // An if/else rather than stacked variants: two Tailwind classes of equal
      // specificity resolve by their order in the generated stylesheet.
      disabled ? disabledTickClasses : readOnly ? readOnlyClasses : restClasses,
      classNames?.control
    );

    return (
      <Field.Root
        disabled={disabled}
        invalid={isInvalid}
        className={['inline-flex flex-col gap-1 align-top', className ?? '']
          .filter(Boolean)
          .join(' ')}
        // `solid`, because a checked tick *is* the coloured thing.
        style={{ ...controlSlots(family, 0, 'solid'), ...style }}
      >
        <div className={`flex items-start gap-2 ${tickRowTextClasses[size]}`}>
          {/* `1lh` centres the tick on the first line of the label rather than on
            the whole block, so it stays put when the label wraps to three. The
            leading is pinned on the row above so `1lh` and the label's own line
            box are the same number. */}
          <span className="flex h-[1lh] shrink-0 items-center">
            <BaseUICheckbox.Root
              ref={ref}
              className={tickClasses}
              disabled={disabled}
              readOnly={readOnly}
              {...props}
            >
              <BaseUICheckbox.Indicator keepMounted className={markClasses}>
                {props.indeterminate ? <DashMark /> : <CheckMark />}
              </BaseUICheckbox.Indicator>
            </BaseUICheckbox.Root>
          </span>

          {label || description ? (
            <span className="flex min-w-0 flex-col gap-0.5">
              {label ? (
                <Field.Label
                  className={cx(
                    disabled ? 'text-(--plass-muted-fg)' : 'cursor-pointer text-(--plass-fg)',
                    classNames?.label
                  )}
                >
                  {label}
                </Field.Label>
              ) : null}
              {description ? (
                <Field.Description
                  className={cx(
                    metaTextClasses[size],
                    'text-(--plass-muted-fg)',
                    classNames?.description
                  )}
                >
                  {description}
                </Field.Description>
              ) : null}
            </span>
          ) : null}
        </div>

        {/* Two branches rather than one, because Base UI's own message is what
            the second is for. With a caller's `error` the box is theirs and
            `match` shows it unconditionally; without one it is left to render
            whatever made the field invalid — the browser's constraint message,
            or a `PlForm`'s `errors` entry for this field's `name`. Passing
            `children` in that case would overwrite the message with nothing,
            and a field that goes red with nothing said is one a reader has to
            guess at. */}
        {hasError ? (
          <Field.Error
            match
            className={cx(metaTextClasses[size], 'text-(--p-accent)', classNames?.error)}
          >
            {error}
          </Field.Error>
        ) : (
          <Field.Error
            className={cx(metaTextClasses[size], 'text-(--p-accent)', classNames?.error)}
          />
        )}
      </Field.Root>
    );
  }
);
