'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { Menu as BaseUIMenu } from '@base-ui/react/menu';
import { ContextMenu as BaseUIContextMenu } from '@base-ui/react/context-menu';
import { MenuContext } from '../../internal/menu.js';
import { CheckIcon, ChevronIcon, DotIcon } from '../../internal/icons.js';
import {
  controlTextLeadingClasses,
  cx,
  gapClasses,
  glassClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  radiusClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassAlign,
  PlassColor,
  PlassDensity,
  PlassSide,
  PlassSize,
  PlassStyleProps
} from '../../types.js';

/**
 * A menu takes `size`, `color` and `density` and stops there.
 *
 * There is no `variant`, for the reason `PlModal` has none: the three materials
 * answer "how much does this surface assert itself against the page", and a
 * popup that has taken the pointer has already answered it. There is no
 * `elevation` either — a menu genuinely floats, which is the one case the
 * ladder exists for, so it is fixed at its top rung.
 */
interface MenuSurfaceProps extends Pick<PlassStyleProps, 'size' | 'color' | 'density'> {
  className?: string;
  style?: React.CSSProperties;
}

export interface PlMenuProps extends MenuSurfaceProps {
  /**
   * The element that opens the menu, wired up by Base UI. Optional — a
   * controlled menu opened from elsewhere needs no trigger of its own.
   */
  trigger?: React.ReactElement;
  /** Whether the menu is open. Use with `onOpenChange` for a controlled menu. */
  open?: boolean;
  /** Whether it starts open, for an uncontrolled one. */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Which edge of the trigger it hangs off. @default 'bottom' */
  side?: PlassSide;
  /** Where it sits along that edge. @default 'start' */
  align?: PlassAlign;
  /** Distance from the trigger, in pixels. @default 6 */
  sideOffset?: number;
  /** Whether the page behind is taken away while the menu is open. @default true */
  modal?: boolean;
  /**
   * Opens on hover as well as on click. For a menu bar, where crossing the row
   * with an open menu should walk through the others rather than close them.
   * @default false
   */
  openOnHover?: boolean;
  /** Whether the arrow keys wrap from the last row back to the first. @default true */
  loopFocus?: boolean;
  /** Unavailable. The trigger stops opening anything. */
  disabled?: boolean;
  /** The rows. */
  children?: React.ReactNode;
}

export interface PlContextMenuProps extends MenuSurfaceProps {
  /** The rows, exactly as they are written inside a `PlMenu`. */
  content: React.ReactNode;
  /**
   * The area that answers a right-click or a long press. Rendered inside a
   * `<div>` of Base UI's, which is what listens for the gesture.
   */
  children: React.ReactNode;
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** @default true */
  loopFocus?: boolean;
  disabled?: boolean;
}

export interface PlMenuItemProps {
  /** What the row does. Not given, and not a link, the row is a label. */
  onClick?: (event: React.MouseEvent<HTMLElement>) => void;
  /** Renders the row as a real `<a>`. A menu of links has to be links. */
  href?: string;
  /** Where the link opens — `_blank` and the rest. Ignored without `href`. */
  target?: string;
  /** Content before the label — an icon, a swatch, a check. */
  startIcon?: React.ReactNode;
  /** Content after the label, before any `shortcut`. */
  endIcon?: React.ReactNode;
  /**
   * The keystroke that does the same thing, set at the end of the row and
   * muted. Text only — the row does not bind it, the application does.
   */
  shortcut?: React.ReactNode;
  /** A second line under the label, one step down the type scale and muted. */
  description?: React.ReactNode;
  /**
   * Re-points the row's colour family — `danger` for the one that deletes.
   * Defaults to the menu's own.
   */
  color?: PlassColor;
  /** Whether picking the row closes the menu. @default true */
  closeOnClick?: boolean;
  /** Unavailable. Still listed, and still found by typeahead. */
  disabled?: boolean;
  /** What typeahead matches against, when the label is not a plain string. */
  label?: string;
  /** The label. */
  children?: React.ReactNode;
  className?: string;
  style?: React.CSSProperties;
}

