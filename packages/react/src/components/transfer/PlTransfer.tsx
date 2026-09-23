'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { PlCheckbox } from '../checkbox/PlCheckbox.js';
import { PlIconButton } from '../icon-button/PlIconButton.js';
import { PlTextField } from '../text-field/PlTextField.js';
import { ArrowRightIcon } from '../../internal/icons.js';
import { searchText } from '../../internal/search.js';
import { textOf } from '../../internal/text.js';
import {
  cx,
  fieldRestClasses,
  hasContent,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  srOnlyClasses,
  surfaceSlots,
  toLength
} from '../../internal/styles.js';
import type { PlassColor, PlassSize, PlassStyleProps, PlassVariant } from '../../types.js';

/** One thing that can be on either side. */
export interface PlTransferItem {
  /** What identifies it, and what `value` is a list of. */
  value: string;
  /** What the row says. */
  label: React.ReactNode;
  /** In the list but not movable. */
  disabled?: boolean;
}

export interface PlTransferProps
  extends
    PlassStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /** Everything that can be on either side, in the order the lists show it. */
  items: readonly PlTransferItem[];
  /** What is on the trailing side. Use with `onValueChange` for a controlled pair. */
  value?: readonly string[];
  /** What starts there, for an uncontrolled one. */
  defaultValue?: readonly string[];
  onValueChange?: (value: string[]) => void;
  /** The heading over the leading list. @default 'Available' */
  sourceLabel?: React.ReactNode;
  /** And over the trailing one. @default 'Selected' */
  targetLabel?: React.ReactNode;
  /** Puts a filter above each list. @default false */
  searchable?: boolean;
  /** What that filter says while it is empty. @default 'Search' */
  searchLabel?: string;
  /** What a list with nothing in it says. @default 'Nothing here' */
  emptyLabel?: string;
  /**
   * What the tick in a list's heading is announced as, before the name of its
   * list, so the two ticks are told apart by ear. Left out, the label pack's
   * `transferSelectAll` says the whole sentence and puts the name where each
   * language puts it.
   * @default `Select all in {list}`, from the label pack
   */
  selectAllLabel?: string;
  /** What the two arrows are announced as. */
  toTargetLabel?: string;
  toSourceLabel?: string;
  /**
   * What is announced once rows have moved, given how many and the name of the
   * list they went to.
   * @default `{count} items moved to {list}`, from the label pack
   */
  movedLabel?: (count: number, list: string) => string;
  /** How tall each list is. A number of pixels or any CSS length. @default 220 */
  height?: number | string;
  /** Nothing can be ticked or moved. */
  disabled?: boolean;
}

/** The heading strip over each list. */
const headerClasses = 'flex items-center gap-2 border-b [border-color:var(--plass-divider)]';

const panelPadY: Record<PlassSize, string> = {
  xs: 'py-1',
  sm: 'py-1.5',
  md: 'py-2',
  lg: 'py-2.5',
  xl: 'py-3'
};

const rowPadY: Record<PlassSize, string> = {
  xs: 'py-0.5',
  sm: 'py-1',
  md: 'py-1',
  lg: 'py-1.5',
  xl: 'py-2'
};

interface RowProps {
  value: string;
  label: React.ReactNode;
  checked: boolean;
  disabled: boolean;
  size: PlassSize;
  color: PlassColor;
  onTick: (value: string, ticked: boolean) => void;
  rowRef: (value: string, element: HTMLElement | null) => void;
}

/**
 * One row of a list, drawn again only when something about it changed.
 *
 * A tick changes one row, and a list of thousands used to draw every row of
 * both lists again for it, each one a `PlCheckbox` with a Base UI checkbox
 * under it, which is where the input stalled. A row is handed its own value,
 * its own state and two callbacks that keep their identity from one render to
 * the next, so `React.memo` can pass over every row the tick did not touch.
 */
