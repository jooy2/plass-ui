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
  orientation: PlassOrientation;
}

const NavigationMenuContext = /* @__PURE__ */ React.createContext<NavigationMenuContextValue>({
  size: 'md',
  density: 'default',
  orientation: 'horizontal'
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
  /**
   * The page the reader is on. A link item is marked `aria-current="page"` and
   * drawn in the accent, so the row says where the reader is as well as where
   * they can go. Ignored on an item that opens a panel.
   */
  active?: boolean;
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
  // The page the reader is on, in the same accent an open panel's word takes.
  'aria-[current=page]:text-(--p-accent)',
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
  // The size of the panel it holds, which the root measures. Unset until a
  // panel has been measured, which leaves the sheet `auto`.
  'w-(--p-panel-w) h-(--p-panel-h)',
  '[transition-duration:var(--plass-duration)] [transition-timing-function:var(--plass-ease)]',
  'motion-reduce:[transition-duration:0ms]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

/**
 * What the sheet eases: its opacity always, and its size only while one panel
 * is following another. Opening at the size of what it opens with is not a
 * resize, and a panel that slid in would drag a page's worth of links across
 * the screen. Under reduced motion both arrive at once, and while Base UI holds
 * the positioner still for a window resize the size does.
 */
const popupFadeClasses = '[transition-property:opacity]';
const popupResizeClasses = /* @__PURE__ */ [
  '[transition-property:opacity,width,height]',
  'motion-reduce:[transition-property:opacity] in-data-[instant]:[transition-property:opacity]'
].join(' ');

/**
 * The box the sheet sits in, at the size the sheet is going to, so it is
 * placed once for where the sheet ends up rather than again on every frame of
 * the resize. Its place eases only while one panel is following another: the
 * first place of an opening panel is not a move, and one that eased after a
 * scroll would trail the row it hangs from.
 */
const positionerClasses = /* @__PURE__ */ [
  'plass-portal z-(--plass-z-portal) [outline:none]',
  'w-(--p-panel-w) h-(--p-panel-h)',
  '[transition-duration:var(--plass-duration)] [transition-timing-function:var(--plass-ease)]'
].join(' ');
const positionerStillClasses = '[transition-property:none]';
const positionerMoveClasses = /* @__PURE__ */ [
  '[transition-property:top,left,right,bottom]',
  'motion-reduce:[transition-property:none] data-[instant]:[transition-property:none]'
].join(' ');

/** The lengths a change of panel eases, on the sheet and on its box. */
const easedProperties = /* @__PURE__ */ new Set([
  'width',
  'height',
  'top',
  'left',
  'right',
  'bottom'
]);

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
  { href, title, description, startIcon, className, children, target, rel, ...props },
  ref
) {
  const { size, density } = React.useContext(NavigationMenuContext);

  return (
    <BaseUINavigationMenu.Link
      ref={ref}
      href={href}
      target={target}
      rel={safeRel(target, rel)}
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
  active = false,
  columns = 1,
  children,
  className,
  style
}: PlNavigationMenuItemProps): React.ReactElement {
  const { size, density, orientation } = React.useContext(NavigationMenuContext);
  const isLink = href !== undefined && !hasContent(children);

  const chrome = cx(
    triggerClasses,
    // Across the whole rail, so a panel that opens beside the word opens
    // beside the rail, and each one opens against the same edge.
    orientation === 'vertical' && 'w-full',
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
          aria-current={active ? 'page' : undefined}
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
                is not a control moving. On a rail it points where the panel
                opens, at the end of the line, and stays there while the panel
                is open, as a submenu's chevron does; the open item says so
                with its fill and its accent. */}
            <BaseUINavigationMenu.Icon
              className={cx(
                'flex items-center',
                orientation === 'vertical'
                  ? '-rotate-90 rtl:rotate-90'
                  : '[transition:rotate_var(--plass-duration)_var(--plass-ease)] motion-reduce:[transition-duration:0ms] data-[popup-open]:rotate-180'
              )}
            >
              <ChevronIcon />
            </BaseUINavigationMenu.Icon>
          </BaseUINavigationMenu.Trigger>

          {/* Kept mounted, so every panel's links are in the server HTML and a
              crawler that never hovers still finds them — which is what the
              `<a>`s are for. A closed panel carries `hidden`, and the
              `[hidden]` rule is here because `grid` would otherwise outrank
              the browser's own `display: none` for it and show the panel.

              As wide as its links, up to the room beside the row less the
              sheet's two edges, and never as wide as the sheet around it: the
              sheet is between two sizes while it eases, and a panel that
              followed it would wrap its lines again on every frame. */}
          <BaseUINavigationMenu.Content
            keepMounted
            className={cx(
              'grid w-max max-w-[calc(var(--available-width)-2px)] gap-1 [&[hidden]]:hidden',
              panelPaddingClasses[size]
            )}
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
 * One panel is open at a time, which is Base UI's doing, and the sheet eases
 * from one item's panel to the next, in size and in place, rather than closing
 * and reopening, which is what makes crossing the row read as one surface
 * rather than three.
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

  const context = React.useMemo(
    () => ({ size, density, orientation }),
    [size, density, orientation]
  );

  /*
   * Which panel is open, whoever holds it. Base UI keeps an uncontrolled value
   * to itself, but every change it makes goes through `onValueChange`, so the
   * copy here moves with it.
   */
  const [ownValue, setOwnValue] = React.useState<string | null>(defaultValue ?? null);
  const openValue = value !== undefined ? value : ownValue;

  /*
   * Whether one panel is following another, which is the one change the sheet
   * eases. Set in the render that changes the panel, so the easing is in place
   * before the new size is; cleared when the menu closes and once the sheet
   * has finished easing, so a later change of size or place arrives at once.
   */
  const [shownValue, setShownValue] = React.useState(openValue);
  const [moving, setMoving] = React.useState(false);

  if (shownValue !== openValue) {
    setShownValue(openValue);
    setMoving(openValue !== null && shownValue !== null);
  }

  const [positioner, setPositioner] = React.useState<HTMLDivElement | null>(null);
  const [viewport, setViewport] = React.useState<HTMLDivElement | null>(null);
  const popupRef = React.useRef<HTMLElement>(null);

  /*
   * Hands the sheet and its box the size of the panel in the viewport, edges
   * included.
   *
   * The sheet never reads the `--popup-width` and `--popup-height` Base UI
   * writes. Those are measured once, when a trigger changes the panel, with
   * the popup laid out wherever the last panel left it; they are set a frame
   * later and handed back as `auto` once the popup stops animating. A change
   * no trigger makes is never measured, and one that cancels the hand-back
   * leaves the sheet held at a size that is not its panel's. This size is the
   * panel's by construction: it is read whenever the panel changes or changes
   * size, and the viewport is as wide as the panel rather than as the sheet,
   * so it reads the same wherever the sheet is.
   */
  const fit = React.useCallback(() => {
    const popup = popupRef.current;

    if (!positioner || !popup || !viewport) {
      return;
    }

    const panel = getComputedStyle(viewport);
    const width = Number.parseFloat(panel.width);
    const height = Number.parseFloat(panel.height);

    // Nothing in it: the menu is closed, or closing with its panel taken out
    // of the flow to fade. The sheet keeps the size of what it held.
    if (!(width > 0 && height > 0)) {
      return;
    }

    const edge = getComputedStyle(popup);
    const across =
      Number.parseFloat(edge.borderLeftWidth) + Number.parseFloat(edge.borderRightWidth);
    const down = Number.parseFloat(edge.borderTopWidth) + Number.parseFloat(edge.borderBottomWidth);

    positioner.style.setProperty('--p-panel-w', `${width + across}px`);
    positioner.style.setProperty('--p-panel-h', `${height + down}px`);
  }, [positioner, viewport]);

  // In the commit that changes the panel, so the box is already the new size
  // when Base UI places it under the new trigger.
  React.useLayoutEffect(() => {
    if (openValue !== null) {
      fit();
    }
  }, [openValue, fit]);

  // And whenever the panel's own size changes after that: its links changing,
  // a font arriving, the room beside the row narrowing. On the next frame
  // rather than inside the observer: Base UI and Floating UI watch the sheet
  // and its box with observers of their own, and a size changed in here would
  // reach them only as a "ResizeObserver loop" error.
  React.useEffect(() => {
    if (!viewport || typeof ResizeObserver === 'undefined') {
      return undefined;
    }

    let frame = 0;
    const observer = new ResizeObserver(() => {
      cancelAnimationFrame(frame);
      frame = requestAnimationFrame(fit);
    });

    observer.observe(viewport);

    return () => {
      cancelAnimationFrame(frame);
      observer.disconnect();
    };
  }, [viewport, fit]);

  /*
   * Ends the easing at the first frame after the change of panel at which
   * neither the sheet nor its box is easing. Waiting for their transitions to
   * end is not enough: a panel the same size as the last, in the same place,
   * starts none, and the box would then ease whatever moved it next, such as
   * the row scrolling with the page, until the menu closed.
   *
   * Not before that first frame, because the box has not been sent anywhere
   * until Floating UI places it under the next item. It does that a few
   * microtasks after the commit that changes the panel, in the same task, so
   * a frame always comes after it.
   */
  React.useEffect(() => {
    const popup = popupRef.current;

    if (!moving || !positioner || !popup) {
      return undefined;
    }

    const elements = [positioner, popup];
    let frame = 0;

    const settle = () => {
      // Reading a computed value brings the styles up to date, which starts
      // the transitions of a change that has not reached a frame yet, so that
      // change counts as easing rather than being cut short.
      for (const element of elements) {
        getComputedStyle(element).getPropertyValue('width');
      }

      const easing = elements.some((element) =>
        element
          .getAnimations()
          .some(
            (animation) =>
              animation instanceof CSSTransition &&
              easedProperties.has(animation.transitionProperty) &&
              animation.playState !== 'finished'
          )
      );

      if (easing) {
        frame = requestAnimationFrame(settle);
      } else {
        setMoving(false);
      }
    };

    frame = requestAnimationFrame(settle);

    return () => {
      cancelAnimationFrame(frame);
    };
  }, [moving, positioner]);

  return (
    <NavigationMenuContext.Provider value={context}>
      <BaseUINavigationMenu.Root
        ref={ref}
        orientation={orientation}
        value={value}
        defaultValue={defaultValue}
        onValueChange={(next) => {
          if (value === undefined) {
            setOwnValue(next);
          }

          onValueChange?.(next);
        }}
        delay={delay}
        closeDelay={closeDelay}
        className={className}
        style={{ ...surfaceSlots(color, 3), ...style }}
        {...props}
      >
        <BaseUINavigationMenu.List
          className={cx(
            'm-0 flex list-none items-center p-0',
            orientation === 'vertical' ? 'flex-col items-stretch' : 'flex-row',
            gapClasses[size]
          )}
        >
          {children}
        </BaseUINavigationMenu.List>

        {/* Kept mounted with the panels: once one has opened, every panel
            lives in the viewport, and a viewport that went away on close would
            take all their links out of the document with it. A closed
            positioner is `hidden` and inert, and stops tracking its anchor. */}
        <BaseUINavigationMenu.Portal keepMounted>
          {/* `.plass-portal` is a hook, not a style: a portalled popup leaves
              the subtree a host may have scoped its CSS reset to.

              A rail's panels open beside it, at the end of the line, which is
              its left under RTL, with their top level with the item's, as a
              submenu opens beside its row: moving down the rail moves the
              sheet down by the items' spacing. */}
          <BaseUINavigationMenu.Positioner
            ref={setPositioner}
            className={cx(
              positionerClasses,
              moving ? positionerMoveClasses : positionerStillClasses
            )}
            side={orientation === 'vertical' ? 'inline-end' : 'bottom'}
            align={orientation === 'vertical' ? 'start' : 'center'}
            sideOffset={sideOffset}
            collisionPadding={12}
          >
            <BaseUINavigationMenu.Popup
              ref={popupRef}
              className={cx(
                popupClasses,
                moving ? popupResizeClasses : popupFadeClasses,
                radiusClasses[size]
              )}
            >
              {/* As wide as the panel in it rather than as the sheet, which
                  is what lets it be measured while the sheet is between two
                  sizes. The sheet clips it. */}
              <BaseUINavigationMenu.Viewport ref={setViewport} className="w-max" />
            </BaseUINavigationMenu.Popup>
          </BaseUINavigationMenu.Positioner>
        </BaseUINavigationMenu.Portal>
      </BaseUINavigationMenu.Root>
    </NavigationMenuContext.Provider>
  );
});
