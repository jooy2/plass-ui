'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { PlCheckbox } from '../checkbox/PlCheckbox.js';
import { PlIconButton } from '../icon-button/PlIconButton.js';
import { PlTextField } from '../text-field/PlTextField.js';
import { ArrowRightIcon } from '../../internal/icons.js';
import { searchText } from '../../internal/search.js';
import {
  cx,
  fieldRestClasses,
  hasContent,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  surfaceSlots,
  toLength
} from '../../internal/styles.js';
import type { PlassSize, PlassStyleProps, PlassVariant } from '../../types.js';

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
  /** What the tick in a list's heading is announced as. @default 'Select all' */
  selectAllLabel?: string;
  /** What the two arrows are announced as. */
  toTargetLabel?: string;
  toSourceLabel?: string;
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
  selectAllLabel: string;
  style: Required<Pick<PlassStyleProps, 'variant' | 'size' | 'color' | 'density'>>;
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
  selectAllLabel,
  style
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
          aria-label={selectAllLabel}
          onCheckedChange={(next) => onTickAll(next === true)}
        />
        <span className={cx('min-w-0 flex-1 truncate font-medium', metaTextClasses[size])}>
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
        className="min-h-0 flex-1 overflow-y-auto overscroll-contain"
        style={height === undefined ? undefined : { height }}
      >
        <div className={cx('flex flex-col', insetX, panelPadY[size])}>
          {rows.length === 0 ? (
            <span className={cx('text-(--plass-muted-fg)', metaTextClasses[size], rowPadY[size])}>
              {emptyLabel}
            </span>
          ) : (
            rows.map((row) => (
              <PlCheckbox
                key={row.value}
                size={size}
                color={color}
                className={rowPadY[size]}
                label={row.label}
                checked={ticked.has(row.value)}
                disabled={disabled || row.disabled}
                onCheckedChange={(next) => onTick(row.value, next === true)}
              />
            ))
          )}
        </div>
      </div>
    </div>
  );
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
      sourceLabel = 'Available',
      targetLabel = 'Selected',
      searchable = false,
      searchLabel = 'Search',
      emptyLabel = 'Nothing here',
      selectAllLabel = 'Select all',
      toTargetLabel = 'Move to selected',
      toSourceLabel = 'Move to available',
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
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';
    const density = densityProp ?? defaults.density ?? 'default';

    const [uncontrolled, setUncontrolled] = React.useState<readonly string[]>(defaultValue ?? []);
    const selected = value ?? uncontrolled;

    const [ticked, setTicked] = React.useState<ReadonlySet<string>>(() => new Set());
    const [sourceSearch, setSourceSearch] = React.useState('');
    const [targetSearch, setTargetSearch] = React.useState('');

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

    const tick = (item: string, on: boolean) => {
      setTicked((current) => {
        const next = new Set(current);

        if (on) next.add(item);
        else next.delete(item);

        return next;
      });
    };

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

      setTicked((current) => new Set([...current].filter((item) => !ids.has(item))));
      commit(next);
    };

    const sourceRows = narrow(source, sourceSearch);
    const targetRows = narrow(target, targetSearch);
    const canSend = sourceRows.some((item) => !item.disabled && ticked.has(item.value));
    const canReturn = targetRows.some((item) => !item.disabled && ticked.has(item.value));
    const listHeight = toLength(height);

    const panelStyle = { variant, size, color, density };
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
          title={hasContent(sourceLabel) ? sourceLabel : 'Available'}
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
          selectAllLabel={selectAllLabel}
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
            icon={<ArrowRightIcon />}
          />
          <PlIconButton
            size={size}
            color={color}
            variant={arrowVariant}
            label={toSourceLabel}
            disabled={disabled || !canReturn}
            onClick={() => move(targetRows, false)}
            // The same glyph turned, which is the one allowance the no-transform
            // rule makes — and it is logical, so under RTL the arrows already
            // point the way the lists are laid out.
            icon={
              <span className="flex rotate-180">
                <ArrowRightIcon />
              </span>
            }
          />
        </div>

        <Panel
          title={hasContent(targetLabel) ? targetLabel : 'Selected'}
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
          selectAllLabel={selectAllLabel}
          style={panelStyle}
        />
      </div>
    );
  }
);
