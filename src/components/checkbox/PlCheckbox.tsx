import * as React from 'react';
import { Checkbox as BaseUICheckbox } from '@base-ui/react/checkbox';
import { Field } from '@base-ui/react/field';
import {
  controlSlots,
  controlTextClasses,
  glassClasses,
  hasContent,
  metaTextClasses,
  tickRadiusClasses,
  tickRowLeadingClasses,
  tickSizeClasses,
  transitionClasses
} from '../../internal/styles';
import type { PlassColor, PlassSize } from '../../types';

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
const tickBaseClasses = [
  'relative inline-flex shrink-0 items-center justify-center border',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:outline-offset-2'
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
const restClasses = [
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

const readOnlyClasses = [
  glassClasses,
  'cursor-default bg-(--plass-glass) [border-color:var(--plass-border)]',
  'saturate-[0.55]',
  'data-[checked]:[background-image:var(--p-fill)] data-[checked]:text-(--p-on-solid)',
  'data-[checked]:[border-color:transparent]'
].join(' ');

/** Disabled is the light going out, exactly as it is on a PlButton. */
const disabledTickClasses = [
  glassClasses,
  'cursor-not-allowed bg-(--plass-glass) [border-color:var(--plass-border)]',
  'opacity-50 saturate-[0.35]',
  'data-[checked]:[background-image:var(--p-fill)] data-[checked]:text-(--p-on-solid)',
  'data-[checked]:[border-color:transparent]',
  'data-[indeterminate]:[background-image:var(--p-fill)] data-[indeterminate]:text-(--p-on-solid)'
].join(' ');

/** The mark is drawn at 70% of the box, so it never touches the corners. */
const markClasses = 'flex size-[70%] items-center justify-center';

function CheckMark() {
  return (
    <svg viewBox="0 0 12 12" fill="none" aria-hidden="true" className="size-full">
      <path
        d="M2 6.2 4.6 8.8 10 3.4"
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
      <path d="M2.5 6h7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
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
export const PlCheckbox = React.forwardRef<HTMLElement, PlCheckboxProps>(function PlCheckbox(
  {
    size = 'md',
    color = 'primary',
    label,
    description,
    error,
    invalid,
    disabled = false,
    readOnly = false,
    className,
    style,
    ...props
  },
  ref
) {
  const hasError = hasContent(error);
  const isInvalid = invalid ?? hasError;
  // Invalid re-points the whole slot family at `danger`, so the tick, the ring
  // and the message all turn over together.
  const family: PlassColor = isInvalid ? 'danger' : color;

  const tickClasses = [
    tickBaseClasses,
    tickSizeClasses[size],
    tickRadiusClasses[size],
    // An if/else rather than stacked variants: two Tailwind classes of equal
    // specificity resolve by their order in the generated stylesheet.
    disabled ? disabledTickClasses : readOnly ? readOnlyClasses : restClasses
  ].join(' ');

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
      <div
        className={`flex items-start gap-2 ${controlTextClasses[size]} ${tickRowLeadingClasses}`}
      >
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
            <BaseUICheckbox.Indicator className={markClasses}>
              {props.indeterminate ? <DashMark /> : <CheckMark />}
            </BaseUICheckbox.Indicator>
          </BaseUICheckbox.Root>
        </span>

        {label || description ? (
          <span className="flex min-w-0 flex-col gap-0.5">
            {label ? (
              <Field.Label
                className={[
                  'leading-[1.4]',
                  disabled ? 'text-(--plass-muted-fg)' : 'cursor-pointer text-(--plass-fg)'
                ].join(' ')}
              >
                {label}
              </Field.Label>
            ) : null}
            {description ? (
              <Field.Description className={`${metaTextClasses[size]} text-(--plass-muted-fg)`}>
                {description}
              </Field.Description>
            ) : null}
          </span>
        ) : null}
      </div>

      {hasError ? (
        <Field.Error match className={`${metaTextClasses[size]} text-(--p-accent)`}>
          {error}
        </Field.Error>
      ) : null}
    </Field.Root>
  );
});
