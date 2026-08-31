'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { Autocomplete } from '@base-ui/react/autocomplete';
import { Dialog as BaseUIDialog } from '@base-ui/react/dialog';
import { PlHotKeys } from '../hot-keys/PlHotKeys.js';
// The same vocabulary `PlHotKeys` draws, bound rather than written — a shortcut
// a component displays and a shortcut it binds must be spelled the same way, or
// the cap on the screen is a claim nobody checked.
import { usePlHotKeys } from '../../hooks/usePlHotKeys.js';
import { searchHaystack, searchText } from '../../internal/search.js';
import {
  controlTextLeadingClasses,
  cx,
  glassClasses,
  hasContent,
  metaTextClasses,
  radiusClasses,
  surfaceSlots,
  toLength
} from '../../internal/styles.js';
import type { PlassPortalClassNames, PlassSize, PlassStyleProps } from '../../types.js';

/** One thing the palette can do. */
export interface PlCommandItem {
  /** What identifies the command. */
  value: string;
  /** What the row says, and what the query is matched against. */
  label: string;
  /** A second line under it — where the command goes, or what it changes. */
  description?: React.ReactNode;
  /** A glyph before the label. */
  icon?: React.ReactNode;
  /**
   * The keystroke that does the same thing, set at the end of the row. Written
   * the way `PlHotKeys` writes them, so `Mod` resolves per platform. The palette
   * **does not bind it** — the application does.
   */
  shortcut?: string;
  /**
   * The heading this command sits under. Commands are drawn in the order they
   * are given, and a heading is drawn each time the group changes — so a
   * group's commands have to be listed together.
   */
  group?: string;
  /**
   * Extra words the query is matched against but that are never drawn — the
   * name somebody else's product gives the same command, an abbreviation, the
   * word a reader would have searched for.
   */
  keywords?: readonly string[];
  /** In the list but not runnable. */
  disabled?: boolean;
  /** What running it does. */
  onSelect?: () => void;
}

export interface PlCommandPaletteProps extends Pick<PlassStyleProps, 'size' | 'color' | 'density'> {
  /** Everything the palette can do. */
  items: readonly PlCommandItem[];
  /** Whether the palette is open. Use with `onOpenChange` for a controlled one. */
  open?: boolean;
  /** Whether it starts open, for an uncontrolled one. @default false */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * Called when a command is run, after its own `onSelect`. The palette closes
   * either way.
   */
  onSelect?: (item: PlCommandItem) => void;
  /**
   * The keystroke that opens the palette, bound on the window. Written the way
   * `PlHotKeys` writes them, so `Mod` is Command on a Mac and Control everywhere
   * else. `false` binds nothing.
   * @default 'Mod+K'
   */
  shortcut?: string | false;
  /** How wide the sheet may get. A number of pixels or any CSS length. */
  width?: number | string;
  /** How tall the list may get before it scrolls. @default 320 */
  maxHeight?: number | string;
  /** The placeholder in the field. @default 'Search commands' */
  placeholder?: string;
  /** The line where the rows would be, when nothing matched. @default 'No commands found' */
  emptyMessage?: React.ReactNode;
  /** The accessible name of the dialog, which has no visible title. @default 'Command palette' */
  label?: string;
  /** Classes on the sheet, alongside the component's own. */
  className?: string;
  /** Inline styles on the sheet, applied over the tokens it sets. */
  style?: React.CSSProperties;
  /** Classes on the parts a `className` does not reach. */
  classNames?: PlassPortalClassNames;
}

