'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { Combobox as BaseUICombobox } from '@base-ui/react/combobox';
import { Field } from '@base-ui/react/field';
import { PlChip } from '../chip/PlChip.js';
import { CheckIcon, ChevronIcon, CloseIcon, PlusIcon } from '../../internal/icons.js';
import { hotKeyHandler } from '../../internal/keys.js';
import {
  chipRemoveClasses,
  controlHeightClasses,
  controlTextLeadingClasses,
  cx,
  disabledClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  focusWithinRingClasses,
  gapClasses,
  glassClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  stackGapClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassColor,
  PlassElevation,
  PlassFieldClassNames,
  PlassHotKeys,
  PlassSize,
  PlassStyleProps
} from '../../types.js';

/**
 * What a combobox's value may be — the same two types a PlSelect submits, and
 * for the same reason: a form control's value is what a form sends, and every
 * escape from that buys flexibility by making the common case harder to write.
 *
 * A value the list does not contain is a `string`: it is what the user typed.
 */
export type PlComboboxValue = string | number;

export interface PlComboboxOption {
  /** Submitted, and what `value` / `onValueChange` speak in. */
  value: PlComboboxValue;
  /**
   * Shown in the list, in the input and on the chip. Defaults to the value.
   *
   * A `string` rather than a `ReactNode`, which is the one place this differs
   * from PlSelect: the label is typed against by the filter and written into a
   * text input, and neither of those can be done to an element.
   */
  label?: string;
  /** Unavailable, but still listed — the option exists, it just cannot be picked. */
  disabled?: boolean;
}

/** One value, or an array of them, depending on `multiple`. */
type Selection<Multiple extends boolean | undefined> = Multiple extends true
  ? PlComboboxValue[]
  : PlComboboxValue | null;

export interface PlComboboxProps<Multiple extends boolean | undefined = false>
  extends
    PlassStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'children'> {
  /** Classes on the parts a `className` does not reach. */
  classNames?: PlassFieldClassNames;
  /**
   * Chords this field answers to, in the vocabulary `PlHotKeys` draws.
   *
   * `{ 'Mod+Enter': save, Escape: cancel }` — the same string a `PlHotKeys`
   * beside the field would print, so the cap and the binding cannot drift. A
   * chord that matches is **consumed**: the handler runs and the key reaches
   * neither the control's own behaviour nor the form around it.
   */
  hotKeys?: PlassHotKeys;
  /**
   * The options, as data — the same shape PlSelect takes, and for the same
   * reason: what a caller has is almost always an array already.
   */
  items: readonly PlComboboxOption[];
  /**
   * Whether more than one value may be held. The chosen ones become chips
   * inside the field, and the input goes on filtering after each.
   * @default false
   */
  multiple?: Multiple;
  /** The chosen value. Use with `onValueChange` for a controlled combobox. */
  value?: Selection<Multiple> | null;
  /** The initially chosen value, for an uncontrolled combobox. */
  defaultValue?: Selection<Multiple> | null;
  onValueChange?: (value: Selection<Multiple>) => void;
  /** Called as the text in the input changes — the filter query, not the value. */
  onInputValueChange?: (inputValue: string) => void;
  /**
   * Whether a value the list does not contain may be committed.
   *
   * On by default, and it is what separates this from a searchable PlSelect: the
   * typed text is offered as its own row at the end of the list, so committing
   * it is a choice the user makes rather than something that happens to them on
   * blur. Turn it off for a field whose values are a closed set.
   * @default true
   */
  allowCustom?: boolean;
  /**
   * What that row says. Receives the trimmed query.
   * @default (query) => `Add “${query}”`
   */
  customLabel?: (query: string) => React.ReactNode;
  /**
   * Shows a × that empties the field. Off by default — a field that can be
   * cleared in one click is a field that can be emptied by accident.
   * @default false
   */
  clearable?: boolean;
  /**
   * Shown in the popup when nothing matched and no value may be added.
   * @default 'No matches'
   */
  emptyMessage?: React.ReactNode;
  /** The most rows the list will show at once. `-1` is all of them. @default -1 */
  limit?: number;
  /** Shown in the input while nothing is typed. */
  placeholder?: string;
  /**
   * Drop shadow depth of the *field*. `0`, like a PlTextField: a field is cut
   * into the sheet rather than resting on it. The popup has its own, fixed at
   * `3` — it genuinely floats above the page.
   * @default 0
   */
  elevation?: PlassElevation;
  /** Label above the field, wired to it by Base UI's Field. */
  label?: React.ReactNode;
  /** Helper text below the field. */
  description?: React.ReactNode;
  /** Error message below. Its presence also turns the combobox invalid. */
  error?: React.ReactNode;
  /** Forces the invalid state without a message. Defaults to whether `error` has content. */
  invalid?: boolean;
  /** Content placed before the input. Sized in `em`, so it tracks the text. */
  startIcon?: React.ReactNode;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  /** Unavailable. */
  disabled?: boolean;
  /** The value is shown but cannot be changed. */
  readOnly?: boolean;
  /** Whether a value must be chosen before the form is submitted. */
  required?: boolean;
  /** Identifies the field when a form is submitted. */
  name?: string;
  /** The popup is open. Use with `onOpenChange` for a controlled popup. */
  open?: boolean;
  /** Whether the popup starts open. */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Accessible name of the button that opens the list. @default 'Open' */
  openLabel?: string;
  /** Accessible name of the clear button. @default 'Clear' */
  clearLabel?: string;
  /**
   * Accessible name of a chip's remove button. Receives the chip's label.
   * @default (label) => `Remove ${label}`
   */
  removeLabel?: (label: string) => string;
  /** A ref to the text input the user types into. */
  inputRef?: React.Ref<HTMLInputElement>;
  id?: string;
}

