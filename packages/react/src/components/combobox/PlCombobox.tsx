'use client';

import * as React from 'react';
import { FadedContext, controlNaming, useDisabled } from '../../internal/form.js';
import { useDefaults, useRuntimeLocale } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { Combobox as BaseUICombobox } from '@base-ui/react/combobox';
import { Field } from '@base-ui/react/field';
import { PlChip } from '../chip/PlChip.js';
import { CheckIcon, ChevronIcon, CloseIcon, PlusIcon } from '../../internal/icons.js';
import { hotKeyHandler } from '../../internal/keys.js';
import { useFieldLight } from '../../internal/glow.js';
import {
  FieldNotch,
  floatControlClassName,
  notchShellStyle,
  resolveNotch
} from '../../internal/notch.js';
import {
  chipRemoveClasses,
  controlHeightClasses,
  controlTextLeadingClasses,
  cx,
  disabledClasses,
  fieldDescriptionClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  fieldSlots,
  focusWithinRingClasses,
  forcedHighlightedClasses,
  gapClasses,
  glassClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  stackGapClasses,
  surfaceSlots,
  targetClasses,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassColor,
  PlassElevation,
  PlassFieldClassNames,
  PlassHotKeys,
  PlassFieldLabelPlacement,
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
   * text input, and neither of those can be done to an element. `content` is
   * where a row draws more than that.
   */
  label?: string;
  /**
   * What the row draws in place of its label: a thumbnail, a glyph, a second
   * line. The label is still what is filtered, written into the input and put
   * on the chip, and the content's text is what a screen reader reads for the
   * row, so keep the label's words in it.
   */
  content?: React.ReactNode;
  /** Unavailable, but still listed — the option exists, it just cannot be picked. */
  disabled?: boolean;
}

/** One value, or an array of them, depending on `multiple`. */
type Selection<Multiple extends boolean | undefined> = Multiple extends true
  ? PlComboboxValue[]
  : PlComboboxValue | null;

/**
 * What caused a change, handed to `onValueChange`, `onInputValueChange` and
 * `onOpenChange` as their second argument. It is Base UI's own: `reason` names
 * the cause (`'item-press'`, `'chip-remove-press'`, `'clear-press'`,
 * `'escape-key'` and the rest), `event` is the DOM event behind it, and
 * `cancel()` turns the change away, so the field keeps what it held.
 */
export type PlComboboxChangeEventDetails = BaseUICombobox.Root.ChangeEventDetails;

export interface PlComboboxProps<Multiple extends boolean | undefined = false>
  extends
    PlassStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'children'> {
  /** @default 'glass' */
  variant?: PlassStyleProps['variant'];
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
   * inside the field, and the input goes on filtering after each. A row taken
   * from a filtered list closes the list and empties the text, as Base UI does;
   * a row taken with nothing typed leaves the list open for the next one.
   * @default false
   */
  multiple?: Multiple;
  /** The chosen value. Use with `onValueChange` for a controlled combobox. */
  value?: Selection<Multiple> | null;
  /** The initially chosen value, for an uncontrolled combobox. */
  defaultValue?: Selection<Multiple> | null;
  /** Called with the new value, and with what caused the change. */
  onValueChange?: (value: Selection<Multiple>, eventDetails: PlComboboxChangeEventDetails) => void;
  /** Called as the text in the input changes — the filter query, not the value. */
  onInputValueChange?: (inputValue: string, eventDetails: PlComboboxChangeEventDetails) => void;
  /**
   * Which rows a query keeps. Left out, a row stays while its label contains
   * the query, compared in the runtime's locale. `null` keeps every row as
   * `items` gives it, for a list a server has already searched, which may have
   * matched a row on a spelling its label does not have.
   *
   * Receives the trimmed query, and is not asked about the row that offers
   * what was typed: that row is the query itself, and always stays.
   */
  filter?: ((option: PlComboboxOption, query: string) => boolean) | null;
  /**
   * Whether a row lights up on its own, so Enter takes it without an arrow key
   * first. `true` lights the first row as the query changes. `'always'` also
   * lights it whenever the open list has rows and none is lit, which is what a
   * list filled after the reader stopped typing needs: rows that arrive later
   * are lit as they arrive. `false` lights nothing until an arrow key or the
   * pointer does.
   * @default true
   */
  autoHighlight?: boolean | 'always';
  /**
   * Whether Escape with the list closed empties the field. Off by default, so
   * a stray Escape cannot take every chip off, and the key goes on to whatever
   * the field sits in, such as a modal. Escape on an open list closes it
   * either way.
   * @default false
   */
  clearOnEscape?: boolean;
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
   * @default `Add “{query}”`, from the label pack
   */
  customLabel?: (query: string) => React.ReactNode;
  /**
   * Shows a × that empties the field. Off by default — a field that can be
   * cleared in one click is a field that can be emptied by accident.
   * @default false
   */
  clearable?: boolean;
  /**
   * Shown in the popup when nothing matched and no value may be added. Falls
   * back to the label pack's `empty`.
   * @default 'Nothing here'
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
  /** The name of what the field holds, wired to it by Base UI's Field. */
  label?: React.ReactNode;
  /**
   * Where the `label` goes — above the field, in its top edge, or inside it
   * where the text would be typed until the field is focused or holds a value.
   * With a `startIcon` a `float` label stays in the edge, because the icon is
   * where it would rest.
   * Falls back to the nearest `PlassProvider`, then to `top`.
   * @default 'top'
   */
  labelPlacement?: PlassFieldLabelPlacement;
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
  /** Called as the popup opens or closes, and with what caused it. */
  onOpenChange?: (open: boolean, eventDetails: PlComboboxChangeEventDetails) => void;
  /** Accessible name of the button that opens the list. @default 'Open' */
  openLabel?: string;
  /** Accessible name of the clear button. @default 'Clear' */
  clearLabel?: string;
  /**
   * Accessible name of a chip's remove button. Receives the chip's label.
   * @default `Remove {label}`, from the label pack
   */
  removeLabel?: (label: string) => string;
  /** A ref to the text input the user types into. */
  inputRef?: React.Ref<HTMLInputElement>;
  id?: string;
}

