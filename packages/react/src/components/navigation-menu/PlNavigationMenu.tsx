'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { NavigationMenu as BaseUINavigationMenu } from '@base-ui/react/navigation-menu';
import { ChevronIcon } from '../../internal/icons.js';
import { safeRel } from '../../internal/link.js';
import {
  controlHeightClasses,
  controlTextClasses,
  controlTextLeadingClasses,
  cx,
  focusRingClasses,
  focusRingInsetClasses,
  gapClasses,
  glassClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassDensity, PlassOrientation, PlassSize, PlassStyleProps } from '../../types.js';

/**
 * What every part of a navigation menu inherits from the root.
 *
 * The same arrangement `internal/menu.ts` makes one folder over, kept local
 * because only this component's own parts read it — an item, its trigger and the
 * links in its panel are three things that exist only inside a
 * `PlNavigationMenu`.
 */
interface NavigationMenuContextValue {
  size: PlassSize;
  density: PlassDensity;
}

const NavigationMenuContext = /* @__PURE__ */ React.createContext<NavigationMenuContextValue>({
  size: 'md',
  density: 'default'
});

export interface PlNavigationMenuProps
  extends
    Pick<PlassStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'nav'>, 'color' | 'defaultValue' | 'onChange'> {
  /**
   * Which way the row runs. `vertical` is a nav rail whose panels open beside
   * it; the arrow keys follow either way.
   * @default 'horizontal'
   */
  orientation?: PlassOrientation;
  /** Which item's panel is open, by its `value`. Nullish means closed. */
  value?: string | null;
  /** Which starts open, for an uncontrolled menu. */
  defaultValue?: string | null;
  onValueChange?: (value: string | null) => void;
  /** How long the pointer rests before a panel opens, in milliseconds. */
  delay?: number;
  /** How long a panel stays after the pointer leaves, in milliseconds. */
  closeDelay?: number;
  /** Distance from the row, in pixels. @default 8 */
  sideOffset?: number;
  /** The items. */
  children?: React.ReactNode;
}

export interface PlNavigationMenuItemProps {
  /** The word in the row. */
  label: React.ReactNode;
  /**
   * Makes the item a plain link rather than something that opens a panel. An
   * item with an `href` and no children is a destination, and it is announced
   * as one — which is the whole reason a site nav is not a `PlMenu`.
   */
  href?: string;
  /**
   * Where the link opens. Ignored without `href`.
   *
   * Anything other than this tab also gets `rel="noopener noreferrer"`, merged
   * with whatever `rel` was asked for, exactly as on `PlTextLink`.
   */
  target?: string;
  /** The link's `rel`. The two tokens a new tab needs are added to it. */
  rel?: string;
  /** Content before the label. Sized in `em`, so it tracks it. */
  startIcon?: React.ReactNode;
  /**
   * Identifies the item, for a controlled menu. Left out is fine for an
   * uncontrolled one — Base UI gives each item an identity of its own.
   */
  value?: string;
  /** Unavailable. The word stays in the row and opens nothing. */
  disabled?: boolean;
  /** How many columns the panel lays its links out in. @default 1 */
  columns?: number;
  /** The panel's contents — usually `PlNavigationMenuLink`s. */
  children?: React.ReactNode;
  /** Classes on the word in the row, alongside the component's own. */
  className?: string;
  /** Inline styles on that word. */
  style?: React.CSSProperties;
}

export interface PlNavigationMenuLinkProps extends Omit<
  React.ComponentPropsWithoutRef<'a'>,
  'color' | 'title'
> {
  /** Where it goes. */
  href: string;
  /** The row's name. */
  title: React.ReactNode;
  /** A second line under it, one step down the scale and muted. */
  description?: React.ReactNode;
  /** A glyph before the title. */
  startIcon?: React.ReactNode;
}

/**
 * The row of words.
 *
 * A nav's items sit at control height and carry **no surface at rest**: they
 * are the page's own words, not keys laid on it, and a row of five bordered
 * boxes across the top of a site is a toolbar rather than a navigation. The
 * family arrives with the pointer and with the open panel.
 */
