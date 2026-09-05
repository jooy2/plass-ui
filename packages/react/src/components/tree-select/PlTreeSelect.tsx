'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { PickerShell, type PlassPickerShellProps } from '../../internal/picker.js';
import { searchHaystack, searchText } from '../../internal/search.js';
import { cx, metaTextClasses } from '../../internal/styles.js';
import { PlTextField } from '../text-field/PlTextField.js';
import { PlTree, type PlTreeNode } from '../tree/PlTree.js';

/**
 * One node of the tree a reader is choosing from.
 *
 * A `PlTree`'s node with two more answers on it, both of which only mean
 * anything once the tree is behind a field: what a filter matches the node
 * against, and whether the node is one of the answers or only the road to one.
 */
export interface PlTreeSelectNode extends PlTreeNode {
  /**
   * What a search matches against.
   *
   * `label` is a `ReactNode` and the text inside one is not something to guess
   * at, so a node whose label is anything but a string says here what it can be
   * found by. Falls back to the label when that is a string, and to the `id`
   * when it is not.
   */
  searchLabel?: string;
  /**
   * Whether this node may itself be chosen.
   *
   * Defaults to `true` for a leaf and to `selectableBranches` for a node that
   * has children. Set it either way to override both.
   */
  selectable?: boolean;
  children?: readonly PlTreeSelectNode[];
}

export interface PlTreeSelectProps extends PlassPickerShellProps {
  /** The whole tree, as data. */
  items: readonly PlTreeSelectNode[];
  /** The chosen ids. Use with `onValueChange` for a controlled picker. */
  value?: readonly string[];
  /** What starts chosen, for an uncontrolled one. */
  defaultValue?: readonly string[];
  onValueChange?: (value: string[]) => void;
  /** Whether more than one node may be held at once. @default false */
  multiple?: boolean;
  /**
   * Whether a node that has children may itself be chosen.
   *
   * Off by default, which is the shape most of these trees have: the branches
   * are the taxonomy and the leaves are the answers, and a "Europe" held
   * alongside "France" is usually a data model nobody meant. A node's own
   * `selectable` overrides it either way, and a branch that cannot be chosen
   * still opens and closes — pressing it is how you get at what is under it.
   * @default false
   */
  selectableBranches?: boolean;
  /** The ids of the branches that are open. Use with `onExpandedChange` to control them. */
  expanded?: readonly string[];
  /** The branches that start open, for an uncontrolled tree. */
  defaultExpanded?: readonly string[];
  onExpandedChange?: (expanded: string[]) => void;
  /** Whether the popup is open. Use with `onOpenChange` to control it. */
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Shown in the trigger while nothing is chosen. */
  placeholder?: React.ReactNode;
  /** Offers the × that empties the control. @default false */
  clearable?: boolean;
  /** Closes the popup as soon as a node is chosen. @default `!multiple` */
  closeOnSelect?: boolean;
  /**
   * Offers a field above the tree that filters it.
   *
   * A match keeps its ancestors, because a node with its parents cut away is a
   * node the reader cannot place — a "Seoul" under nothing at all does not say
   * which taxonomy it came out of. Every branch a filter keeps is opened, since
   * a match folded inside a shut parent is a match nobody was shown.
   * @default false
   */
  searchable?: boolean;
  /** The word in the filter field. @default 'Search' */
  searchLabel?: string;
  /** What the popup says when the filter matched nothing. @default 'Nothing here' */
  emptyLabel?: string;
  /** How the trigger writes what is held. Defaults to the labels, comma-joined. */
  format?: (chosen: PlTreeSelectNode[]) => React.ReactNode;
  /** Identifies the field when a form is submitted. One hidden input per value. */
  name?: string;
}

/** Every node, flattened, so an id can be looked up without walking twice. */
function flatten(
  items: readonly PlTreeSelectNode[],
  into: Map<string, PlTreeSelectNode> = new Map()
): Map<string, PlTreeSelectNode> {
  for (const node of items) {
    into.set(node.id, node);

    if (node.children) {
      flatten(node.children, into);
    }
  }

  return into;
}

