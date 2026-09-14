'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { Collapsible as BaseUICollapsible } from '@base-ui/react/collapsible';
import { ChevronIcon } from '../../internal/icons.js';
import {
  controlTextLeadingClasses,
  cx,
  focusRingClasses,
  gapClasses,
  iconClasses,
  radiusClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassDensity, PlassSize } from '../../types.js';

/**
 * A branch's children, and the height they travel over.
 *
 * `height` from Base UI's measured `--collapsible-panel-height` down to 0, plus
 * `overflow-hidden` so the rows are clipped rather than squashed while they
 * move — the same two lines a `PlCollapsible`'s panel is written with, at the
 * same slow duration, because what is moving in all three cases is the page
 * under the thing being pressed.
 *
 * Base UI decides when the rows exist. It renders the panel's contents while
 * the branch is open and while it is closing, which is what pays for the
 * animation: rows dropped from the document on the frame the twisty turns have
 * nothing to travel. Once the fold is shut it renders nothing, which takes the
 * rows off the accessibility tree and out of the tab order, and since the rows
 * are a component inside the panel, a shut branch does not build them either.
 */
const groupClasses = /* @__PURE__ */ [
  'h-(--collapsible-panel-height) overflow-hidden',
  '[transition:height_var(--plass-duration-slow)_var(--plass-ease)]',
  'data-[starting-style]:h-0 data-[ending-style]:h-0'
].join(' ');

/** One node. A branch is a node with `children`; a leaf is one without. */
export interface PlTreeNode {
  /** What identifies it. Unique across the whole tree. */
  id: string;
  /** What the row says. */
  label: React.ReactNode;
  /** A glyph before the label. */
  icon?: React.ReactNode;
  /** Its own children. An **empty array is a branch with nothing in it**, which
   * is not the same as a leaf: the first opens and shows nothing, the second
   * has no twisty at all. `undefined` is the leaf. */
  children?: readonly PlTreeNode[];
  /** In the tree but not selectable, and not a stop for the arrow keys. */
  disabled?: boolean;
}

/** How many rows a click can leave selected. */
export type PlTreeSelection = 'none' | 'single' | 'multiple';

export interface PlTreeProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /** The whole tree, as data. */
  items: readonly PlTreeNode[];
  /** The ids of the branches that are open. Use with `onExpandedChange` to control them. */
  expanded?: readonly string[];
  /** The branches that start open, for an uncontrolled tree. */
  defaultExpanded?: readonly string[];
  onExpandedChange?: (expanded: string[]) => void;
  /** The ids of the selected rows. Use with `onSelectedChange` to control them. */
  selected?: readonly string[];
  /** What starts selected, for an uncontrolled tree. */
  defaultSelected?: readonly string[];
  onSelectedChange?: (selected: string[]) => void;
  /**
   * How many rows a click can leave selected.
   *
   * `single` by default. `none` makes the tree a browser rather than a
   * chooser — every row still expands, and a click reports through
   * `onItemClick` without anything staying lit.
   * @default 'single'
   */
  selection?: PlTreeSelection;
  /** Called when a row is clicked, selectable or not. */
  onItemClick?: (node: PlTreeNode) => void;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** @default 'default' */
  density?: PlassDensity;
}

/** How far one level is indented, per size. Multiplied by the level. */
const indentValues: Record<PlassSize, number> = {
  xs: 14,
  sm: 16,
  md: 20,
  lg: 24,
  xl: 28
};

const rowPaddingClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'py-1', sm: 'py-1', md: 'py-1.5', lg: 'py-2', xl: 'py-2.5' },
  compact: { xs: 'py-0.5', sm: 'py-0.5', md: 'py-1', lg: 'py-1', xl: 'py-1.5' }
};

/** Every row the arrow keys can reach, in the order they are drawn. */
function visibleRows(
  items: readonly PlTreeNode[],
  expanded: ReadonlySet<string>,
  level = 1,
  into: Array<{ node: PlTreeNode; level: number }> = []
): Array<{ node: PlTreeNode; level: number }> {
  for (const node of items) {
    into.push({ node, level });

    if (node.children && expanded.has(node.id)) {
      visibleRows(node.children, expanded, level + 1, into);
    }
  }

  return into;
}