/**
 * One row of the list. What Base UI holds as the value is the row's `value`
 * itself, a string or a number, and the object is what carries the label the
 * input and the filter need, plus the flag that says "this row is offering a
 * value the list does not have". `option` is the caller's own item, which is
 * what a caller's `filter` is handed.
 */
interface Entry {
  value: PlComboboxValue;
  label: string;
  content?: React.ReactNode;
  disabled?: boolean;
  custom?: boolean;
  option?: PlComboboxOption;
}

/** The field, and it is a PlTextField's shell to the pixel. */
const shellBaseClasses = /* @__PURE__ */ [
  'relative flex w-full cursor-text items-center',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  iconClasses
].join(' ');

/**
 * The ring, added at the call site rather than above: a notched field does not
 * have one. An outline is a rectangle and the label is sitting on the edge it
 * would be drawn along, so there the edge itself thickens instead. See
 * `internal/notch`.
 */
const shellRingClasses = focusWithinRingClasses;

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
  'motion-reduce:[transition-duration:0ms]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

const itemClasses = /* @__PURE__ */ [
  'relative flex cursor-pointer items-center gap-2 select-none',
  'rounded-(--plass-radius-xs) py-1.5 pe-2 ps-7',
  transitionClasses,
  // `data-highlighted` rather than `:hover`: it is also what the arrow keys
  // move, so the mouse and the keyboard light the same row.
  'data-[highlighted]:bg-(--p-soft-hover) data-[highlighted]:text-(--p-accent)',
  forcedHighlightedClasses,
  'data-[selected]:font-semibold data-[selected]:text-(--p-accent)',
  'data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50',
  '[outline:none]'
].join(' ');

/**
 * The chevron and the ×, which sit in the field rather than in the list.
 *
 * `p-0` because a browser pads a button on every side, and
 * `plass-ui/styles.css` does not reset that padding: without it each would be
 * wider than its glyph.
 */
const adornmentClasses = /* @__PURE__ */ [
  'inline-flex h-[1lh] shrink-0 cursor-pointer items-center justify-center p-0',
  'rounded-(--plass-radius-xs) text-(--plass-muted-fg)',
  '[transition:color_var(--plass-duration)_var(--plass-ease)]',
  'motion-reduce:[transition-duration:0ms]',
  // `enabled:` because a disabled button still matches `:hover`, and the
  // chevron of a disabled field is no more lit than the field is.
  'enabled:hover:text-(--p-accent)',
  'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:[outline-offset:1px]',
  // No fade of their own: they are disabled only when the field is, and the
  // shell they sit in is already drawn at half, as a `PlSelect`'s chevron is.
  'disabled:cursor-not-allowed'
].join(' ');