/** What a node is matched against, folded once. */
function haystackOf(node: PlTreeSelectNode): string {
  return searchHaystack([
    node.searchLabel ?? (typeof node.label === 'string' ? node.label : node.id)
  ]);
}

/**
 * The nodes that match, and every ancestor of one.
 *
 * The ancestors are the point. A tree filtered to bare matches is a list, and a
 * list of leaves is exactly what a tree was chosen over. A node that matched
 * keeps all of its children — you asked for it, so you get what is in it — and
 * a node kept only because something under it matched keeps just that.
 */
function filterTree(items: readonly PlTreeSelectNode[], needle: string): PlTreeSelectNode[] {
  const kept: PlTreeSelectNode[] = [];

  for (const node of items) {
    const children = node.children ? filterTree(node.children, needle) : undefined;
    const hit = haystackOf(node).includes(needle);

    if (hit || (children && children.length > 0)) {
      kept.push(hit ? node : { ...node, children });
    }
  }

  return kept;
}

/** Every branch in a tree — what a filter opens so its matches are visible. */
function branchIds(items: readonly PlTreeSelectNode[], into: string[] = []): string[] {
  for (const node of items) {
    if (node.children && node.children.length > 0) {
      into.push(node.id);
      branchIds(node.children, into);
    }
  }

  return into;
}

/**
 * A value chosen out of a hierarchy rather than out of a list.
 *
 * The gap between a `PlSelect` and a `PlTree`: the first is a flat list behind
 * a field, the second is a hierarchy that shows what it holds but has no field
 * to put it in. A category, a folder, a region and an org chart node are all
 * chosen from a shape a flat list flattens away.
 *
 * It is the two of them composed and almost nothing else — the trigger is the
 * same `PickerShell` all four pickers wear, and what is in the popup is a
 * `PlTree` with a `PlTextField` over it. What it adds is the arithmetic between
 * them: which nodes a query keeps, which branches that opens, and which of the
 * ids coming back out of the tree are answers rather than roads.
 */