const backdropClasses = /* @__PURE__ */ [
  'fixed inset-0 z-(--plass-z-portal) bg-(--plass-scrim)',
  '[backdrop-filter:blur(2px)] [-webkit-backdrop-filter:blur(2px)]',
  '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

const popupClasses = /* @__PURE__ */ [
  glassClasses,
  'relative flex w-full flex-col overflow-hidden',
  'border text-(--plass-fg) bg-(--plass-glass-press)',
  '[border-color:var(--plass-glass-line)]',
  '[box-shadow:var(--plass-shadow-3),var(--plass-gloss-glass)]',
  '[outline:none]',
  // Opacity only. A palette that slid in would move the row a reader is already
  // reaching for, which is the one thing a list under a cursor must never do.
  '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

const widthClasses: Record<PlassSize, string> = {
  xs: 'max-w-sm',
  sm: 'max-w-md',
  md: 'max-w-xl',
  lg: 'max-w-2xl',
  xl: 'max-w-3xl'
};

/**
 * The field's own height, and its own ladder.
 *
 * A palette's field is not a control in a row of controls — it is the top of a
 * sheet, and it is the one thing on screen. `md` is 48px, one step above the
 * control ladder, for the same reason a search field in a browser's own command
 * bar is taller than a form field.
 */
const inputHeights: Record<PlassSize, string> = {
  xs: 'h-9',
  sm: 'h-10',
  md: 'h-12',
  lg: 'h-14',
  xl: 'h-16'
};

const rowPadY: Record<PlassSize, string> = {
  xs: 'py-1',
  sm: 'py-1.5',
  md: 'py-2',
  lg: 'py-2.5',
  xl: 'py-3'
};

/**
 * A row's gutter, and its own ladder rather than the sheet track.
 *
 * The same decision a `PlMenu` row makes: the sheet track's `px-5` at `md`
 * would add forty pixels to a palette row that says "Copy".
 */
const insetX: Record<PlassSize, string> = {
  xs: 'px-2.5',
  sm: 'px-3',
  md: 'px-3.5',
  lg: 'px-4',
  xl: 'px-5'
};

const rowClasses = /* @__PURE__ */ [
  'flex cursor-pointer items-center gap-3 select-none',
  '[transition:background-color_var(--plass-duration)_var(--plass-ease)]',
  // The highlight is Base UI's, and it is one thing rather than two: the pointer
  // and the arrow keys move the same mark, so a reader never has to work out
  // which of two highlighted rows Enter would run.
  'data-[highlighted]:bg-(--p-soft) data-[highlighted]:text-(--p-accent)',
  'data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50',
  'data-[disabled]:saturate-[0.35]'
].join(' ');

/**
 * Everything a command answers to, folded into one string.
 *
 * `searchHaystack` is the same fold a `PlTransfer`'s filter uses, which is the
 * point of it being shared: `cafe` finds `Café` in both, and a reader who has
 * learned what one search box does has learned what the other does.
 */
function haystackOf(item: PlCommandItem): string {
  return searchHaystack([item.label, item.group, ...(item.keywords ?? [])]);
}

/**
 * Everything an application can do, behind one field.
 *
 * The shape a keyboard-first product takes once it has more actions than a menu
 * bar can hold: a reader types what they want instead of remembering where it
 * was put.
 *
 * It is not a `PlMenu` — a menu is a short list in one place, and every row is
 * visible before you look for it. It is not a `PlCombobox` either: what comes
 * back is not a value, it is *something happening*.
 *
 * Base UI's Autocomplete owns the list — the highlight the pointer and the arrow
 * keys share, `aria-activedescendant`, Enter running the highlighted row — and
 * its Dialog owns the sheet, the scrim, the focus trap and returning the focus
 * to wherever the reader was.
 */
export function PlCommandPalette({
  items,
  open,
  defaultOpen = false,
  onOpenChange,
  onSelect,
  shortcut = 'Mod+K',
  width,
  maxHeight = 320,
  placeholder = 'Search commands',
  emptyMessage = 'No commands found',
  label = 'Command palette',
  size: sizeProp,
  color: colorProp,
  density: densityProp,
  className,
  classNames,
  style
}: PlCommandPaletteProps): React.ReactElement {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';

  const [uncontrolled, setUncontrolled] = React.useState(defaultOpen);
  const [query, setQuery] = React.useState('');

  const showing = open ?? uncontrolled;

  const setOpen = React.useCallback(
    (next: boolean) => {
      if (open === undefined) setUncontrolled(next);
      onOpenChange?.(next);
    },
    [open, onOpenChange]
  );

  // `whileTyping`, because a palette is reached from wherever the reader is —
  // including the field they are halfway through filling in. `Mod+K` carries a
  // modifier and would be answered there anyway; a caller who sets `shortcut`
  // to a bare key means it.
  usePlHotKeys(shortcut === false ? undefined : { [shortcut]: () => setOpen(true) }, {
    whileTyping: true
  });

  // Folded once per list rather than once per comparison — `searchText`
  // normalizes, and doing that inside the filter puts a `normalize` on every
  // command for every character typed.
  const haystacks = React.useMemo(() => items.map(haystackOf), [items]);

  const filtered = React.useMemo(() => {
    const needle = searchText(query);

    return needle === '' ? items : items.filter((_, index) => haystacks[index].includes(needle));
  }, [items, haystacks, query]);

  const run = (item: PlCommandItem) => {
    if (item.disabled) return;

    item.onSelect?.();
    onSelect?.(item);
    setOpen(false);
  };

  const sheetWidth = toLength(width);
  const listHeight = toLength(maxHeight);

  return (
    <BaseUIDialog.Root
      open={showing}
      onOpenChange={(next) => {
        // The query is dropped on the way out rather than on the way in, so the
        // sheet never flashes the last search as it fades.
        if (!next) setQuery('');
        setOpen(next);
      }}
    >
      <BaseUIDialog.Portal>
        <BaseUIDialog.Backdrop
          className={cx('plass-portal', backdropClasses, classNames?.backdrop)}
        />

        <BaseUIDialog.Viewport className="plass-portal fixed inset-0 z-(--plass-z-portal) flex justify-center p-4 pt-[12vh]">
          <BaseUIDialog.Popup
            aria-label={label}
            className={cx(
              popupClasses,
              radiusClasses[size],
              controlTextLeadingClasses[size],
              sheetWidth === undefined ? widthClasses[size] : '',
              'self-start',
              className
            )}
            style={{
              ...surfaceSlots(color, 3),
              ...(sheetWidth === undefined ? null : { maxWidth: sheetWidth }),
              ...style
            }}
          >
            <Autocomplete.Root
              open
              mode="list"
              // Already filtered here, so that a group heading can be drawn from
              // the same array the rows come out of.
              items={filtered}
              filter={null}
              value={query}
              onValueChange={(next) => setQuery(next)}
              itemToStringValue={(item: PlCommandItem) => item.label}
            >
              <div
                className={cx(
                  'flex shrink-0 items-center border-b [border-color:var(--plass-glass-line)]',
                  insetX[size]
                )}
              >
                <Autocomplete.Input
                  autoFocus
                  placeholder={placeholder}
                  className={cx(
                    'min-w-0 flex-1 bg-transparent [font:inherit] text-inherit [outline:none]',
                    'placeholder:text-(--plass-muted-fg) caret-(--p-accent)',
                    'selection:bg-(--p-soft-press)',
                    inputHeights[size]
                  )}
                />
              </div>

              <Autocomplete.List
                className="min-h-0 flex-1 overflow-y-auto overscroll-contain p-1"
                style={{ maxHeight: listHeight }}
              >
                {(item: PlCommandItem, index: number) => (
                  <React.Fragment key={item.value}>
                    {item.group && item.group !== filtered[index - 1]?.group ? (
                      <div
                        role="presentation"
                        className={cx(
                          insetX[size],
                          'pt-2 pb-1 font-medium text-(--plass-muted-fg)',
                          metaTextClasses[size]
                        )}
                      >
                        {item.group}
                      </div>
                    ) : null}

                    <Autocomplete.Item
                      index={index}
                      value={item}
                      disabled={item.disabled}
                      onClick={() => run(item)}
                      className={cx(
                        rowClasses,
                        radiusClasses[size],
                        insetX[size],
                        rowPadY[density === 'compact' ? 'xs' : size]
                      )}
                    >
                      {hasContent(item.icon) ? (
                        <span className="flex h-[1lh] shrink-0 items-center [&_svg]:size-[1.15em]">
                          {item.icon}
                        </span>
                      ) : null}

                      <span className="flex min-w-0 flex-1 flex-col">
                        <span className="truncate">{item.label}</span>
                        {hasContent(item.description) ? (
                          <span
                            className={cx(
                              'truncate text-(--plass-muted-fg)',
                              metaTextClasses[size]
                            )}
                          >
                            {item.description}
                          </span>
                        ) : null}
                      </span>

                      {item.shortcut ? (
                        <PlHotKeys size="xs" keys={item.shortcut} className="shrink-0" />
                      ) : null}
                    </Autocomplete.Item>
                  </React.Fragment>
                )}
              </Autocomplete.List>

              <Autocomplete.Empty
                className={cx(
                  insetX[size],
                  'py-6 text-center text-(--plass-muted-fg)',
                  metaTextClasses[size]
                )}
              >
                {emptyMessage}
              </Autocomplete.Empty>
            </Autocomplete.Root>
          </BaseUIDialog.Popup>
        </BaseUIDialog.Viewport>
      </BaseUIDialog.Portal>
    </BaseUIDialog.Root>
  );
}