/** Every node's parent, `null` at the top. */
function parentsOf(
  items: readonly PlTreeNode[],
  parent: string | null = null,
  into = new Map<string, string | null>()
): Map<string, string | null> {
  for (const node of items) {
    into.set(node.id, parent);

    if (node.children) {
      parentsOf(node.children, node.id, into);
    }
  }

  return into;
}

/** What a row does when it is pressed or given a key. */
interface TreeActions {
  press: (node: PlTreeNode) => void;
  keyDown: (event: React.KeyboardEvent, node: PlTreeNode, level: number) => void;
}

/**
 * What every row reads that is the same for all of them.
 *
 * `actions` is a ref rather than two functions, because the functions close
 * over the visible rows and the open branches and are new on every render. As
 * props they would draw every row again each time the focus moved, which is
 * the cost a memoised row is there to avoid. A row calls them from an event,
 * never while it is drawn. `focus` is the state setter itself, which never
 * changes.
 */
interface TreeShared {
  size: PlassSize;
  density: PlassDensity;
  selection: PlTreeSelection;
  idPrefix: string;
  parents: ReadonlyMap<string, string | null>;
  focus: (id: string) => void;
  actions: React.RefObject<TreeActions | null>;
}

const TreeContext = /* @__PURE__ */ React.createContext<TreeShared | null>(null);

interface TreeRowsProps {
  items: readonly PlTreeNode[];
  level: number;
  /** The branch the rows are in, or `null` at the top. */
  parent: string | null;
  /** The tree's tab stop, when it is one of these rows or under one of them. */
  tabStop: string | null;
  expanded: ReadonlySet<string>;
  selected: ReadonlySet<string>;
}

/** One level of rows. */
function TreeRows({ items, level, parent, tabStop, expanded, selected }: TreeRowsProps) {
  const { parents } = React.useContext(TreeContext)!;

  // The one row the tab stop is at or under, found by walking up from the stop
  // rather than down every row. Every other row is handed no stop at all, so a
  // row the focus did not pass through is not drawn again.
  let path: string | null = null;

  for (let at = tabStop; at !== null && parents.has(at); at = parents.get(at)!) {
    if (parents.get(at) === parent) {
      path = at;
      break;
    }
  }

  return (
    <>
      {items.map((node) => {
        const hasRows = node.children !== undefined && node.children.length > 0;

        return (
          <TreeRow
            key={node.id}
            node={node}
            level={level}
            isOpen={expanded.has(node.id)}
            isSelected={selected.has(node.id)}
            tabStop={node.id === path ? tabStop : null}
            // Only a branch with rows in it is handed the two sets, so opening
            // a branch or selecting a row does not draw every leaf again.
            expanded={hasRows ? expanded : undefined}
            selected={hasRows ? selected : undefined}
          />
        );
      })}
    </>
  );
}

interface TreeRowProps {
  node: PlTreeNode;
  level: number;
  isOpen: boolean;
  isSelected: boolean;
  /** The tree's tab stop, when it is this row or a row under it. */
  tabStop: string | null;
  /** What the rows under a branch read. Passed only to a branch with rows. */
  expanded?: ReadonlySet<string>;
  selected?: ReadonlySet<string>;
}

/**
 * One row, and the branch under it.
 *
 * Memoised, and handed only what it draws, so moving the focus one step draws
 * the row it left, the row it reached and the branches they are in, rather
 * than every row the tree has loaded.
 */
