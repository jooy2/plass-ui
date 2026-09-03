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
 * The branch is built whether or not it is open, which is what pays for the
 * animation: rows that are dropped from the document on the frame the twisty
 * turns have nothing to travel. Base UI is what decides whether they are
 * *mounted*, and it takes them off the accessibility tree and out of the tab
 * order the moment the fold is shut. **A tree big enough for that to cost
 * anything should load its branches instead**, which is what `children:
 * undefined` on an unopened branch is for.
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

  // The one row the whole tree hands `Tab` to. It follows the focus rather than
  // leading it, so tabbing back into a tree returns to where you left it.
  const [tabStop, setTabStop] = React.useState<string | null>(null);
  const reachable = rows.filter((row) => !row.node.disabled);
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

  const idPrefix = React.useId();
  const rowId = (id: string) => `${idPrefix}-${id}`;

  const focusRow = (id: string) => {
    setTabStop(id);
    document.getElementById(rowId(id))?.focus();
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
        if (isBranch) toggle(node.id);
        select(node);
        onItemClick?.(node);
        break;
      default:
        break;
    }
  };

  const renderRow = ({ node, level }: { node: PlTreeNode; level: number }) => {
    const isBranch = node.children !== undefined;
    const isOpen = expanded.has(node.id);
    const isSelected = selected.has(node.id);

    return (
      <React.Fragment key={node.id}>
        <div
          id={rowId(node.id)}
          role="treeitem"
          aria-level={level}
          aria-expanded={isBranch ? isOpen : undefined}
          aria-selected={selection === 'none' ? undefined : isSelected}
          aria-disabled={node.disabled || undefined}
          tabIndex={node.disabled ? undefined : current === node.id ? 0 : -1}
          onFocus={() => setTabStop(node.id)}
          onKeyDown={(event) => {
            if (node.disabled) return;
            onKeyDown(event, node, level);
          }}
          onClick={() => {
            if (node.disabled) return;
            if (isBranch) toggle(node.id);
            select(node);
            onItemClick?.(node);
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

        {isBranch && node.children!.length > 0 ? (
          <BaseUICollapsible.Root open={isOpen}>
            <BaseUICollapsible.Panel role="group" className={groupClasses}>
              {node.children!.map((child) => renderRow({ node: child, level: level + 1 }))}
            </BaseUICollapsible.Panel>
          </BaseUICollapsible.Root>
        ) : null}
      </React.Fragment>
    );
  };

  return (
    <div
      ref={ref}
      role="tree"
      aria-multiselectable={selection === 'multiple' || undefined}
      className={cx('flex flex-col', className)}
      style={{ ...surfaceSlots(color, 0), ...style }}
      {...props}
    >
      {items.map((node) => renderRow({ node, level: 1 }))}
    </div>
  );
});