export const PlTreeSelect = /* @__PURE__ */ React.forwardRef<HTMLButtonElement, PlTreeSelectProps>(
  function PlTreeSelect(
    {
      items,
      value: valueProp,
      defaultValue,
      onValueChange,
      multiple = false,
      selectableBranches = false,
      expanded: expandedProp,
      defaultExpanded,
      onExpandedChange,
      open: openProp,
      defaultOpen,
      onOpenChange,
      placeholder,
      clearable = false,
      closeOnSelect,
      searchable = false,
      searchLabel: searchLabelProp,
      emptyLabel: emptyLabelProp,
      format,
      name,
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      readOnly = false,
      disabled = false,
      ...shell
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';
    const density = densityProp ?? defaults.density ?? 'default';

    const labels = useLabels();
    const searchLabel = searchLabelProp ?? labels.search;
    const emptyLabel = emptyLabelProp ?? labels.empty;

    const [uncontrolledValue, setUncontrolledValue] = React.useState<readonly string[]>(
      defaultValue ?? []
    );
    const held = valueProp ?? uncontrolledValue;

    const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen ?? false);
    const open = openProp ?? uncontrolledOpen;

    const [query, setQuery] = React.useState('');
    const needle = searchText(query);

    const byId = React.useMemo(() => flatten(items), [items]);
    const shown = React.useMemo(
      () => (needle === '' ? items : filterTree(items, needle)),
      [items, needle]
    );

    // A filter drives the folds itself, and hands them back the moment the
    // field is emptied — the branches the reader had opened are still in
    // whichever state holds them, untouched.
    const filtered = needle !== '';
    const [uncontrolledExpanded, setUncontrolledExpanded] = React.useState<readonly string[]>(
      defaultExpanded ?? []
    );
    const searchExpanded = React.useMemo(
      () => (filtered ? branchIds(shown) : undefined),
      [filtered, shown]
    );
    const expanded = searchExpanded ?? expandedProp ?? uncontrolledExpanded;

    const setOpen = (next: boolean) => {
      // A read-only picker does not open. What it holds is something to read.
      if (next && (disabled || readOnly)) {
        return;
      }

      if (openProp === undefined) {
        setUncontrolledOpen(next);
      }

      if (!next) {
        setQuery('');
      }

      onOpenChange?.(next);
    };

    const commit = (next: string[]) => {
      if (valueProp === undefined) {
        setUncontrolledValue(next);
      }

      onValueChange?.(next);
    };

    const isSelectable = (node: PlTreeSelectNode) =>
      !node.disabled &&
      (node.selectable ?? (node.children && node.children.length > 0 ? selectableBranches : true));

    /**
     * What comes back out of the tree, filtered down to the answers.
     *
     * A branch that cannot be chosen still expands, so a press on one arrives
     * here as a selection that has to be turned down rather than as nothing at
     * all. Turning it down is not the same as clearing: a single-value picker
     * hands back exactly one id, and treating an unusable one as an empty
     * answer would empty the field every time somebody opened a folder.
     */
    const onSelectedChange = (next: string[]) => {
      if (!multiple) {
        const node = next.length === 1 ? byId.get(next[0]) : undefined;

        if (!node || !isSelectable(node)) {
          return;
        }

        commit([node.id]);

        if (closeOnSelect ?? true) {
          setOpen(false);
        }

        return;
      }

      const allowed = next.filter((id) => {
        const node = byId.get(id);

        return node !== undefined && isSelectable(node);
      });

      const changed =
        allowed.length !== held.length || allowed.some((id, index) => id !== held[index]);

      if (!changed) {
        return;
      }

      commit(allowed);

      if (closeOnSelect ?? false) {
        setOpen(false);
      }
    };

    const chosen = held
      .map((id) => byId.get(id))
      .filter((node): node is PlTreeSelectNode => node !== undefined);

    const display =
      chosen.length === 0
        ? (placeholder ?? '')
        : format
          ? format(chosen)
          : chosen.map((node, index) => (
              <React.Fragment key={node.id}>
                {index === 0 ? null : ', '}
                {node.label}
              </React.Fragment>
            ));

    return (
      <PickerShell
        {...shell}
        size={size}
        color={color}
        density={density}
        readOnly={readOnly}
        disabled={disabled}
        triggerRef={ref}
        display={display}
        empty={chosen.length === 0}
        clearable={clearable}
        onClear={() => commit([])}
        open={open}
        onOpenChange={setOpen}
        labels={labels}
        hiddenValues={name ? held.map((id) => ({ name, value: id })) : undefined}
      >
        <div className="flex max-h-80 w-64 flex-col gap-1.5 overflow-hidden">
          {searchable ? (
            <PlTextField
              size={size}
              color={color}
              density={density}
              variant="ghost"
              fullWidth
              placeholder={searchLabel}
              aria-label={searchLabel}
              value={query}
              onChange={(event) => setQuery(event.target.value)}
            />
          ) : null}

          <div className="min-h-0 flex-1 overflow-y-auto overscroll-contain">
            {shown.length === 0 ? (
              <p className={cx('px-1.5 py-1 text-(--plass-muted-fg)', metaTextClasses[size])}>
                {emptyLabel}
              </p>
            ) : (
              <PlTree
                items={shown}
                size={size}
                color={color}
                density={density}
                selection={multiple ? 'multiple' : 'single'}
                selected={held}
                onSelectedChange={onSelectedChange}
                expanded={expanded}
                onExpandedChange={(next) => {
                  // While a filter is driving the folds, what the tree reports
                  // is the filter's own answer coming back. Writing it down
                  // would leave the reader's branches open once they cleared
                  // the field.
                  if (filtered) {
                    return;
                  }

                  if (expandedProp === undefined) {
                    setUncontrolledExpanded(next);
                  }

                  onExpandedChange?.(next);
                }}
              />
            )}
          </div>
        </div>
      </PickerShell>
    );
  }
);