const TreeRow = /* @__PURE__ */ React.memo(function TreeRow({
  node,
  level,
  isOpen,
  isSelected,
  tabStop,
  expanded,
  selected
}: TreeRowProps) {
  const { size, density, selection, idPrefix, focus, actions } = React.useContext(TreeContext)!;
  const isBranch = node.children !== undefined;

  return (
    <>
      <div
        id={`${idPrefix}-${node.id}`}
        role="treeitem"
        aria-level={level}
        aria-expanded={isBranch ? isOpen : undefined}
        aria-selected={selection === 'none' ? undefined : isSelected}
        aria-disabled={node.disabled || undefined}
        tabIndex={node.disabled ? undefined : tabStop === node.id ? 0 : -1}
        onFocus={() => focus(node.id)}
        onKeyDown={(event) => {
          if (node.disabled) return;
          actions.current?.keyDown(event, node, level);
        }}
        onClick={() => {
          if (node.disabled) return;
          actions.current?.press(node);
        }}
        className={cx(
          'flex cursor-pointer items-center select-none',
          gapClasses[size],
          rowPaddingClasses[density][size],
          controlTextLeadingClasses[size],
          radiusClasses[size],
          focusRingClasses,
          transitionClasses,
          iconClasses,
          node.disabled
            ? 'cursor-not-allowed opacity-50'
            : isSelected
              ? 'bg-(--p-soft) text-(--p-accent) font-medium'
              : 'text-(--plass-fg) hover:bg-(--p-soft)'
        )}
        style={{ paddingInlineStart: `${(level - 1) * indentValues[size] + 6}px` }}
      >
        {/* Turned, not swapped — and the turn has to name itself, because the
            house transition carries colour and depth and deliberately carries
            no `rotate`. It used to carry the house transition alone, which on
            a span whose only colour is a constant was a transition of nothing
            at all: the twisty jumped between its two angles, and it is the
            only thing on a row that says whether the branch is open. Written
            as an accordion's and a select's chevrons write it. */}
        <span
          aria-hidden="true"
          className={cx(
            'flex shrink-0 items-center text-(--plass-muted-fg)',
            '[transition:rotate_var(--plass-duration)_var(--plass-ease)]',
            // A leaf keeps the twisty's space rather than losing it, so every
            // label at one level starts on the same edge.
            isBranch ? '' : 'invisible',
            isOpen ? 'rotate-0' : '-rotate-90 rtl:rotate-90'
          )}
        >
          <ChevronIcon />
        </span>

        {node.icon ? <span className="flex shrink-0 items-center">{node.icon}</span> : null}

        <span className="truncate">{node.label}</span>
      </div>

      {expanded && selected ? (
        <BaseUICollapsible.Root open={isOpen}>
          <BaseUICollapsible.Panel role="group" className={groupClasses}>
            <TreeRows
              items={node.children!}
              level={level + 1}
              parent={node.id}
              tabStop={tabStop}
              expanded={expanded}
              selected={selected}
            />
          </BaseUICollapsible.Panel>
        </BaseUICollapsible.Root>
      ) : null}
    </>
  );
});

/**
 * A hierarchy, opened one branch at a time.
 *
 * It takes its nodes as **data** rather than as children, which is the opposite
 * of what most of this library does and is the right way round here for one
 * reason: a tree is recursive, and recursion written in JSX is a component
 * every caller has to write for themselves. `PlTable` takes its columns the
 * same way and for the same reason.
 *
 * The keyboard is the ARIA tree pattern and it is most of what makes this a
 * tree rather than a nested list: **one tab stop** for the whole thing, the up
 * and down arrows walking the rows that are actually visible, and the left and
 * right arrows opening a branch, stepping into it, and going back out to the
 * parent. A tree where Tab walked four hundred rows would be one nobody reaches
 * the end of.
 */
