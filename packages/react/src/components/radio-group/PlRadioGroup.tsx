'use client';

import * as React from 'react';
import { Radio as BaseUIRadio } from '@base-ui/react/radio';
import { RadioGroup as BaseUIRadioGroup } from '@base-ui/react/radio-group';
import { Field } from '@base-ui/react/field';
import {
  controlSlots,
  cx,
  focusRingClasses,
  glassClasses,
  hasContent,
  metaTextClasses,
  tickDotClasses,
  tickRowTextClasses,
  tickSizeClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassFieldClassNames, PlassOrientation, PlassSize } from '../../types.js';

/**
 * What a `PlRadio` inherits from the group around it.
 *
 * A radio button is meaningless alone — it only says anything relative to its
 * siblings — so `size`, `color` and the read-only state belong to the set, not
 * to the member. Passing them on every `<PlRadio>` would be four chances to get
 * one of them wrong.
 */
interface RadioGroupContextValue {
  size: PlassSize;
  color: PlassColor;
  readOnly: boolean;
}

const RadioGroupContext = /* @__PURE__ */ React.createContext<RadioGroupContextValue>({
  size: 'md',
  color: 'primary',
  readOnly: false
});

export interface PlRadioGroupProps extends Omit<
  React.ComponentPropsWithoutRef<typeof BaseUIRadioGroup>,
  'className' | 'style' | 'render'
> {
  /** Classes on the parts a `className` does not reach. */
  classNames?: PlassFieldClassNames;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /**
   * Which way the options stack. Vertical by default — a column of options is
   * scannable at any length, and a row silently becomes unreadable the moment
   * one label is longer than expected.
   * @default 'vertical'
   */
  orientation?: PlassOrientation;
  /** The question the options answer. Rendered as the group's label. */
  label?: React.ReactNode;
  /** Helper text under the label. */
  description?: React.ReactNode;
  /** Error message below the options. Its presence also turns the group invalid. */
  error?: React.ReactNode;
  /**
   * Forces the invalid state without a message — for when an external form
   * library owns the validity. Defaults to whether `error` has content.
   */
  invalid?: boolean;
  className?: string;
  style?: React.CSSProperties;
}

export interface PlRadioProps extends Omit<
  React.ComponentPropsWithoutRef<typeof BaseUIRadio.Root>,
  'className' | 'style' | 'render' | 'children'
> {
  /** The text beside the dot. Wired to it by Base UI's Field. */
  label?: React.ReactNode;
  /** Helper text under the label. */
  description?: React.ReactNode;
  className?: string;
  style?: React.CSSProperties;
}

/**
 * The dot. Round, and one of the two things in the library allowed to be —
 * roundness is exactly what tells a reader "one of these" rather than "any of
 * these", and it is the one convention old enough that breaking it would cost
 * more than it bought.
 */
const dotBaseClasses = /* @__PURE__ */ [
  'relative inline-flex shrink-0 items-center justify-center rounded-full border',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  focusRingClasses
].join(' ');

/**
 * No gloss line and no tinted lift, for the reason a PlCheckbox's tick has
 * neither: a 1px white edge is light on a cut edge at 40px and a grey smudge at
 * 18px, and a `0 6px 16px` shadow under an 18px circle is bigger than the
 * circle. The glass stays; only the two decorations go.
 *
 * The edge is `--plass-border` rather than the sheet's own `--plass-glass-line`,
 * and that is not a slip. The glass hairline is white light on a translucent
 * pane, which is invisible the moment the tick is set on a light card rather
 * than on the page wash — and a tick nobody can see is a control nobody can
 * find. A neutral hairline reads on both.
 */
const restDotClasses = /* @__PURE__ */ [
  glassClasses,
  'cursor-pointer bg-(--plass-glass) [border-color:var(--plass-border)]',
  'hover:bg-(--plass-glass-hover) hover:[border-color:var(--p-line)]',
  'data-[checked]:[background-image:var(--p-fill)] data-[checked]:text-(--p-on-solid)',
  'data-[checked]:[border-color:transparent] data-[checked]:hover:brightness-105'
].join(' ');

const readOnlyDotClasses = /* @__PURE__ */ [
  glassClasses,
  'cursor-default bg-(--plass-glass) [border-color:var(--plass-border)]',
  'saturate-[0.55]',
  'data-[checked]:[background-image:var(--p-fill)] data-[checked]:text-(--p-on-solid)',
  'data-[checked]:[border-color:transparent]'
].join(' ');