/**
 * The ×, pressed from a 24px square through `targetClasses`.
 *
 * The chevron beside it keeps the size it is drawn at: what it does, a press
 * on the input does as well, since Base UI opens the list on a click in the
 * field. The × is positioned and the chevron is not, so where the square
 * reaches over the chevron at `xs` the × has the press.
 */
const clearClasses = /* @__PURE__ */ cx(targetClasses, adornmentClasses);

const nothing: PlComboboxValue[] = [];

/** No labels held, as one empty map, so a field with nothing chosen keeps the same one. */
const noLabels: ReadonlyMap<PlComboboxValue, string> = new Map();

/**
 * The label of each of `values`, from the row that lists it now or, failing
 * that, from `held`, the labels kept from the rows that listed them before.
 * `held` itself when nothing has changed, so a caller can tell by comparing.
 */
function labelsOf(
  held: ReadonlyMap<PlComboboxValue, string>,
  values: readonly PlComboboxValue[],
  byValue: ReadonlyMap<PlComboboxValue, Entry>
): ReadonlyMap<PlComboboxValue, string> {
  const next = new Map<PlComboboxValue, string>();

  for (const value of values) {
    const label = byValue.get(value)?.label ?? held.get(value);

    if (label !== undefined) {
      next.set(value, label);
    }
  }

  const same =
    next.size === held.size && [...next].every(([value, label]) => held.get(value) === label);

  if (same) {
    return held;
  }

  return next.size === 0 ? noLabels : next;
}

/**
 * Keeps `countRef` at the number of rows the list is showing. Base UI holds that
 * in a context only its own parts can read, through a hook, so this sits
 * inside the root to read it for the handlers around it.
 */
function ShownRows({ countRef }: { countRef: React.RefObject<number> }) {
  const shown = BaseUICombobox.useFilteredItems().length;

  React.useEffect(() => {
    countRef.current = shown;
  }, [countRef, shown]);

  return null;
}

/**
 * Always an array inside, however the caller spells it.
 *
 * An array is passed on as it came rather than copied, and nothing is always
 * the same empty one. With `multiple` this is the value Base UI holds, and
 * Base UI takes a new array for a new value: it clears the field's error from
 * a `PlForm` and runs its validation again each time it sees one.
 */