/**
 * What Base UI holds. The public value is a string or a number; the object is
 * what carries the label the input and the filter need, plus the flag that says
 * "this row is offering a value the list does not have".
 */
interface Entry {
  value: PlComboboxValue;
  label: string;
  disabled?: boolean;
  custom?: boolean;
}

/** The field, and it is a PlTextField's shell to the pixel. */
const shellBaseClasses = /* @__PURE__ */ [
  'group relative flex w-full cursor-text items-center',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  focusWithinRingClasses,
  iconClasses
].join(' ');

/**
 * With chips in it the field cannot have a fixed height — the chips wrap. The
 * padding is `(control height − chip height) / 2` instead, which makes a one-row
 * combobox exactly as tall as the field beside it, and `min-h-*` catches the
 * variant that carries no border.
 *
 * Keyed by `size` and never by `density`: density is horizontal padding only.
 */
const chipsInsetClasses: Record<PlassSize, string> = {
  xs: 'min-h-6 py-0',
  sm: 'min-h-8 py-0.5',
  md: 'min-h-10 py-1',
  lg: 'min-h-12 py-1.5',
  xl: 'min-h-14 py-2'
};

/**
 * The popup is one of the few surfaces in the library that is *supposed* to
 * float, so unlike everything else it carries a shadow by default — at level 3.
 * Identical to PlSelect's, because a combobox's list and a select's list are the
 * same list.
 *
 * Every `--p-*` it reads is set on the popup itself rather than inherited from
 * the Field around it. A portalled popup renders at the end of `<body>`, so it
 * is outside the element the slots were declared on, and a `var()` with nothing
 * to resolve to is not a fallback — `border-color` collapses to `currentColor`
 * and `background-color` to transparent.
 *
 * Opacity only, exactly as on a `PlSelect`: a list that slid or grew would be
 * dragging its own options across the field they are being typed into. Base UI
 * holds the popup in the document for the length of the ending transition, so
 * the way out is the way in reversed rather than a disappearance.
 */