const triggerClasses = /* @__PURE__ */ [
  'inline-flex shrink-0 cursor-pointer select-none items-center justify-center',
  'whitespace-nowrap font-medium leading-none no-underline',
  'text-(--plass-fg) bg-transparent',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  iconClasses,
  focusRingClasses,
  'hover:bg-(--p-soft)',
  'data-[popup-open]:bg-(--p-soft-hover) data-[popup-open]:text-(--p-accent)',
  // The light going out, which is what `disabled` is everywhere in the library.
  'data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50',
  'data-[disabled]:saturate-[0.35] data-[disabled]:hover:bg-transparent'
].join(' ');

/** The panel. The same frosted sheet a `PlMenu` and a `PlPopover` draw. */
const popupClasses = /* @__PURE__ */ [
  glassClasses,
  'relative border text-(--plass-fg) bg-(--plass-glass-press)',
  '[border-color:var(--plass-glass-line)]',
  '[box-shadow:var(--plass-shadow-3),var(--plass-gloss-glass)]',
  '[outline:none] overflow-hidden',
  // Opacity and the viewport's own size only. A panel that slid in would drag a
  // page's worth of links across the screen.
  '[transition:opacity_var(--plass-duration)_var(--plass-ease),width_var(--plass-duration)_var(--plass-ease),height_var(--plass-duration)_var(--plass-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

const linkClasses = /* @__PURE__ */ [
  'flex min-w-0 cursor-pointer items-start no-underline',
  'text-(--plass-fg) bg-transparent',
  transitionClasses,
  iconClasses,
  'hover:bg-(--p-soft)',
  // Turned inward: the panel clips, so a ring drawn outside a row would have
  // its top or its bottom sliced off by the popup's own overflow.
  focusRingInsetClasses
].join(' ');

/** How much room the panel keeps around its links, per step. */
const panelPaddingClasses: Record<PlassSize, string> = {
  xs: 'p-1',
  sm: 'p-1.5',
  md: 'p-2',
  lg: 'p-2.5',
  xl: 'p-3'
};

/**
 * One row inside a panel: where it goes, what it is called, and a line saying
 * what is there.
 *
 * It is a real `<a>`, which is the point of the whole component — a site's
 * navigation is a list of destinations, and a destination that is a `<div>` with
 * a click handler is not in the link list, not on the status bar and not in a
 * crawler's index.
 */
export const PlNavigationMenuLink = /* @__PURE__ */ React.forwardRef<
  HTMLAnchorElement,
  PlNavigationMenuLinkProps
>(function PlNavigationMenuLink(
  { href, title, description, startIcon, className, children, ...props },
  ref
) {
  const { size, density } = React.useContext(NavigationMenuContext);

  return (
    <BaseUINavigationMenu.Link
      ref={ref}
      href={href}
      className={cx(
        linkClasses,
        radiusClasses[size],
        gapClasses[size],
        paddingXClasses[density][size],
        'py-2',
        className
      )}
      {...props}
    >
      {hasContent(startIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center">{startIcon}</span>
      ) : null}
      <span className="flex min-w-0 flex-col gap-0.5">
        <span className={cx('font-medium', controlTextLeadingClasses[size])}>{title}</span>
        {hasContent(description) ? (
          <span className={cx('text-(--plass-muted-fg)', metaTextClasses[size])}>
            {description}
          </span>
        ) : null}
        {children}
      </span>
    </BaseUINavigationMenu.Link>
  );
});

/**
 * One word in the row, and what opens under it.
 *
 * With children it is a trigger and a panel; with an `href` and nothing else it
 * is a link, and the difference is not cosmetic — the second is announced as a
 * destination and the first as something that expands.
 */
export function PlNavigationMenuItem({
  label,
  href,
  target,
  rel,
  startIcon,
  value,
  disabled = false,
  columns = 1,
  children,
  className,
  style
}: PlNavigationMenuItemProps): React.ReactElement {
  const { size, density } = React.useContext(NavigationMenuContext);
  const isLink = href !== undefined && !hasContent(children);

  const chrome = cx(
    triggerClasses,
    controlHeightClasses[size],
    controlTextClasses[size],
    gapClasses[size],
    paddingXClasses[density][size],
    radiusClasses[size],
    className
  );

  return (
    <BaseUINavigationMenu.Item value={value}>
      {isLink ? (
        <BaseUINavigationMenu.Link
          href={href}
          target={target}
          rel={safeRel(target, rel)}
          className={chrome}
          style={style}
        >
          {hasContent(startIcon) ? startIcon : null}
          {label}
        </BaseUINavigationMenu.Link>
      ) : (
        <>
          <BaseUINavigationMenu.Trigger disabled={disabled} className={chrome} style={style}>
            {hasContent(startIcon) ? startIcon : null}
            {label}
            {/* Drawn pointing down and turned when the panel is open, which is
                the one allowance the no-transform rule makes: a glyph rotating
                is not a control moving. */}
            <BaseUINavigationMenu.Icon className="flex items-center [transition:rotate_var(--plass-duration)_var(--plass-ease)] data-[popup-open]:rotate-180">
              <ChevronIcon />
            </BaseUINavigationMenu.Icon>
          </BaseUINavigationMenu.Trigger>

          <BaseUINavigationMenu.Content
            className={cx('grid gap-1', panelPaddingClasses[size])}
            style={
              columns > 1
                ? { gridTemplateColumns: `repeat(${columns}, minmax(0, 1fr))` }
                : undefined
            }
          >
            {children}
          </BaseUINavigationMenu.Content>
        </>
      )}
    </BaseUINavigationMenu.Item>
  );
}

/**
 * A site's navigation: a row of destinations, some of which open a panel of
 * more of them.
 *
 * The difference from a `PlMenu` is what the rows *are*. A menu holds actions,
 * so its rows are `menuitem`s and the whole thing is a widget that traps the
 * arrow keys. This holds links, so it is a `<nav>` full of real `<a>`s — which
 * is what puts them in the link list, on the status bar and in a crawler's
 * index. Reach for a menu when the row *does* something and for this when the
 * row *goes* somewhere.
 *
 * One panel is open at a time and it resizes between items rather than closing
 * and reopening, which is Base UI's doing and is what makes crossing the row
 * read as one surface rather than three.
 */
export const PlNavigationMenu = /* @__PURE__ */ React.forwardRef<
  HTMLElement,
  PlNavigationMenuProps
>(function PlNavigationMenu(
  {
    size: sizeProp,
    color: colorProp,
    density: densityProp,
    orientation = 'horizontal',
    value,
    defaultValue,
    onValueChange,
    delay,
    closeDelay,
    sideOffset = 8,
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

  const context = React.useMemo(() => ({ size, density }), [size, density]);

  return (
    <NavigationMenuContext.Provider value={context}>
      <BaseUINavigationMenu.Root
        ref={ref}
        orientation={orientation}
        value={value}
        defaultValue={defaultValue}
        onValueChange={(next) => onValueChange?.(next)}
        delay={delay}
        closeDelay={closeDelay}
        className={className}
        style={{ ...surfaceSlots(color, 3), ...style }}
        {...props}
      >
        <BaseUINavigationMenu.List
          className={cx(
            'flex items-center',
            orientation === 'vertical' ? 'flex-col items-stretch' : 'flex-row',
            gapClasses[size]
          )}
        >
          {children}
        </BaseUINavigationMenu.List>

        <BaseUINavigationMenu.Portal>
          {/* `.plass-portal` is a hook, not a style: a portalled popup leaves
              the subtree a host may have scoped its CSS reset to. */}
          <BaseUINavigationMenu.Positioner
            className="plass-portal z-(--plass-z-portal) [outline:none]"
            sideOffset={sideOffset}
            collisionPadding={12}
          >
            <BaseUINavigationMenu.Popup className={cx(popupClasses, radiusClasses[size])}>
              <BaseUINavigationMenu.Viewport />
            </BaseUINavigationMenu.Popup>
          </BaseUINavigationMenu.Positioner>
        </BaseUINavigationMenu.Portal>
      </BaseUINavigationMenu.Root>
    </NavigationMenuContext.Provider>
  );
});