export interface PlMenuSubmenuProps {
  /** The label on the row that opens it. */
  label?: React.ReactNode;
  startIcon?: React.ReactNode;
  disabled?: boolean;
  /** Which edge of the parent row it opens against. @default 'right' */
  side?: PlassSide;
  /** Distance from the parent menu, in pixels. @default 4 */
  sideOffset?: number;
  /** The nested rows. */
  children?: React.ReactNode;
  className?: string;
  style?: React.CSSProperties;
}

export interface PlMenuGroupProps {
  /** The heading over the group. Wired to it by Base UI. */
  label?: React.ReactNode;
  children?: React.ReactNode;
  className?: string;
  style?: React.CSSProperties;
}

export interface PlMenuCheckboxItemProps extends Omit<
  PlMenuItemProps,
  'href' | 'target' | 'startIcon' | 'onClick'
> {
  checked?: boolean;
  defaultChecked?: boolean;
  onCheckedChange?: (checked: boolean) => void;
  /**
   * Whether ticking the row closes the menu. `false` here, against the `true` a
   * plain row takes: a list of things to tick is a list you tick more than one
   * of.
   * @default false
   */
  closeOnClick?: boolean;
}

export interface PlMenuRadioGroupProps {
  value?: string | number;
  defaultValue?: string | number;
  onValueChange?: (value: string | number) => void;
  disabled?: boolean;
  children?: React.ReactNode;
  className?: string;
  style?: React.CSSProperties;
}

export interface PlMenuRadioItemProps extends Omit<
  PlMenuItemProps,
  'href' | 'target' | 'startIcon' | 'onClick'
> {
  /** What this row sets the group to. */
  value: string | number;
  /** @default false */
  closeOnClick?: boolean;
}

export type PlMenuSeparatorProps = React.ComponentPropsWithoutRef<'div'>;

/* ---------------------------------------------------------------------------
 * The surface
 * ------------------------------------------------------------------------- */

/**
 * The popup, which is `PlSelect`'s popup to the pixel — deliberately, because a
 * select *is* a menu that remembers what you picked, and two floating lists of
 * rows that do not match are two lists the eye has to learn separately.
 */
const popupClasses = /* @__PURE__ */ [
  glassClasses,
  'max-h-[min(24rem,var(--available-height))] min-w-40 overflow-y-auto overscroll-contain',
  'border bg-(--plass-glass-press) p-1',
  '[border-color:var(--plass-glass-line)]',
  '[box-shadow:var(--plass-shadow-3),var(--plass-gloss-glass)]',
  '[outline:none]',
  // Opacity only. A menu that slides in has moved the row you were already
  // reaching for, which is the one thing a menu must never do.
  '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

/**
 * A row's padding, and a ladder of its own rather than the sheet track.
 *
 * A `PlList` row spans a sheet that something else decided the width of; a menu
 * row is inside a popup that is exactly as wide as its longest label. The sheet
 * track's `px-5` at `md` would add 40px to a menu that says "Cut", which is how
 * a five-row menu ends up the width of a dialog.
 */
const rowPaddingClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: {
    xs: 'px-1.5 py-0.5',
    sm: 'px-2 py-1',
    md: 'px-2.5 py-1.5',
    lg: 'px-3 py-2',
    xl: 'px-3.5 py-2.5'
  },
  compact: {
    xs: 'px-1 py-0.5',
    sm: 'px-1.5 py-0.5',
    md: 'px-2 py-1',
    lg: 'px-2.5 py-1',
    xl: 'px-3 py-1.5'
  }
};

/**
 * A row sits one step down the radius ladder from the popup it is inside: a
 * tile cut out of a sheet cannot carry the sheet's own corner, or the two curves
 * fight along the edge.
 */
const rowRadiusClasses: Record<PlassSize, string> = {
  xs: radiusClasses.xs,
  sm: radiusClasses.xs,
  md: radiusClasses.sm,
  lg: radiusClasses.sm,
  xl: radiusClasses.md
};