const popupClasses = /* @__PURE__ */ [
  glassClasses,
  'max-h-[min(20rem,var(--available-height))] overflow-y-auto overscroll-contain',
  'w-[var(--anchor-width)] border bg-(--plass-glass-press) p-1',
  '[border-color:var(--plass-glass-line)]',
  '[box-shadow:var(--plass-shadow-3),var(--plass-gloss-glass)]',
  '[outline:none]',
  '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

const itemClasses = /* @__PURE__ */ [
  'relative flex cursor-pointer items-center gap-2 select-none',
  'rounded-(--plass-radius-xs) py-1.5 pe-2 ps-7',
  transitionClasses,
  // `data-highlighted` rather than `:hover`: it is also what the arrow keys
  // move, so the mouse and the keyboard light the same row.
  'data-[highlighted]:bg-(--p-soft-hover) data-[highlighted]:text-(--p-accent)',
  'data-[selected]:font-semibold data-[selected]:text-(--p-accent)',
  'data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50',
  '[outline:none]'
].join(' ');

/** The chevron and the ×, which sit in the field rather than in the list. */
const adornmentClasses = /* @__PURE__ */ [
  'inline-flex h-[1lh] shrink-0 cursor-pointer items-center justify-center',
  'rounded-(--plass-radius-xs) text-(--plass-muted-fg)',
  '[transition:color_var(--plass-duration)_var(--plass-ease)]',
  'hover:text-(--p-accent)',
  'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:[outline-offset:1px]',
  'disabled:cursor-not-allowed disabled:opacity-50'
].join(' ');

/** Always an array inside, however the caller spells it. */
function toArray(value: unknown): PlComboboxValue[] {
  if (value === null || value === undefined) {
    return [];
  }

  return Array.isArray(value) ? (value.slice() as PlComboboxValue[]) : [value as PlComboboxValue];
}

/**
 * A field you can type into and also choose from.
 *
 * The shell is a PlTextField's wearing a chevron, exactly as PlSelect's trigger
 * is — the three have to be indistinguishable in a form, or the form looks
 * assembled rather than designed. What is different is what the text does: it
 * filters the list, and — unless `allowCustom` is off — it can become the value
 * itself, offered as the last row rather than committed silently on blur.
 *
 * With `multiple` the chosen values become PlChips inside the field and the
 * input goes on filtering after each one, so a set of tags is built without the
 * field ever closing.
 *
 * Base UI owns everything hard about this: the filtering and its collator, the
 * popup's positioning and flipping, the `combobox`/`listbox` wiring, arrow-key
 * navigation across both the list and the chips, and the hidden input that makes
 * the whole thing submit with a form.
 */
export function PlCombobox<Multiple extends boolean | undefined = false>({
  variant = 'glass',
  size: sizeProp,
  color: colorProp,
  density: densityProp,
  elevation = 0,
  items,
  multiple,
  value,
  defaultValue,
  onValueChange,
  onInputValueChange,
  allowCustom = true,
  customLabel,
  clearable = false,
  emptyMessage = 'No matches',
  limit,
  placeholder,
  label,
  description,
  error,
  invalid,
  startIcon,
  fullWidth = false,
  disabled = false,
  readOnly = false,
  required = false,
  name,
  open,
  defaultOpen,
  onOpenChange,
  openLabel: openLabelProp,
  clearLabel: clearLabelProp,
  removeLabel = (chip: string) => `Remove ${chip}`,
  inputRef,
  id,
  className,
  hotKeys,
  classNames,
  style,
  ...props
}: PlComboboxProps<Multiple>) {
  const defaults = useDefaults();
  const labels = useLabels();
  const openLabel = openLabelProp ?? labels.open;
  const clearLabel = clearLabelProp ?? labels.clear;
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';

  const hasError = hasContent(error);
  const isInvalid = invalid ?? hasError;
  // Invalid re-points the whole slot family at `danger`, so the edge, the ring,
  // the caret and the message all turn over together.
  const family: PlassColor = isInvalid ? 'danger' : color;
  const isMultiple = multiple === true;

  const options = React.useMemo<Entry[]>(
    () =>
      items.map((item) => ({
        value: item.value,
        label: item.label ?? String(item.value),
        disabled: item.disabled
      })),
    [items]
  );

  // The selection is mirrored internally even when the caller controls it. The
  // "add this" row has to know what has already been chosen — otherwise a tag
  // that was just added goes on being offered — and in uncontrolled mode there
  // is nowhere else that knowledge lives.
  const [ownSelection, setOwnSelection] = React.useState<PlComboboxValue[]>(() =>
    toArray(defaultValue)
  );
  const selection = value === undefined ? ownSelection : toArray(value);

  const [query, setQuery] = React.useState('');

  /* A map rather than a `find`: this is called once per chosen item, and a
     multi-select with a hundred options and twenty chips in it would otherwise
     walk the list twenty times on every render. */
  const byValue = React.useMemo(
    () => new Map(options.map((option) => [option.value, option])),
    [options]
  );

  const entryFor = React.useCallback(
    (item: PlComboboxValue): Entry =>
      byValue.get(item) ?? { value: item, label: String(item), custom: true },
    [byValue]
  );

  // The row that offers what was typed. It is a real item rather than a special
  // case in the keyboard handling, so Enter, a click and the arrow keys all
  // reach it the same way every other row is reached — and Base UI's own filter
  // keeps it visible, because its label *is* the query.
  const trimmed = query.trim();
  const folded = trimmed.toLocaleLowerCase();
  const alreadyKnown =
    trimmed === '' ||
    options.some(
      (option) =>
        option.label.toLocaleLowerCase() === folded ||
        String(option.value).toLocaleLowerCase() === folded
    ) ||
    selection.some((item) => String(item).toLocaleLowerCase() === folded);
  const customValue = allowCustom && !readOnly && !disabled && !alreadyKnown ? trimmed : null;

  const listItems = React.useMemo<Entry[]>(
    () =>
      customValue === null
        ? options
        : [...options, { value: customValue, label: customValue, custom: true }],
    [options, customValue]
  );

  const baseValue = isMultiple
    ? selection.map(entryFor)
    : selection.length > 0
      ? entryFor(selection[0])
      : null;

  function commit(next: PlComboboxValue[]) {
    if (value === undefined) {
      setOwnSelection(next);
    }
    onValueChange?.((isMultiple ? next : (next[0] ?? null)) as Selection<Multiple>);
  }

  const shellClasses = cx(
    shellBaseClasses,
    controlTextLeadingClasses[size],
    radiusClasses[size],
    gapClasses[size],
    isMultiple ? chipsInsetClasses[size] : controlHeightClasses[size],
    // The chevron brings its own hit area; stacking the field's padding on top
    // of it would leave the glyph floating in the middle of a gap.
    `${paddingXClasses[density][size]} pe-1.5`,
    // An if/else rather than stacked variants: two Tailwind classes of equal
    // specificity resolve by their order in the generated stylesheet.
    disabled
      ? disabledClasses[variant]
      : readOnly
        ? fieldReadOnlyClasses[variant]
        : fieldRestClasses[variant]
  );

  const inputClasses = /* @__PURE__ */ [
    // `self-stretch` and no height of its own, in both modes. An input centres
    // its own text in its box, so letting the box be the full height of the row
    // it sits on — the field in single mode, the chip line in multiple — is what
    // puts the placeholder on the same baseline as the chips beside it.
    'min-w-0 flex-1 self-stretch bg-transparent [font:inherit] text-inherit',
    // Not `outline-none`: that utility zeroes `--tw-outline-style`, and the
    // shell's focus ring is drawn from the same variable family.
    '[outline:none]',
    'placeholder:text-(--plass-muted-fg)',
    'caret-(--p-accent) selection:bg-(--p-soft-press)',
    'disabled:cursor-not-allowed'
  ].join(' ');

  /**
   * `afterChips` is the space between the last chip and where typing starts.
   *
   * The row's own `gap-1` is the distance between two chips, which is right
   * between two things of the same kind and too little between a chip and a
   * caret — the query reads as another chip's label rather than as the field's
   * own text. It is only added when there is a chip to be clear of, so an empty
   * multi-select lines its placeholder up with every other field in the form.
   */
  const renderInput = (afterChips: boolean) => (
    <BaseUICombobox.Input
      ref={inputRef}
      placeholder={placeholder}
      // On the input rather than on the stack `...props` lands on: a chord is
      // answered by the thing that has the focus.
      onKeyDown={hotKeyHandler(hotKeys, undefined)}
      className={cx(inputClasses, isMultiple && 'min-w-16', isMultiple && afterChips && 'ms-1.5')}
    />
  );

  return (
    <Field.Root
      disabled={disabled}
      invalid={isInvalid}
      className={cx(
        'flex-col align-top',
        stackGapClasses[size],
        fullWidth ? 'flex w-full' : 'inline-flex',
        className
      )}
      style={{ ...surfaceSlots(family, elevation), ...style }}
      {...props}
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

      <BaseUICombobox.Root<Entry, boolean>
        id={id}
        name={name}
        items={listItems}
        multiple={isMultiple}
        value={baseValue}
        onValueChange={(next) => {
          const chosen = next === null ? [] : Array.isArray(next) ? next : [next];
          commit(chosen.map((entry) => entry.value));
        }}
        // The text is Base UI's to own, not ours: in single mode it is the
        // chosen option's label, which has to be there from the first paint, and
        // in multiple mode it empties itself after each pick. What is kept here
        // is a copy, and only so the "add this" row knows what was typed.
        onInputValueChange={(next) => {
          setQuery(next);
          onInputValueChange?.(next);
        }}
        open={open}
        defaultOpen={defaultOpen}
        onOpenChange={(next) => onOpenChange?.(next)}
        // The first match lights up as you type, so Enter commits without an
        // arrow key first. This is what makes the "add this" row reachable from
        // the keyboard at all: a value the list does not have is the only match
        // there is, so it is the one Enter lands on.
        autoHighlight
        itemToStringLabel={(entry) => entry.label}
        itemToStringValue={(entry) => String(entry.value)}
        isItemEqualToValue={(a, b) => a.value === b.value}
        limit={limit}
        disabled={disabled}
        readOnly={readOnly}
        required={required}
      >
        <BaseUICombobox.InputGroup className={cx(shellClasses, classNames?.control)}>
          {startIcon ? (
            <span className="flex h-[1lh] shrink-0 items-center text-(--plass-muted-fg)">
              {startIcon}
            </span>
          ) : null}

          {isMultiple ? (
            <BaseUICombobox.Chips className="flex min-w-0 flex-1 flex-wrap items-center gap-1">
              <BaseUICombobox.Value>
                {(chosen: Entry[]) => (
                  <React.Fragment>
                    {chosen.map((entry) => (
                      <BaseUICombobox.Chip
                        key={String(entry.value)}
                        render={
                          <PlChip
                            variant="glass"
                            size={size}
                            color={family}
                            density="compact"
                            disabled={disabled}
                            endIcon={
                              readOnly || disabled ? null : (
                                <BaseUICombobox.ChipRemove
                                  aria-label={removeLabel(entry.label)}
                                  className={chipRemoveClasses}
                                >
                                  <CloseIcon />
                                </BaseUICombobox.ChipRemove>
                              )
                            }
                          />
                        }
                      >
                        {entry.label}
                      </BaseUICombobox.Chip>
                    ))}
                    {renderInput(chosen.length > 0)}
                  </React.Fragment>
                )}
              </BaseUICombobox.Value>
            </BaseUICombobox.Chips>
          ) : (
            renderInput(false)
          )}

          {clearable && !readOnly ? (
            <BaseUICombobox.Clear aria-label={clearLabel} className={adornmentClasses}>
              <CloseIcon />
            </BaseUICombobox.Clear>
          ) : null}

          <BaseUICombobox.Trigger aria-label={openLabel} className={adornmentClasses}>
            <BaseUICombobox.Icon
              className={cx(
                // The chevron is the one thing here that may turn: it is a
                // glyph, not a label, and nothing about it resamples.
                'flex items-center',
                '[transition:rotate_var(--plass-duration)_var(--plass-ease)]',
                'data-[popup-open]:rotate-180'
              )}
            >
              <ChevronIcon />
            </BaseUICombobox.Icon>
          </BaseUICombobox.Trigger>
        </BaseUICombobox.InputGroup>

        <BaseUICombobox.Portal>
          {/* `plass-portal` is a hook, not a style: a portalled popup leaves the
              subtree its host may have scoped a CSS reset to. */}
          <BaseUICombobox.Positioner
            className="plass-portal z-(--plass-z-portal) [outline:none]"
            sideOffset={6}
          >
            <BaseUICombobox.Popup
              className={cx(popupClasses, radiusClasses[size], controlTextLeadingClasses[size])}
              style={surfaceSlots(family, 3)}
            >
              <BaseUICombobox.Empty className="px-2 py-1.5 text-(--plass-muted-fg) empty:hidden">
                {emptyMessage}
              </BaseUICombobox.Empty>

              <BaseUICombobox.List>
                {(entry: Entry) => (
                  <BaseUICombobox.Item
                    key={`${entry.custom ? 'custom:' : ''}${String(entry.value)}`}
                    value={entry}
                    disabled={entry.disabled}
                    className={itemClasses}
                  >
                    {entry.custom ? (
                      <React.Fragment>
                        <span className="absolute start-1.5 flex size-4 items-center justify-center text-(--p-accent) [&_svg]:size-4">
                          <PlusIcon />
                        </span>
                        <span className="truncate">
                          {customLabel ? customLabel(entry.label) : `Add “${entry.label}”`}
                        </span>
                      </React.Fragment>
                    ) : (
                      <React.Fragment>
                        <BaseUICombobox.ItemIndicator className="absolute start-1.5 flex size-4 items-center justify-center">
                          <CheckIcon />
                        </BaseUICombobox.ItemIndicator>
                        <span className="truncate">{entry.label}</span>
                      </React.Fragment>
                    )}
                  </BaseUICombobox.Item>
                )}
              </BaseUICombobox.List>
            </BaseUICombobox.Popup>
          </BaseUICombobox.Positioner>
        </BaseUICombobox.Portal>
      </BaseUICombobox.Root>

      {description ? (
        <Field.Description
          className={cx(metaTextClasses[size], 'text-(--plass-muted-fg)', classNames?.description)}
        >
          {description}
        </Field.Description>
      ) : null}

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