const Row = /* @__PURE__ */ React.memo(function Row({
  value,
  label,
  checked,
  disabled,
  size,
  color,
  onTick,
  rowRef
}: RowProps) {
  const ref = React.useCallback(
    (element: HTMLElement | null) => rowRef(value, element),
    [rowRef, value]
  );
  const onCheckedChange = React.useCallback(
    (next: boolean) => onTick(value, next === true),
    [onTick, value]
  );

  return (
    <PlCheckbox
      ref={ref}
      size={size}
      color={color}
      className={rowPadY[size]}
      label={label}
      checked={checked}
      disabled={disabled}
      onCheckedChange={onCheckedChange}
    />
  );
});

/** What a caller sees of one side, so the two panels are literally one function. */
interface PanelProps {
  title: React.ReactNode;
  rows: readonly PlTransferItem[];
  ticked: ReadonlySet<string>;
  onTick: (value: string, ticked: boolean) => void;
  onTickAll: (ticked: boolean) => void;
  search: string;
  onSearch: (search: string) => void;
  searchable: boolean;
  disabled: boolean;
  height: string | undefined;
  emptyLabel: string;
  searchLabel: string;
  /** The heading tick's whole name, which already says which list it is over. */
  selectAllName: string;
  style: Required<Pick<PlassStyleProps, 'variant' | 'size' | 'color' | 'density'>>;
  /** The heading's id, which names the list. */
  titleId: string;
  /** The list, for the focus a move whose rows were refused lands on. */
  listRef: React.Ref<HTMLDivElement>;
  /** Each row's checkbox, for the focus a move hands to the first row that arrived. */
  rowRef: (value: string, element: HTMLElement | null) => void;
}

function Panel({
  title,
  rows,
  ticked,
  onTick,
  onTickAll,
  search,
  onSearch,
  searchable,
  disabled,
  height,
  emptyLabel,
  searchLabel,
  selectAllName,
  style,
  titleId,
  listRef,
  rowRef
}: PanelProps) {
  const { variant, size, color, density } = style;
  const movable = rows.filter((row) => !row.disabled);
  const tickedHere = movable.filter((row) => ticked.has(row.value));
  const all = movable.length > 0 && tickedHere.length === movable.length;
  const some = tickedHere.length > 0 && !all;
  const insetX = paddingXClasses[density][size];

  return (
    <div
      className={cx(
        'flex min-w-0 flex-col overflow-hidden',
        fieldRestClasses[variant],
        radiusClasses[size]
      )}
      style={surfaceSlots(color, 0)}
    >
      <div className={cx(headerClasses, insetX, panelPadY[size])}>
        <PlCheckbox
          size={size}
          color={color}
          checked={all}
          indeterminate={some}
          disabled={disabled || movable.length === 0}
          // One sentence with the list's name in it, so the two lists' ticks
          // are told apart by ear as they are by eye. See `nameOf`.
          aria-label={selectAllName}
          onCheckedChange={(next) => onTickAll(next === true)}
        />
        <span
          id={titleId}
          className={cx('min-w-0 flex-1 truncate font-medium', metaTextClasses[size])}
        >
          {title}
        </span>
        <span
          className={cx('shrink-0 tabular-nums text-(--plass-muted-fg)', metaTextClasses[size])}
        >
          {tickedHere.length}/{rows.length}
        </span>
      </div>

      {searchable ? (
        <div className={cx(insetX, panelPadY[size])}>
          <PlTextField
            size={size}
            color={color}
            density={density}
            fullWidth
            variant="ghost"
            disabled={disabled}
            placeholder={searchLabel}
            aria-label={searchLabel}
            value={search}
            onChange={(event) => onSearch(event.target.value)}
          />
        </div>
      ) : null}

      <div
        ref={listRef}
        // A group named by its heading, and focusable from script only: it is
        // where the focus lands after a move whose rows did not arrive.
        role="group"
        aria-labelledby={titleId}
        tabIndex={-1}
        className={cx(
          'min-h-0 flex-1 overflow-y-auto overscroll-contain',
          'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:[outline-offset:-2px]'
        )}
        style={height === undefined ? undefined : { height }}
      >
        <div className={cx('flex flex-col', insetX, panelPadY[size])}>
          {rows.length === 0 ? (
            <span className={cx('text-(--plass-muted-fg)', metaTextClasses[size], rowPadY[size])}>
              {emptyLabel}
            </span>
          ) : (
            rows.map((row) => (
              <Row
                key={row.value}
                value={row.value}
                label={row.label}
                checked={ticked.has(row.value)}
                disabled={disabled || row.disabled === true}
                size={size}
                color={color}
                onTick={onTick}
                rowRef={rowRef}
              />
            ))
          )}
        </div>
      </div>
    </div>
  );
}