/**
 * The row, in every one of its shapes — plain, link, submenu trigger, checkbox,
 * radio. They differ in which Base UI part renders them and in nothing else.
 *
 * `data-highlighted` rather than `:hover`, exactly as on a `PlSelect` option: it
 * is also what the arrow keys move, so the mouse and the keyboard light the same
 * row instead of the keyboard lighting nothing.
 *
 * `accented` is a parameter rather than a class the caller appends, and that is
 * not a style preference. Appending `text-(--p-accent)` next to the default
 * `text-(--plass-fg)` puts two utilities of equal specificity on one element,
 * and which of them wins is decided by their order in the generated stylesheet
 * rather than by the order they were written in — so `color="danger"` on a row
 * would silently do nothing. Branching here is what makes only one of the two
 * exist.
 */
function rowClasses(
  size: PlassSize,
  density: PlassDensity,
  accented: boolean,
  className?: string
): string {
  return cx(
    'relative flex w-full cursor-pointer items-center select-none',
    accented ? 'text-(--p-accent)' : 'text-(--plass-fg)',
    rowPaddingClasses[density][size],
    rowRadiusClasses[size],
    gapClasses[size],
    controlTextLeadingClasses[size],
    transitionClasses,
    iconClasses,
    'data-[highlighted]:bg-(--p-soft-hover)',
    'data-[popup-open]:bg-(--p-soft)',
    'data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50',
    // Base UI moves focus onto the highlighted row itself, so a ring here would
    // draw a rectangle inside the popup on every arrow press. The tint is the
    // focus indicator, which is what makes it the same one the mouse gets.
    '[outline:none]',
    className
  );
}

/** The fixed-width slot a check, a dot or a `startIcon` lands in. */
const slotClasses = 'flex h-[1lh] w-[1.2em] shrink-0 items-center justify-center';

/** The muted run of text a shortcut is set in, at the end of the row. */
function shortcutClasses(size: PlassSize): string {
  return cx('ms-2 shrink-0 text-(--plass-muted-fg) tabular-nums', metaTextClasses[size]);
}

/**
 * The label, and the description under it when there is one.
 *
 * `min-w-0` so a long label truncates rather than pushing the shortcut off the
 * end of a popup that has already been positioned.
 */
function RowBody({
  children,
  description,
  size
}: {
  children: React.ReactNode;
  description?: React.ReactNode;
  size: PlassSize;
}) {
  if (!hasContent(description)) {
    return <span className="min-w-0 flex-1 truncate text-start">{children}</span>;
  }

  return (
    <span className="flex min-w-0 flex-1 flex-col text-start">
      <span className="truncate">{children}</span>
      <span className={cx('truncate text-(--plass-muted-fg)', metaTextClasses[size])}>
        {description}
      </span>
    </span>
  );
}

/* ---------------------------------------------------------------------------
 * The parts
 * ------------------------------------------------------------------------- */

/**
 * One row of a menu.
 *
 * Renders a real `<a>` when it is given an `href` and Base UI's own item
 * otherwise — the same split `PlListItem` makes, for the same reason. A menu of
 * links that are not links cannot be opened in a new tab, cannot be copied, and
 * tells a screen reader the wrong thing about every one of them.
 */
export function PlMenuItem({
  onClick,
  href,
  target,
  startIcon,
  endIcon,
  shortcut,
  description,
  color,
  closeOnClick = true,
  disabled = false,
  label,
  children,
  className,
  style
}: PlMenuItemProps) {
  const { size, density } = React.useContext(MenuContext);

  const body = (
    <>
      {hasContent(startIcon) ? (
        <span className={cx(slotClasses, 'text-(--plass-muted-fg)')}>{startIcon}</span>
      ) : null}
      <RowBody description={description} size={size}>
        {children}
      </RowBody>
      {hasContent(endIcon) ? (
        <span className={cx(slotClasses, 'text-(--plass-muted-fg)')}>{endIcon}</span>
      ) : null}
      {hasContent(shortcut) ? <span className={shortcutClasses(size)}>{shortcut}</span> : null}
    </>
  );

  // A row can name its own family — `color="danger"` on the one that deletes —
  // and the slots are re-declared on the row so the tint, the hairline and the
  // text all turn over together rather than one of them staying indigo.
  const slots = color ? surfaceSlots(color, 0) : undefined;
  const rowStyle = slots || style ? { ...slots, ...style } : undefined;

  if (href !== undefined) {
    return (
      <BaseUIMenu.LinkItem
        href={href}
        target={target}
        label={label}
        closeOnClick={closeOnClick}
        onClick={onClick}
        className={rowClasses(size, density, Boolean(color), className)}
        style={rowStyle}
      >
        {body}
      </BaseUIMenu.LinkItem>
    );
  }

  return (
    <BaseUIMenu.Item
      disabled={disabled}
      label={label}
      closeOnClick={closeOnClick}
      onClick={onClick}
      className={rowClasses(size, density, Boolean(color), className)}
      style={rowStyle}
    >
      {body}
    </BaseUIMenu.Item>
  );
}