function toArray(value: unknown): PlComboboxValue[] {
  if (value === null || value === undefined) {
    return nothing;
  }

  return Array.isArray(value) ? (value as PlComboboxValue[]) : [value as PlComboboxValue];
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
 * input goes on filtering after each one. A row taken from a filtered list
 * closes the list and empties the text, which is how Base UI 1.8.0 behaves,
 * and a row taken with nothing typed leaves the list open for the next one.
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
  filter,
  autoHighlight = true,
  clearOnEscape = false,
  allowCustom = true,
  customLabel,
  clearable = false,
  emptyMessage: emptyMessageProp,
  limit,
  placeholder,
  label,
  labelPlacement: labelPlacementProp,
  description,
  error,
  invalid,
  startIcon,
  fullWidth = false,
  disabled: disabledProp = false,
  readOnly = false,
  required = false,
  name,
  open,
  defaultOpen,
  onOpenChange,
  openLabel: openLabelProp,
  clearLabel: clearLabelProp,
  removeLabel: removeLabelProp,
  inputRef,
  id,
  className,
  hotKeys,
  classNames,
  style,
  'aria-label': ariaLabel,
  'aria-labelledby': ariaLabelledBy,
  ...props
}: PlComboboxProps<Multiple>) {
  const defaults = useDefaults();
  // The one locale the text is matched in: Base UI's filter compares in it and
  // the "add this" row folds case in it, so the two cannot disagree about what
  // was typed. The runtime's, pinned while a server render hydrates, as a
  // `PlDataTable` sorts text in.
  const matchLocale = useRuntimeLocale(undefined);
  const disabled = useDisabled(disabledProp);
  const labels = useLabels();
  const openLabel = openLabelProp ?? labels.open;
  const clearLabel = clearLabelProp ?? labels.clear;
  const emptyMessage = emptyMessageProp ?? labels.empty;
  const removeLabel = removeLabelProp ?? labels.removeItem;
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';
  const labelPlacement = labelPlacementProp ?? defaults.labelPlacement ?? 'top';
  const { notched, float } = resolveNotch(labelPlacement, label, hasContent(startIcon));

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
        content: item.content,
        disabled: item.disabled,
        option: item
      })),
    [items]
  );

  // The caller's filter speaks in their own items. The row offering what was
  // typed has none, and stays whatever the filter says, as Base UI's own
  // filter keeps it by its label being the query.
  const keeps = React.useMemo(
    () =>
      filter
        ? (entry: Entry, query: string) => entry.option === undefined || filter(entry.option, query)
        : filter,
    [filter]
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

  // The label each chosen value was last listed with. A list a server answers
  // holds only what the last query found, and a chip whose row is not among
  // them would otherwise be called by its value. Kept for the chosen values
  // alone, and brought up to date while rendering, as React keeps a value
  // from an earlier render: a row that lists a chosen value is read on the
  // render that shows it.
  const [heldLabels, setHeldLabels] = React.useState(noLabels);
  const chosenLabels = labelsOf(heldLabels, selection, byValue);

  if (chosenLabels !== heldLabels) {
    setHeldLabels(chosenLabels);
  }

  const entryFor = React.useCallback(
    (item: PlComboboxValue): Entry =>
      byValue.get(item) ?? {
        value: item,
        label: chosenLabels.get(item) ?? String(item),
        custom: !chosenLabels.has(item)
      },
    [byValue, chosenLabels]
  );

  // What Base UI writes into a single field for a value no row holds: the
  // label it was last listed with, or for a value typed in, the value itself.
  const labelOf = React.useCallback(
    (item: PlComboboxValue) => chosenLabels.get(item) ?? String(item),
    [chosenLabels]
  );

  // The row that offers what was typed. It is a real item rather than a special
  // case in the keyboard handling, so Enter, a click and the arrow keys all
  // reach it the same way every other row is reached — and Base UI's own filter
  // keeps it visible, because its label *is* the query.
  const trimmed = query.trim();
  const folded = trimmed.toLocaleLowerCase(matchLocale);
  const alreadyKnown =
    trimmed === '' ||
    options.some(
      (option) =>
        option.label.toLocaleLowerCase(matchLocale) === folded ||
        String(option.value).toLocaleLowerCase(matchLocale) === folded
    ) ||
    selection.some(
      (item) =>
        String(item).toLocaleLowerCase(matchLocale) === folded ||
        chosenLabels.get(item)?.toLocaleLowerCase(matchLocale) === folded
    );
  const customValue = allowCustom && !readOnly && !disabled && !alreadyKnown ? trimmed : null;

  const listItems = React.useMemo<Entry[]>(
    () =>
      customValue === null
        ? options
        : [...options, { value: customValue, label: customValue, custom: true }],
    [options, customValue]
  );

  // Base UI is handed the rows as a collection, so the value it holds is the
  // value itself rather than the row. Base UI takes a value that is a new object
  // for a new value and writes its label into the field, over whatever has been
  // typed there; a row is a new object each time `items` is, and a string or a
  // number is not. A renamed option's new label reaches the field the way Base
  // UI writes any new label, which is not over a query typed into the open list.
  const collection = React.useMemo(
    () =>
      BaseUICombobox.createItems(listItems, {
        getValue: (entry) => entry.value,
        getLabel: (entry) => entry.label
      }),
    [listItems]
  );
  const baseValue = isMultiple ? selection : (selection[0] ?? null);

  // The caller hears of a change before the field takes it, so a caller that
  // cancels it leaves Base UI and the mirror holding what they held.
  function commit(next: PlComboboxValue[], details: PlComboboxChangeEventDetails) {
    onValueChange?.((isMultiple ? next : (next[0] ?? null)) as Selection<Multiple>, details);

    if (details.isCanceled) {
      return;
    }

    if (value === undefined) {
      setOwnSelection(next);
    }

    // Read off the rows as they are now, which list what was just taken. By
    // the time the field renders again they may hold only what the next query
    // finds: a `multiple` field empties its text as a row is taken, and a
    // caller that searches as the text changes has already asked again.
    setHeldLabels(labelsOf(chosenLabels, [...selection, ...next], byValue));
  }

  /**
   * Turns away Base UI emptying the field on Escape with the list closed,
   * unless `clearOnEscape` asks for it. Base UI empties the text and then the
   * value on that one press, and those are the only changes it makes for that
   * reason: Escape on an open list closes it and lets go of the query under
   * reasons of their own. The key is let past the field, so a modal round it
   * hears it, as it would from a field with nothing to empty.
   */
  function refusesEscape(details: PlComboboxChangeEventDetails) {
    if (clearOnEscape || details.reason !== 'escape-key') {
      return false;
    }

    details.cancel();
    details.allowPropagation();

    return true;
  }

  // How many rows the list is showing, which Base UI works out and keeps.
  const shownRef = React.useRef(0);

  /**
   * Keeps the list open on Enter when it has no rows at all: still waiting for
   * them, or matching nothing. Base UI closes a list on Enter with no row lit,
   * and closing it throws away what was typed, in a `multiple` field and in a
   * single one alike, when there was nothing for Enter to take. The key goes no
   * further either, so a form round the field is not sent with its list open.
   * A list with rows and none lit still closes, and lets the form be sent.
   */
  function holdsOpen(details: PlComboboxChangeEventDetails) {
    const { event } = details;

    if (
      details.reason !== 'none' ||
      event.type !== 'keydown' ||
      (event as KeyboardEvent).key !== 'Enter' ||
      shownRef.current > 0
    ) {
      return false;
    }

    details.cancel();
    event.preventDefault();

    return true;
  }

  const lit = !disabled && !readOnly;
  const light = useFieldLight(lit);
  const shellClasses = cx(
    shellBaseClasses,
    notched ? '' : shellRingClasses,
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
        : fieldRestClasses[variant],
    // The interaction light, on the shell rather than on the input inside it:
    // what a pointer is over is the field. A locked one carries none, because
    // the light is a claim that the surface answers and neither a disabled nor
    // a read-only field does.
    lit ? 'plass-glow' : ''
  );

  const inputClasses = /* @__PURE__ */ [
    // `self-stretch` and no height of its own, in both modes. An input centres
    // its own text in its box, so letting the box be the full height of the row
    // it sits on — the field in single mode, the chip line in multiple — is what
    // puts the placeholder on the same baseline as the chips beside it. `p-0`
    // because a browser pads an input, and `plass-ui/styles.css` does not
    // reset that padding: the shell's padding is the field's, so without it
    // the text would start further in than a text field's.
    'min-w-0 flex-1 self-stretch bg-transparent p-0 [font:inherit] text-inherit',
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
      // `:placeholder-shown` is how a resting label knows the field is empty,
      // and it never matches an input that has no placeholder.
      placeholder={float ? placeholder || ' ' : placeholder}
      // The thing being named, rather than the stack: a field with no room for
      // a `label` is named here or nowhere. An `aria-label` names it in a
      // visible label's place, and a caller's `aria-labelledby` outranks both.
      {...controlNaming(ariaLabel, ariaLabelledBy)}
      // On the input rather than on the stack `...props` lands on: a chord is
      // answered by the thing that has the focus.
      onKeyDown={hotKeyHandler(hotKeys, undefined)}
      className={cx(
        inputClasses,
        isMultiple && 'min-w-16',
        isMultiple && afterChips && 'ms-1.5',
        // The hook a resting label reads the field's emptiness through. Not
        // once a chip is there: the text after the chips is empty then, and
        // the field is not.
        float && !afterChips && floatControlClassName
      )}
    />
  );

  // One element for both placements, so the label a reader clicks and the label
  // a screen reader reads are the same element wherever it is drawn.
  const labelNode = (
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
      style={{ ...fieldSlots(family, elevation), ...style }}
      {...props}
    >
      {hasContent(label) && !notched ? labelNode : null}

      <BaseUICombobox.Root<PlComboboxValue, boolean, Entry>
        id={id}
        name={name}
        items={collection}
        multiple={isMultiple}
        value={baseValue}
        filter={keeps}
        onValueChange={(next, details) => {
          if (refusesEscape(details)) {
            return;
          }

          const chosen = toArray(next);

          // Base UI empties the value whether or not it holds anything: on
          // Escape with the list closed, and in single mode as the text is
          // emptied. Nothing held before and nothing after is not a change, so
          // the parent is not told of one.
          if (chosen.length === 0 && selection.length === 0) {
            return;
          }

          commit(chosen, details);
        }}
        // The text is Base UI's to own, not ours: in single mode it is the
        // chosen option's label, which has to be there from the first paint, and
        // in multiple mode it empties itself after each pick. What is kept here
        // is a copy, and only so the "add this" row knows what was typed.
        onInputValueChange={(next, details) => {
          if (refusesEscape(details)) {
            return;
          }

          onInputValueChange?.(next, details);

          if (!details.isCanceled) {
            setQuery(next);
          }
        }}
        open={open}
        defaultOpen={defaultOpen}
        onOpenChange={(next, details) => {
          if (!next && holdsOpen(details)) {
            return;
          }

          onOpenChange?.(next, details);
        }}
        // On by default, so the first match lights up as you type and Enter
        // commits without an arrow key first. This is what makes the "add this"
        // row reachable from the keyboard at all: a value the list does not
        // have is the only match there is, so it is the one Enter lands on.
        // `'always'` is Base UI's own mode, the one its Autocomplete documents:
        // `Combobox.Root` narrows the type to a boolean but hands the value on
        // to the same machinery as it is.
        autoHighlight={autoHighlight as boolean}
        // The collection labels a value from its row, so this labels only a
        // value no row holds: one listed before, or a custom one.
        itemToStringLabel={labelOf}
        itemToStringValue={String}
        limit={limit}
        locale={matchLocale}
        disabled={disabled}
        readOnly={readOnly}
        required={required}
      >
        <ShownRows countRef={shownRef} />

        <FieldNotch
          notched={notched}
          size={size}
          density={density}
          variant={variant}
          disabled={disabled}
          readOnly={readOnly}
          float={float}
          label={labelNode}
        >
          <BaseUICombobox.InputGroup
            style={notched ? notchShellStyle : undefined}
            {...light}
            className={cx(shellClasses, classNames?.control)}
          >
            {startIcon ? (
              <span className="flex h-[1lh] shrink-0 items-center text-(--plass-muted-fg)">
                {startIcon}
              </span>
            ) : null}

            {isMultiple ? (
              <BaseUICombobox.Chips className="flex min-w-0 flex-1 flex-wrap items-center gap-1">
                {/* The shell already fades what it holds while the field is
                    disabled, so the chips, disabled with it, keep the disabled
                    look without a fade of their own. */}
                <FadedContext.Provider value={disabled}>
                  <BaseUICombobox.Value>
                    {(chosen: PlComboboxValue[]) => (
                      <React.Fragment>
                        {chosen.map(entryFor).map((entry) => (
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
                </FadedContext.Provider>
              </BaseUICombobox.Chips>
            ) : (
              renderInput(false)
            )}

            {/* Not on a locked field, as a chip's × is not: a × that cannot be
                pressed is only something else to read past. */}
            {clearable && !readOnly && !disabled ? (
              <BaseUICombobox.Clear aria-label={clearLabel} className={clearClasses}>
                <CloseIcon />
              </BaseUICombobox.Clear>
            ) : null}

            <BaseUICombobox.Trigger
              aria-label={openLabel}
              // Base UI points the trigger at the field's label, for a combobox
              // whose trigger is the field itself. Here it is a button beside
              // the input, named by what it does, and an `aria-labelledby` would
              // outrank the `aria-label`. Passing the key takes Base UI's value
              // off, since the caller's props are merged last, and an
              // `undefined` attribute is not rendered.
              aria-labelledby={undefined}
              className={adornmentClasses}
            >
              <BaseUICombobox.Icon
                className={cx(
                  // The chevron is the one thing here that may turn: it is a
                  // glyph, not a label, and nothing about it resamples.
                  'flex items-center',
                  '[transition:rotate_var(--plass-duration)_var(--plass-ease)]',
                  'motion-reduce:[transition-duration:0ms]',
                  'data-[popup-open]:rotate-180'
                )}
              >
                <ChevronIcon />
              </BaseUICombobox.Icon>
            </BaseUICombobox.Trigger>
          </BaseUICombobox.InputGroup>
        </FieldNotch>

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
                    value={entry.value}
                    disabled={entry.disabled}
                    className={itemClasses}
                  >
                    {entry.custom ? (
                      <React.Fragment>
                        <span className="absolute start-1.5 flex size-4 items-center justify-center text-(--p-accent) [&_svg]:size-4">
                          <PlusIcon />
                        </span>
                        <span className="truncate">
                          {customLabel ? customLabel(entry.label) : labels.addCustom(entry.label)}
                        </span>
                      </React.Fragment>
                    ) : (
                      <React.Fragment>
                        <BaseUICombobox.ItemIndicator className="absolute start-1.5 flex size-4 items-center justify-center">
                          <CheckIcon />
                        </BaseUICombobox.ItemIndicator>
                        {/* The rest of the row, laid out by the caller. The
                            tick stays in the gutter, centred on however tall
                            the content makes the row. */}
                        {hasContent(entry.content) ? (
                          <span className="min-w-0 flex-1">{entry.content}</span>
                        ) : (
                          <span className="truncate">{entry.label}</span>
                        )}
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
        <Field.Description className={cx(fieldDescriptionClasses(size), classNames?.description)}>
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