/**
 * A heading as words a sentence can hold.
 *
 * The label pack says the heading tick's name as one sentence with the list's
 * name in it, so that a language can put the name where its own grammar puts
 * it — Korean and Japanese before the verb, English after it. A sentence takes
 * a string and a heading may be a node, so the node is read for its text, and
 * one with none, such as a lone icon, is called by the pack's name for the list.
 */
function nameOf(heading: React.ReactNode, fallback: string): string {
  const text = textOf(heading).trim();

  return text === '' ? fallback : text;
}

/**
 * One side's rows, narrowed by what was typed at that side's box.
 *
 * The fold is `searchText`, the same one a `PlCommandPalette` uses, so `cafe`
 * finds `Café` on both. A label that is a node rather than a string has no text
 * to match and **stays**: the alternative is a row that disappears from a
 * filter it could never satisfy.
 */
function narrow(rows: readonly PlTransferItem[], query: string): readonly PlTransferItem[] {
  const needle = searchText(query);

  if (needle === '') return rows;

  return rows.filter(
    (item) => typeof item.label !== 'string' || searchText(item.label).includes(needle)
  );
}

/**
 * Two lists and the arrows between them: everything that could be chosen on one
 * side, everything that has been on the other.
 *
 * It is the shape for a choice that is *long* — the columns in a report, the
 * permissions on a role, the people on a channel — where a `PlCombobox` with
 * forty chips in its field stops being readable and a list of forty checkboxes
 * gives no answer to "what did I actually pick". Below about a dozen options,
 * one of those two is the smaller component.
 *
 * The order of `items` is the order both lists show, so a row does not move when
 * it is sent across and back. What ticks are for is choosing which rows to move;
 * `value` is which side they are on, and the two are deliberately separate —
 * **ticking is not choosing**.
 */