/** A row that ticks. The tick lands in the same slot a `startIcon` would. */
export function PlMenuCheckboxItem({
  checked,
  defaultChecked,
  onCheckedChange,
  endIcon,
  shortcut,
  description,
  color,
  closeOnClick = false,
  disabled = false,
  label,
  children,
  className,
  style
}: PlMenuCheckboxItemProps) {
  const { size, density } = React.useContext(MenuContext);
  const slots = color ? surfaceSlots(color, 0) : undefined;

  return (
    <BaseUIMenu.CheckboxItem
      checked={checked}
      defaultChecked={defaultChecked}
      onCheckedChange={(next) => onCheckedChange?.(next)}
      disabled={disabled}
      label={label}
      closeOnClick={closeOnClick}
      className={rowClasses(size, density, Boolean(color), className)}
      style={slots || style ? { ...slots, ...style } : undefined}
    >
      <span className={cx(slotClasses, 'text-(--p-accent)')}>
        <BaseUIMenu.CheckboxItemIndicator className="flex items-center justify-center">
          <CheckIcon />
        </BaseUIMenu.CheckboxItemIndicator>
      </span>
      <RowBody description={description} size={size}>
        {children}
      </RowBody>
      {hasContent(endIcon) ? (
        <span className={cx(slotClasses, 'text-(--plass-muted-fg)')}>{endIcon}</span>
      ) : null}
      {hasContent(shortcut) ? <span className={shortcutClasses(size)}>{shortcut}</span> : null}
    </BaseUIMenu.CheckboxItem>
  );
}

/** One choice out of a set. Wraps the rows that make up the set. */
export function PlMenuRadioGroup({
  value,
  defaultValue,
  onValueChange,
  disabled = false,
  children,
  className,
  style
}: PlMenuRadioGroupProps) {
  return (
    <BaseUIMenu.RadioGroup
      value={value}
      defaultValue={defaultValue}
      onValueChange={(next) => onValueChange?.(next as string | number)}
      disabled={disabled}
      className={className}
      style={style}
    >
      {children}
    </BaseUIMenu.RadioGroup>
  );
}

/**
 * A row inside a `PlMenuRadioGroup`.
 *
 * Marked with a dot rather than a tick, which is the same distinction
 * `PlCheckbox` and `PlRadioGroup` make everywhere else: a tick says "and", a dot
 * says "instead of".
 */
export function PlMenuRadioItem({
  value,
  endIcon,
  shortcut,
  description,
  color,
  closeOnClick = false,
  disabled = false,
  label,
  children,
  className,
  style
}: PlMenuRadioItemProps) {
  const { size, density } = React.useContext(MenuContext);
  const slots = color ? surfaceSlots(color, 0) : undefined;

  return (
    <BaseUIMenu.RadioItem
      value={value}
      disabled={disabled}
      label={label}
      closeOnClick={closeOnClick}
      className={rowClasses(size, density, Boolean(color), className)}
      style={slots || style ? { ...slots, ...style } : undefined}
    >
      <span className={cx(slotClasses, 'text-(--p-accent)')}>
        <BaseUIMenu.RadioItemIndicator className="flex items-center justify-center">
          <DotIcon />
        </BaseUIMenu.RadioItemIndicator>
      </span>
      <RowBody description={description} size={size}>
        {children}
      </RowBody>
      {hasContent(endIcon) ? (
        <span className={cx(slotClasses, 'text-(--plass-muted-fg)')}>{endIcon}</span>
      ) : null}
      {hasContent(shortcut) ? <span className={shortcutClasses(size)}>{shortcut}</span> : null}
    </BaseUIMenu.RadioItem>
  );
}