export const PlTree = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlTreeProps>(function PlTree(
  {
    items,
    expanded: expandedProp,
    defaultExpanded,
    onExpandedChange,
    selected: selectedProp,
    defaultSelected,
    onSelectedChange,
    selection = 'single',
    onItemClick,
    size: sizeProp,
    color: colorProp,
    density: densityProp,
    className,
    style,
    ...props
  },
  ref
) {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';

  const [uncontrolledExpanded, setUncontrolledExpanded] = React.useState<readonly string[]>(
    defaultExpanded ?? []
  );
  const expandedList = expandedProp ?? uncontrolledExpanded;
  const expanded = React.useMemo(() => new Set(expandedList), [expandedList]);

  const [uncontrolledSelected, setUncontrolledSelected] = React.useState<readonly string[]>(
    defaultSelected ?? []
  );
  const selectedList = selectedProp ?? uncontrolledSelected;
  const selected = React.useMemo(() => new Set(selectedList), [selectedList]);

  const rows = React.useMemo(() => visibleRows(items, expanded), [items, expanded]);
  const parents = React.useMemo(() => parentsOf(items), [items]);

  // The one row the whole tree hands `Tab` to. It follows the focus rather than
  // leading it, so tabbing back into a tree returns to where you left it.
  const [tabStop, setTabStop] = React.useState<string | null>(null);
  const reachable = React.useMemo(() => rows.filter((row) => !row.node.disabled), [rows]);
  const current =
    tabStop && reachable.some((row) => row.node.id === tabStop)
      ? tabStop
      : (reachable[0]?.node.id ?? null);

  const setExpanded = (next: string[]) => {
    if (expandedProp === undefined) {
      setUncontrolledExpanded(next);
    }

    onExpandedChange?.(next);
  };

  const toggle = (id: string, open?: boolean) => {
    const shouldOpen = open ?? !expanded.has(id);
    const next = shouldOpen
      ? [...expandedList.filter((entry) => entry !== id), id]
      : expandedList.filter((entry) => entry !== id);

    setExpanded(next);
  };

  const select = (node: PlTreeNode) => {
    if (selection === 'none') {
      return;
    }

    const next =
      selection === 'multiple'
        ? selected.has(node.id)
          ? selectedList.filter((entry) => entry !== node.id)
          : [...selectedList, node.id]
        : [node.id];

    if (selectedProp === undefined) {
      setUncontrolledSelected(next);
    }

    onSelectedChange?.(next);
  };

  const press = (node: PlTreeNode) => {
    if (node.children !== undefined) toggle(node.id);
    select(node);
    onItemClick?.(node);
  };

  const idPrefix = React.useId();

  const focusRow = (id: string) => {
    setTabStop(id);
    document.getElementById(`${idPrefix}-${id}`)?.focus();
  };

  const onKeyDown = (event: React.KeyboardEvent, node: PlTreeNode, level: number) => {
    const index = reachable.findIndex((row) => row.node.id === node.id);
    const isBranch = node.children !== undefined;
    const isOpen = expanded.has(node.id);

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();
        if (reachable[index + 1]) focusRow(reachable[index + 1].node.id);
        break;
      case 'ArrowUp':
        event.preventDefault();
        if (reachable[index - 1]) focusRow(reachable[index - 1].node.id);
        break;
      case 'ArrowRight':
        event.preventDefault();
        // Open, then step in. Two presses rather than one, which is the pattern
        // and is what lets a reader open a branch without leaving the row that
        // told them it was there.
        if (isBranch && !isOpen) toggle(node.id, true);
        else if (isBranch && reachable[index + 1]) focusRow(reachable[index + 1].node.id);
        break;
      case 'ArrowLeft': {
        event.preventDefault();
        if (isBranch && isOpen) {
          toggle(node.id, false);
          break;
        }
        // Out to the parent, which is the nearest row above at a shallower
        // level — the tree is flat by the time the keyboard sees it.
        for (let back = index - 1; back >= 0; back -= 1) {
          if (reachable[back].level < level) {
            focusRow(reachable[back].node.id);
            break;
          }
        }
        break;
      }
      case 'Home':
        event.preventDefault();
        if (reachable[0]) focusRow(reachable[0].node.id);
        break;
      case 'End':
        event.preventDefault();
        if (reachable.length) focusRow(reachable[reachable.length - 1].node.id);
        break;
      case 'Enter':
      case ' ':
        event.preventDefault();
        press(node);
        break;
      default:
        break;
    }
  };

  const actions = React.useRef<TreeActions | null>(null);

  // After every commit, so a row's event always reaches the functions of the
  // render that drew it.
  React.useLayoutEffect(() => {
    actions.current = { press, keyDown: onKeyDown };
  });

  const shared = React.useMemo<TreeShared>(
    () => ({ size, density, selection, idPrefix, parents, focus: setTabStop, actions }),
    [size, density, selection, idPrefix, parents]
  );

  return (
    <div
      ref={ref}
      role="tree"
      aria-multiselectable={selection === 'multiple' || undefined}
      className={cx('flex flex-col', className)}
      style={{ ...surfaceSlots(color, 0), ...style }}
      {...props}
    >
      <TreeContext.Provider value={shared}>
        <TreeRows
          items={items}
          level={1}
          parent={null}
          tabStop={current}
          expanded={expanded}
          selected={selected}
        />
      </TreeContext.Provider>
    </div>
  );
});