const disabledDotClasses = /* @__PURE__ */ [
  glassClasses,
  'cursor-not-allowed bg-(--plass-glass) [border-color:var(--plass-border)]',
  'opacity-50 saturate-[0.35]',
  'data-[checked]:[background-image:var(--p-fill)] data-[checked]:text-(--p-on-solid)',
  'data-[checked]:[border-color:transparent]'
].join(' ');

/** The inner dot: `currentColor`, so it inherits the on-fill ink. */
const indicatorClasses = 'rounded-full bg-current';

/**
 * One option in a `PlRadioGroup`.
 *
 * It has no `size` and no `color` of its own — both come from the group, which
 * is the only place they can be set once and mean the same thing for every
 * option in the set.
 */
export const PlRadio = /* @__PURE__ */ React.forwardRef<HTMLElement, PlRadioProps>(function PlRadio(
  { label, description, disabled = false, className, style, ...props },
  ref
) {
  const group = React.useContext(RadioGroupContext);
  const readOnly = props.readOnly ?? group.readOnly;

  return (
    <Field.Root
      disabled={disabled}
      className={['flex flex-col', className ?? ''].filter(Boolean).join(' ')}
      style={style}
    >
      <div className={`flex items-start gap-2 ${tickRowTextClasses[group.size]}`}>
        {/* `1lh` centres the dot on the first line of the label, and the row
            pins the leading so `1lh` is the label's line box and not the host
            page's. */}
        <span className="flex h-[1lh] shrink-0 items-center">
          <BaseUIRadio.Root
            ref={ref}
            className={[
              dotBaseClasses,
              tickSizeClasses[group.size],
              disabled ? disabledDotClasses : readOnly ? readOnlyDotClasses : restDotClasses
            ].join(' ')}
            disabled={disabled}
            {...props}
          >
            <BaseUIRadio.Indicator
              className={`${indicatorClasses} ${tickDotClasses[group.size]}`}
            />
          </BaseUIRadio.Root>
        </span>

        {label || description ? (
          <span className="flex min-w-0 flex-col gap-0.5">
            {label ? (
              <Field.Label
                className={
                  disabled ? 'text-(--plass-muted-fg)' : 'cursor-pointer text-(--plass-fg)'
                }
              >
                {label}
              </Field.Label>
            ) : null}
            {description ? (
              <Field.Description
                className={`${metaTextClasses[group.size]} text-(--plass-muted-fg)`}
              >
                {description}
              </Field.Description>
            ) : null}
          </span>
        ) : null}
      </div>
    </Field.Root>
  );
});

/**
 * A set of options where exactly one is chosen.
 *
 * Base UI owns the roving tab index and the arrow-key navigation, which is the
 * whole reason a radio group is a component at all rather than a `<div>` full of
 * inputs: the set takes one tab stop, and the arrows move within it.
 */
export const PlRadioGroup = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlRadioGroupProps>(
  function PlRadioGroup(
    {
      size = 'md',
      color = 'primary',
      orientation = 'vertical',
      label,
      description,
      error,
      invalid,
      disabled = false,
      readOnly = false,
      className,
      classNames,
      style,
      children,
      ...props
    },
    ref
  ) {
    const hasError = hasContent(error);
    const isInvalid = invalid ?? hasError;
    // Invalid re-points the whole slot family at `danger`, so every dot, the
    // ring and the message all turn over together.
    const family: PlassColor = isInvalid ? 'danger' : color;

    const context = React.useMemo(
      () => ({ size, color: family, readOnly }),
      [size, family, readOnly]
    );

    return (
      <RadioGroupContext.Provider value={context}>
        <Field.Root
          disabled={disabled}
          invalid={isInvalid}
          className={['flex flex-col gap-1.5', className ?? ''].filter(Boolean).join(' ')}
          // `solid`, because a checked dot *is* the coloured thing.
          style={{ ...controlSlots(family, 0, 'solid'), ...style }}
        >
          {label ? (
            <Field.Label
              className={cx(
                metaTextClasses[size],
                'font-semibold',
                disabled ? 'text-(--plass-muted-fg)' : 'text-(--plass-fg)',
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

          <BaseUIRadioGroup
            ref={ref}
            disabled={disabled}
            readOnly={readOnly}
            className={cx(
              'flex',
              orientation === 'horizontal'
                ? 'flex-row flex-wrap gap-x-5 gap-y-2'
                : 'flex-col gap-2',
              classNames?.control
            )}
            {...props}
          >
            {children}
          </BaseUIRadioGroup>

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
      </RadioGroupContext.Provider>
    );
  }
);