/** A named run of rows. The label is a heading, not a row — it cannot be picked. */
export function PlMenuGroup({ label, children, className, style }: PlMenuGroupProps) {
  const { size, density } = React.useContext(MenuContext);

  return (
    <BaseUIMenu.Group className={className} style={style}>
      {hasContent(label) ? (
        <BaseUIMenu.GroupLabel
          className={cx(
            rowPaddingClasses[density][size],
            metaTextClasses[size],
            'font-semibold tracking-wide text-(--plass-muted-fg) uppercase'
          )}
        >
          {label}
        </BaseUIMenu.GroupLabel>
      ) : null}
      {children}
    </BaseUIMenu.Group>
  );
}

/** The hairline between two runs of rows. */
export function PlMenuSeparator({ className, ...props }: PlMenuSeparatorProps) {
  return (
    <BaseUIMenu.Separator
      className={cx('-mx-1 my-1 h-px bg-(--plass-divider)', className)}
      {...props}
    />
  );
}

/**
 * A menu inside a menu.
 *
 * The row that opens it is the same row every other item is, wearing a chevron —
 * and it opens on hover, on <kbd>Enter</kbd> and on the arrow key that points at
 * it, all of which is Base UI's. What is here is the surface and the glyph.
 *
 * Nesting is unlimited: a `PlMenuSubmenu` renders its children inside a popup
 * that is itself a menu, so a submenu of a submenu needs no different component.
 */
export function PlMenuSubmenu({
  label,
  startIcon,
  disabled = false,
  side = 'right',
  sideOffset = 4,
  children,
  className,
  style
}: PlMenuSubmenuProps) {
  const { size, density, color } = React.useContext(MenuContext);

  return (
    <BaseUIMenu.SubmenuRoot>
      <BaseUIMenu.SubmenuTrigger disabled={disabled} className={rowClasses(size, density, false)}>
        {hasContent(startIcon) ? (
          <span className={cx(slotClasses, 'text-(--plass-muted-fg)')}>{startIcon}</span>
        ) : null}
        <span className="min-w-0 flex-1 truncate text-start">{label}</span>
        {/*
          The chevron is drawn pointing down and turned — the one allowance the
          no-transform rule makes, because a glyph has no text in it to resample.
        */}
        <span className={cx(slotClasses, 'text-(--plass-muted-fg) -rotate-90')}>
          <ChevronIcon />
        </span>
      </BaseUIMenu.SubmenuTrigger>

      <BaseUIMenu.Portal>
        <BaseUIMenu.Positioner
          className="plass-portal z-(--plass-z-portal) [outline:none]"
          side={side}
          sideOffset={sideOffset}
          align="start"
        >
          <BaseUIMenu.Popup
            className={cx(
              popupClasses,
              radiusClasses[size],
              controlTextLeadingClasses[size],
              className
            )}
            style={{ ...surfaceSlots(color, 3), ...style }}
          >
            {children}
          </BaseUIMenu.Popup>
        </BaseUIMenu.Positioner>
      </BaseUIMenu.Portal>
    </BaseUIMenu.SubmenuRoot>
  );
}

/**
 * A list of actions that appears when something is pressed.
 *
 * Everything that makes a menu a menu rather than a floating list of `<div>`s is
 * Base UI's: roving focus with the arrow keys, <kbd>Home</kbd> and
 * <kbd>End</kbd>, typeahead, <kbd>Esc</kbd>, closing on an outside click,
 * restoring focus to the trigger, submenus opening on hover with the safe
 * triangle so a diagonal reach does not close them, and the `menu` / `menuitem`
 * roles that make any of it mean something to a screen reader. What is here is
 * the surface, the ladders and the row layout.
 *
 * The rows are **composed rather than passed as data** — the opposite of
 * `PlSelect`, and deliberately. A select's options are values from a list a
 * caller already has; a menu's rows are *code*, each one a different handler, a
 * different icon, sometimes a submenu. Data would mean an `items` type with a
 * variant for every shape a row can take, which is a component tree spelled as a
 * discriminated union.
 */