export const PlTransfer = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlTransferProps>(
  function PlTransfer(
    {
      items,
      value,
      defaultValue,
      onValueChange,
      sourceLabel: sourceLabelProp,
      targetLabel: targetLabelProp,
      searchable = false,
      searchLabel: searchLabelProp,
      emptyLabel: emptyLabelProp,
      selectAllLabel: selectAllLabelProp,
      toTargetLabel: toTargetLabelProp,
      toSourceLabel: toSourceLabelProp,
      movedLabel: movedLabelProp,
      height = 220,
      disabled = false,
      variant = 'glass',
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      className,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const labels = useLabels();
    const sourceLabel = sourceLabelProp ?? labels.transferAvailable;
    const targetLabel = targetLabelProp ?? labels.transferSelected;
    const searchLabel = searchLabelProp ?? labels.search;
    const emptyLabel = emptyLabelProp ?? labels.empty;
    // A caller's words go before the name, which is what `selectAllLabel` has
    // always meant; the pack's sentence places the name itself.
    const selectAllLabel =
      selectAllLabelProp === undefined
        ? labels.transferSelectAll
        : (list: string) => [selectAllLabelProp, list].filter(Boolean).join(' ');
    const toTargetLabel = toTargetLabelProp ?? labels.transferToSelected;
    const toSourceLabel = toSourceLabelProp ?? labels.transferToAvailable;
    const movedLabel = movedLabelProp ?? labels.transferMoved;
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';
    const density = densityProp ?? defaults.density ?? 'default';

    const [uncontrolled, setUncontrolled] = React.useState<readonly string[]>(defaultValue ?? []);
    const selected = value ?? uncontrolled;

    const [ticked, setTicked] = React.useState<ReadonlySet<string>>(() => new Set());

    /*
     * A tick says "this row moves on the next press", and a row that has left
     * `items` is not going to move. Nothing reads a tick without narrowing to
     * the rows first, so an abandoned one draws nothing and counts for nothing
     * — until the value comes back, and comes back ticked with its arrow
     * pressable. So a render that finds a tick with no row drops it, and React
     * renders again before anything is painted; a render that finds none sets
     * no state.
     */
    const present = React.useMemo(() => new Set(items.map((item) => item.value)), [items]);

    if ([...ticked].some((item) => !present.has(item))) {
      setTicked(new Set([...ticked].filter((item) => present.has(item))));
    }

    const [sourceSearch, setSourceSearch] = React.useState('');
    const [targetSearch, setTargetSearch] = React.useState('');

    const baseId = React.useId();
    const rowRefs = React.useRef(new Map<string, HTMLElement>());
    const sourceListRef = React.useRef<HTMLDivElement>(null);
    const targetListRef = React.useRef<HTMLDivElement>(null);
    const pendingMove = React.useRef<{ ids: string[]; toTarget: boolean } | null>(null);
    const [announcement, setAnnouncement] = React.useState<{ key: number; text: string } | null>(
      null
    );

    // Both of these, and `tick` below, keep their identity across renders:
    // they are what every `Row` is handed, and a new function each render would
    // draw every row again for every tick.
    const rowRef = React.useCallback((item: string, element: HTMLElement | null) => {
      if (element) rowRefs.current.set(item, element);
      else rowRefs.current.delete(item);
    }, []);

    const chosen = React.useMemo(() => new Set(selected), [selected]);
    const source = React.useMemo(
      () => items.filter((item) => !chosen.has(item.value)),
      [items, chosen]
    );
    const target = React.useMemo(
      () => items.filter((item) => chosen.has(item.value)),
      [items, chosen]
    );

    const commit = (next: string[]) => {
      if (value === undefined) setUncontrolled(next);
      onValueChange?.(next);
    };

    const tick = React.useCallback((item: string, on: boolean) => {
      setTicked((current) => {
        const next = new Set(current);

        if (on) next.add(item);
        else next.delete(item);

        return next;
      });
    }, []);

    const tickAll = (rows: readonly PlTransferItem[], on: boolean) => {
      setTicked((current) => {
        const next = new Set(current);

        for (const row of rows) {
          if (row.disabled) continue;
          if (on) next.add(row.value);
          else next.delete(row.value);
        }

        return next;
      });
    };

    /*
     * Moving drops the ticks on what moved and keeps the rest. A row that has
     * arrived on the other side is not still waiting to be sent there, and a
     * row the filter was hiding was never part of this press.
     */
    const move = (moving: readonly PlTransferItem[], toTarget: boolean) => {
      const moved = moving.filter((item) => !item.disabled && ticked.has(item.value));

      if (moved.length === 0) return;

      const ids = new Set(moved.map((item) => item.value));
      const next = toTarget
        ? items
            .filter((item) => chosen.has(item.value) || ids.has(item.value))
            .map((item) => item.value)
        : selected.filter((item) => !ids.has(item));

      pendingMove.current = { ids: moved.map((item) => item.value), toTarget };
      setTicked((current) => new Set([...current].filter((item) => !ids.has(item))));
      commit(next);
    };

    /*
     * After a move, the focus goes where the rows went. The pressed arrow is
     * disabled by the same render, since nothing on its side is ticked any
     * more, and a disabled button drops the focus to `body`: a keyboard reader
     * is thrown to the top of the page with no word about what happened. So the
     * first row that arrived takes it, and the live region says how many did.
     * A controlled pair whose owner refused the rows sends the focus to the
     * list they were sent to and says nothing, because nothing moved.
     */
    React.useLayoutEffect(() => {
      const pending = pendingMove.current;

      if (!pending) return;

      pendingMove.current = null;

      const arrived = pending.ids.filter((item) => chosen.has(item) === pending.toTarget);
      const list = pending.toTarget ? targetListRef.current : sourceListRef.current;

      if (arrived.length === 0) {
        list?.focus();
        return;
      }

      (rowRefs.current.get(arrived[0]) ?? list)?.focus();

      // The list by the words its heading draws, which is the name its tick
      // says as well, so a heading given as an element is not called by the
      // pack's word here and by its own everywhere else.
      const name = pending.toTarget
        ? nameOf(targetLabel, labels.transferSelected)
        : nameOf(sourceLabel, labels.transferAvailable);

      setAnnouncement((current) => ({
        key: (current?.key ?? 0) + 1,
        text: movedLabel(arrived.length, name)
      }));
      // `ticked` is what changes on every move, including one whose rows the
      // owner refused, so the effect runs after each press either way.
    }, [chosen, ticked, labels, movedLabel, sourceLabel, targetLabel]);

    const sourceRows = narrow(source, sourceSearch);
    const targetRows = narrow(target, targetSearch);
    const canSend = sourceRows.some((item) => !item.disabled && ticked.has(item.value));
    const canReturn = targetRows.some((item) => !item.disabled && ticked.has(item.value));
    const listHeight = toLength(height);

    const panelStyle = { variant, size, color, density };
    const sourceTitle = hasContent(sourceLabel) ? sourceLabel : labels.transferAvailable;
    const targetTitle = hasContent(targetLabel) ? targetLabel : labels.transferSelected;
    const arrowVariant: PlassVariant = variant === 'ghost' ? 'ghost' : 'glass';

    return (
      <div
        ref={ref}
        className={cx(
          'grid w-full items-center gap-3',
          '[grid-template-columns:minmax(0,1fr)_auto_minmax(0,1fr)]',
          className
        )}
        {...props}
      >
        <Panel
          title={sourceTitle}
          titleId={`${baseId}-source`}
          listRef={sourceListRef}
          rowRef={rowRef}
          rows={sourceRows}
          ticked={ticked}
          onTick={tick}
          onTickAll={(on) => tickAll(sourceRows, on)}
          search={sourceSearch}
          onSearch={setSourceSearch}
          searchable={searchable}
          disabled={disabled}
          height={listHeight}
          emptyLabel={emptyLabel}
          searchLabel={searchLabel}
          selectAllName={selectAllLabel(nameOf(sourceTitle, labels.transferAvailable))}
          style={panelStyle}
        />

        <div className="flex flex-col gap-2">
          <PlIconButton
            size={size}
            color={color}
            variant={arrowVariant}
            label={toTargetLabel}
            disabled={disabled || !canSend}
            onClick={() => move(sourceRows, true)}
            // The glyph is drawn pointing right, and the selected list is at the
            // inline end, which is the left under RTL, so it turns there.
            icon={
              <span className="flex rtl:rotate-180">
                <ArrowRightIcon />
              </span>
            }
          />
          <PlIconButton
            size={size}
            color={color}
            variant={arrowVariant}
            label={toSourceLabel}
            disabled={disabled || !canReturn}
            onClick={() => move(targetRows, false)}
            // The same glyph turned, which is the one allowance the no-transform
            // rule makes. A rotation is physical, so it is turned back under RTL,
            // where the available list is on the right.
            icon={
              <span className="flex rotate-180 rtl:rotate-0">
                <ArrowRightIcon />
              </span>
            }
          />
        </div>

        <Panel
          title={targetTitle}
          titleId={`${baseId}-target`}
          listRef={targetListRef}
          rowRef={rowRef}
          rows={targetRows}
          ticked={ticked}
          onTick={tick}
          onTickAll={(on) => tickAll(targetRows, on)}
          search={targetSearch}
          onSearch={setTargetSearch}
          searchable={searchable}
          disabled={disabled}
          height={listHeight}
          emptyLabel={emptyLabel}
          searchLabel={searchLabel}
          selectAllName={selectAllLabel(nameOf(targetTitle, labels.transferSelected))}
          style={panelStyle}
        />

        {/* How many rows the last press moved, said once. The words are a new
            node for every move, so a second move of the same size is announced
            again rather than read as text that did not change. */}
        <div className={srOnlyClasses} aria-live="polite">
          {announcement ? <span key={announcement.key}>{announcement.text}</span> : null}
        </div>
      </div>
    );
  }
);
