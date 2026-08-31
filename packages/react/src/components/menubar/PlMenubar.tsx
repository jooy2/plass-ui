'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { Menubar as BaseUIMenubar } from '@base-ui/react/menubar';
import { PlMenu } from '../menu/PlMenu.js';
import { MenuContext } from '../../internal/menu.js';
import {
  controlTextClasses,
  cx,
  gapClasses,
  hasContent,
  iconClasses,
  paddingXClasses,
  radiusClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassOrientation, PlassSize, PlassStyleProps } from '../../types.js';

export interface PlMenubarProps
  extends
    Pick<PlassStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Which way the bar runs. `vertical` is the shape a side rail of menus takes;
   * the arrow keys follow it either way.
   * @default 'horizontal'
   */
  orientation?: PlassOrientation;
  /**
   * Whether an open menu takes the page away. On — the default, and Base UI's —
   * an open menu is what the pointer is talking to.
   * @default true
   */
  modal?: boolean;
  /** Whether the arrow keys wrap around at the ends of the bar. @default true */
  loopFocus?: boolean;
  /** Disables every menu on the bar at once. */
  disabled?: boolean;
  /** The menus. */
  children?: React.ReactNode;
}

export interface PlMenubarMenuProps {
  /** The word on the bar. */
  label: React.ReactNode;
  /** Content before the label. Sized in `em`, so it tracks it. */
  startIcon?: React.ReactNode;
  /** Unavailable. The word stays on the bar and opens nothing. */
  disabled?: boolean;
  /** The rows, written exactly as they are inside a `PlMenu`. */
  children?: React.ReactNode;
  /** Classes on the word this menu is opened by, alongside the bar's own. */
  className?: string;
  /** Inline styles on that word. */
  style?: React.CSSProperties;
}

/**
 * A menu bar's own row height, one rung below the control ladder at every step.
 *
 * A menu bar is not a row of buttons — it is a strip of words, and the strip is
 * usually inside something that already has a height of its own: a `PlToolbar`,
 * a `PlHeader`. Sized as controls, `File Edit View` would be three buttons in a
 * row and would make the bar taller than the thing it is drawn on.
 */
const triggerHeights: Record<PlassSize, string> = {
  xs: 'h-4.5',
  sm: 'h-5.5',
  md: 'h-6.5',
  lg: 'h-8',
  xl: 'h-10'
};

const triggerClasses = /* @__PURE__ */ [
  'inline-flex shrink-0 cursor-pointer select-none items-center justify-center',
  'whitespace-nowrap font-medium leading-none',
  'text-(--plass-fg) bg-transparent',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  iconClasses,
  'hover:bg-(--p-soft)',
  // A menu bar is the one place where "this one is open" has to be legible from
  // across the bar, and it is still colour and nothing else: the word does not
  // move and the strip does not change height.
  'data-[popup-open]:bg-(--p-soft-hover) data-[popup-open]:text-(--p-accent)',
  // Turned inward, because a word on a strip has a neighbour a hair away on
  // each side and a ring drawn outside it would overlap them.
  'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:[outline-offset:-2px]',
  'disabled:cursor-not-allowed disabled:opacity-50 disabled:saturate-[0.35]',
  'disabled:hover:bg-transparent'
].join(' ');

/**
 * One menu on the bar: the word, and the rows behind it.
 *
 * It has no `size`, `color` or `density` of its own — all three belong to the
 * bar, which is the only place they can be set once and hold for every menu on
 * it. The rows inside are the same `PlMenuItem`, `PlMenuSeparator`,
 * `PlMenuGroup` and `PlMenuSubmenu` a `PlMenu` takes, because it *is* the same
 * menu.
 */
export function PlMenubarMenu({
  label,
  startIcon,
  disabled = false,
  children,
  className,
  style
}: PlMenubarMenuProps): React.ReactElement {
  const { size, color, density } = React.useContext(MenuContext);

  return (
    <PlMenu
      size={size}
      color={color}
      density={density}
      disabled={disabled}
      // The whole reason a menu bar is not a row of separate menus: once one of
      // them is open, crossing the bar walks through the others rather than
      // closing the one you left.
      openOnHover
      sideOffset={4}
      trigger={
        <button
          type="button"
          disabled={disabled}
          className={cx(
            triggerClasses,
            triggerHeights[size],
            controlTextClasses[size],
            gapClasses[size],
            // A word on a strip, not a key in a row: the compact track at every
            // step, because the default one would space three words like three
            // buttons.
            paddingXClasses[density === 'default' ? 'compact' : density][size],
            radiusClasses[size],
            className
          )}
          style={style}
        >
          {hasContent(startIcon) ? startIcon : null}
          {label}
        </button>
      }
    >
      {children}
    </PlMenu>
  );
}

/**
 * The strip of words at the top of an application — File, Edit, View — each of
 * which opens a menu.
 *
 * What makes it a bar rather than a row of separate menus is what happens once
 * one is open: moving along the strip walks through the others instead of
 * closing the one you left, and the arrow keys move between the menus as well
 * as inside them. Base UI owns all of that, along with the `menubar` role.
 *
 * It draws **no surface of its own**. A menu bar sits *on* something — a
 * `PlToolbar`, a `PlHeader` — and a sheet under a strip that is already on a
 * sheet is two sheets.
 */
export const PlMenubar = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlMenubarProps>(
  function PlMenubar(
    {
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      orientation = 'horizontal',
      modal = true,
      loopFocus = true,
      disabled = false,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';
    const density = densityProp ?? defaults.density ?? 'default';

    const context = React.useMemo(() => ({ size, color, density }), [size, color, density]);

    return (
      <MenuContext.Provider value={context}>
        <BaseUIMenubar
          ref={ref}
          orientation={orientation}
          modal={modal}
          loopFocus={loopFocus}
          disabled={disabled}
          className={cx(
            'flex items-center',
            orientation === 'vertical' ? 'flex-col items-stretch' : 'flex-row',
            gapClasses[size],
            className
          )}
          style={
            {
              // Four slots rather than `surfaceSlots`: the bar draws nothing, so
              // the only colour it needs is what the words light up in.
              '--p-soft': `var(--plass-${color}-soft)`,
              '--p-soft-hover': `var(--plass-${color}-soft-hover)`,
              '--p-accent': `var(--plass-${color}-accent)`,
              '--p-ring': `var(--plass-${color}-ring)`,
              ...style
            } as React.CSSProperties
          }
          {...props}
        >
          {children}
        </BaseUIMenubar>
      </MenuContext.Provider>
    );
  }
);