export function PlMenu({
  size: sizeProp,
  color: colorProp,
  density: densityProp,
  trigger,
  open,
  defaultOpen,
  onOpenChange,
  side = 'bottom',
  align = 'start',
  sideOffset = 6,
  modal = true,
  openOnHover = false,
  loopFocus = true,
  disabled = false,
  className,
  style,
  children
}: PlMenuProps) {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';

  const context = React.useMemo(() => ({ size, color, density }), [size, color, density]);

  return (
    <MenuContext.Provider value={context}>
      <BaseUIMenu.Root
        open={open}
        defaultOpen={defaultOpen}
        onOpenChange={(next) => onOpenChange?.(next)}
        modal={modal}
        loopFocus={loopFocus}
        disabled={disabled}
      >
        {trigger ? (
          <BaseUIMenu.Trigger render={trigger} openOnHover={openOnHover} disabled={disabled} />
        ) : null}

        <BaseUIMenu.Portal>
          {/*
            `plass-portal` is a hook, not a style: a portalled popup leaves the
            subtree a host may have scoped its CSS reset to, and this is what
            such a host can hang the same reset off.
          */}
          <BaseUIMenu.Positioner
            className="plass-portal z-(--plass-z-portal) [outline:none]"
            side={side}
            align={align}
            sideOffset={sideOffset}
          >
            <BaseUIMenu.Popup
              className={cx(
                popupClasses,
                radiusClasses[size],
                controlTextLeadingClasses[size],
                className
              )}
              style={{ ...surfaceSlots(color, 3), ...style }}
            >
              {children}
            </BaseUIMenu.Popup>
          </BaseUIMenu.Positioner>
        </BaseUIMenu.Portal>
      </BaseUIMenu.Root>
    </MenuContext.Provider>
  );
}

/**
 * The same menu, opened by a right-click or a long press instead of by a button.
 *
 * It takes the rows as `content` and the area as `children`, which is
 * `PlTooltip`'s shape rather than `PlMenu`'s — because here the trigger is not
 * one element you hand over, it is a region of the page, and the region is the
 * thing being wrapped. Base UI positions the popup at the pointer rather than
 * against an anchor, and the long press is what makes it reachable on a touch
 * screen at all.
 */
export function PlContextMenu({
  size: sizeProp,
  color: colorProp,
  density: densityProp,
  content,
  children,
  open,
  defaultOpen,
  onOpenChange,
  loopFocus = true,
  disabled = false,
  className,
  style
}: PlContextMenuProps) {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';

  const context = React.useMemo(() => ({ size, color, density }), [size, color, density]);

  return (
    <MenuContext.Provider value={context}>
      <BaseUIContextMenu.Root
        open={open}
        defaultOpen={defaultOpen}
        onOpenChange={(next) => onOpenChange?.(next)}
        loopFocus={loopFocus}
        disabled={disabled}
      >
        <BaseUIContextMenu.Trigger>{children}</BaseUIContextMenu.Trigger>

        <BaseUIContextMenu.Portal>
          <BaseUIContextMenu.Positioner className="plass-portal z-(--plass-z-portal) [outline:none]">
            <BaseUIContextMenu.Popup
              className={cx(
                popupClasses,
                radiusClasses[size],
                controlTextLeadingClasses[size],
                className
              )}
              style={{ ...surfaceSlots(color, 3), ...style }}
            >
              {content}
            </BaseUIContextMenu.Popup>
          </BaseUIContextMenu.Positioner>
        </BaseUIContextMenu.Portal>
      </BaseUIContextMenu.Root>
    </MenuContext.Provider>
  );
}
