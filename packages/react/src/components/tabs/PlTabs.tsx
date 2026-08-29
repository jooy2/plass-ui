'use client';

import * as React from 'react';
import { Tabs as BaseUITabs } from '@base-ui/react/tabs';
import {
  controlHeightClasses,
  controlTextClasses,
  focusRingClasses,
  focusRingInsetClasses,
  gapClasses,
  glassClasses,
  hasContent,
  iconClasses,
  paddingXClasses,
  radiusClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassDensity,
  PlassOrientation,
  PlassSize,
  PlassStyleProps,
  PlassVariant
} from '../../types.js';

/**
 * What a `PlTab` inherits from the `PlTabs` around it.
 *
 * `variant`, `size`, `color`, `density` and the orientation are properties of
 * the *set*, and a tab that could disagree with its neighbours about any of them
 * is a tab bar with a hole in it.
 */
interface TabsContextValue {
  variant: PlassVariant;
  size: PlassSize;
  density: PlassDensity;
  orientation: PlassOrientation;
  fullWidth: boolean;
}

const TabsContext = /* @__PURE__ */ React.createContext<TabsContextValue>({
  variant: 'glass',
  size: 'md',
  density: 'default',
  orientation: 'horizontal',
  fullWidth: false
});

/** A tab's value. The same restraint `PlSelect` puts on its own — an identifier. */
export type PlTabValue = string | number;

export interface PlTabsProps
  extends
    Omit<PlassStyleProps, 'variant'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /**
   * What the tab *bar* is made of, not the panels under it.
   *
   * - `solid` — a groove cut into the sheet with a clear pane riding in it, the
   *   way a segmented control works. (The tile is deliberately *not* the
   *   gradient: that is what a `PlSegmentedButton` is, and a screen with both
   *   should be able to tell them apart.)
   * - `glass` — the classic: a rule along the edge of the bar with the indicator
   *   riding on it. The default.
   * - `ghost` — the same bar with the rule taken away, for tabs inside a PlCard
   *   that already has an edge of its own.
   * @default 'glass'
   */
  variant?: PlassVariant;
  /** The chosen tab. Use with `onValueChange` for a controlled set. */
  value?: PlTabValue | null;
  /** Which starts chosen, for an uncontrolled set. */
  defaultValue?: PlTabValue | null;
  onValueChange?: (value: PlTabValue | null) => void;
  /**
   * Which way the bar runs. `vertical` puts the tabs down the side and the panel
   * beside them, and moves the arrow keys onto the other axis — which is Base
   * UI's doing, and is what makes a vertical tab bar reachable.
   * @default 'horizontal'
   */
  orientation?: PlassOrientation;
  /**
   * Whether moving the arrow keys also chooses the tab it lands on.
   *
   * `false` by default. Automatic activation is only kind when every panel is
   * already on the page; the moment one of them fetches, walking past four tabs
   * fires four requests.
   * @default false
   */
  activateOnFocus?: boolean;
  /**
   * Whether the arrow keys wrap from the last tab back to the first.
   * @default true
   */
  loopFocus?: boolean;
  /** The tabs share the bar's full width, each taking an equal part of it. */
  fullWidth?: boolean;
  children?: React.ReactNode;
}

export interface PlTabProps extends Omit<
  React.ComponentPropsWithoutRef<'button'>,
  'value' | 'color'
> {
  /** Identifies the tab, and picks out the panel with the same value. */
  value: PlTabValue;
  /** Content before the label. Sized in `em`, so it tracks the label. */
  startIcon?: React.ReactNode;
  /** Content after the label — a count, a status dot. */
  endIcon?: React.ReactNode;
  /** Unavailable, but still listed. */
  disabled?: boolean;
  children?: React.ReactNode;
}

export interface PlTabPanelProps extends React.ComponentPropsWithoutRef<'div'> {
  /** Which tab shows this panel. */
  value: PlTabValue;
  /**
   * Keeps the panel in the DOM while it is hidden. For a panel that is expensive
   * to build, or that holds form state which should survive being switched away
   * from.
   * @default false
   */
  keepMounted?: boolean;
  children?: React.ReactNode;
}

/* ---------------------------------------------------------------------------
 * The bar
 * ------------------------------------------------------------------------- */

/**
 * What the bar itself looks like, per material and per axis.
 *
 * `glass` is one border on one edge rather than a box, which is why it needs the
 * axis: the rule belongs under a horizontal bar and beside a vertical one. It is
 * `--plass-border` rather than the sheet's own white hairline, because a bar
 * drawn on a light card would otherwise have no rule at all.
 */
const listClasses: Record<PlassVariant, Record<PlassOrientation, string>> = {
  solid: {
    horizontal: `${glassClasses} inline-flex bg-(--plass-glass) p-1 [box-shadow:var(--plass-well)]`,
    vertical: `${glassClasses} inline-flex flex-col bg-(--plass-glass) p-1 [box-shadow:var(--plass-well)]`
  },
  glass: {
    horizontal: 'flex border-b [border-color:var(--plass-border)]',
    vertical: 'flex flex-col border-e [border-color:var(--plass-border)]'
  },
  ghost: {
    horizontal: 'flex',
    vertical: 'flex flex-col'
  }
};

/**
 * The indicator.
 *
 * `solid` fills the tab — a tile that slides between them. The other two draw a
 * 2px bar along the bar's own edge. All three move by animating `left`/`top` and
 * `width`/`height`, which Base UI measures onto `--active-tab-*`. That is a
 * layout animation on an empty box, not a transform on a label: nothing with
 * text in it moves, which is the distinction the house rule actually draws.
 *
 * `left`, not `inset-inline-start`, and this is one of the two places in the
 * library that reaches for a physical property on purpose. `--active-tab-left`
 * is a measurement — the distance from the list's left edge to the active tab's,
 * in pixels — and it stays a distance from the *left* under RTL. Pairing a
 * physical measurement with a logical property is what would break the
 * direction, not what would fix it. The edge the bar sits on is logical, because
 * that one genuinely flips.
 */
const indicatorClasses: Record<PlassVariant, Record<PlassOrientation, string>> = {
  solid: {
    horizontal:
      'absolute top-(--active-tab-top) left-(--active-tab-left) h-(--active-tab-height) w-(--active-tab-width)',
    vertical:
      'absolute top-(--active-tab-top) left-(--active-tab-left) h-(--active-tab-height) w-(--active-tab-width)'
  },
  glass: {
    horizontal: 'absolute bottom-0 left-(--active-tab-left) h-0.5 w-(--active-tab-width)',
    vertical: 'absolute end-0 top-(--active-tab-top) h-(--active-tab-height) w-0.5'
  },
  ghost: {
    horizontal: 'absolute bottom-0 left-(--active-tab-left) h-0.5 w-(--active-tab-width)',
    vertical: 'absolute end-0 top-(--active-tab-top) h-(--active-tab-height) w-0.5'
  }
};

const indicatorSurfaceClasses: Record<PlassVariant, string> = {
  solid: `${glassClasses} bg-(--plass-glass-press) [box-shadow:var(--plass-shadow-1),var(--plass-gloss-glass)]`,
  glass: 'bg-(--p-accent)',
  ghost: 'bg-(--p-accent)'
};

/**
 * A tab is a control, so it takes the control height ladder — a `md` tab and a
 * `md` PlButton are the same 40px, which is what lets a tab bar sit in a toolbar
 * next to one without the row losing its baseline.
 *
 * `data-active`, not `data-selected` — Base UI spells a chosen tab's state that
 * way, and the wrong attribute is a class that silently never matches.
 */
const tabStateClasses =
  'text-(--plass-muted-fg) hover:text-(--plass-fg) data-[active]:text-(--p-accent)';

/**
 * One tab, and one place a tab differs from a PlButton: `solid` puts the tile
 * *behind* the tab rather than on it, so the tab needs a stacking context of its
 * own or the indicator would cover the label it is meant to be under.
 */
export const PlTab = /* @__PURE__ */ React.forwardRef<HTMLButtonElement, PlTabProps>(function PlTab(
  { value, startIcon, endIcon, disabled = false, className, children, ...props },
  ref
) {
  const { variant, size, density, fullWidth } = React.useContext(TabsContext);

  return (
    <BaseUITabs.Tab
      ref={ref}
      value={value}
      disabled={disabled}
      className={[
        'relative z-10 inline-flex shrink-0 cursor-pointer items-center justify-center select-none',
        'font-semibold whitespace-nowrap',
        '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
        controlHeightClasses[size],
        controlTextClasses[size],
        gapClasses[size],
        paddingXClasses[density][size],
        variant === 'solid' ? radiusClasses[size] : '',
        transitionClasses,
        iconClasses,
        tabStateClasses,
        // The ring is inset rather than offset: an offset ring on a tab inside a
        // `solid` groove is drawn on top of its neighbours.
        focusRingInsetClasses,
        'data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50',
        fullWidth ? 'flex-1' : '',
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      {...props}
    >
      {hasContent(startIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center">{startIcon}</span>
      ) : null}
      {children}
      {hasContent(endIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center">{endIcon}</span>
      ) : null}
    </BaseUITabs.Tab>
  );
});

/** The content behind one tab. */
export const PlTabPanel = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlTabPanelProps>(
  function PlTabPanel({ value, keepMounted = false, className, children, ...props }, ref) {
    const { size } = React.useContext(TabsContext);

    return (
      <BaseUITabs.Panel
        ref={ref}
        value={value}
        keepMounted={keepMounted}
        className={[
          'min-w-0 flex-1 text-(--plass-fg)',
          // The panel takes focus when it holds nothing focusable of its own, so
          // it is reachable by keyboard — and it gets the house ring rather than
          // the browser's.
          focusRingClasses,
          radiusClasses[size],
          className ?? ''
        ]
          .filter(Boolean)
          .join(' ')}
        {...props}
      >
        {children}
      </BaseUITabs.Panel>
    );
  }
);

/**
 * One set of panels, one of which is shown.
 *
 * Base UI owns everything that makes a tab bar a tab bar rather than a row of
 * buttons: roving focus so the whole bar is one tab stop, the arrow keys on
 * whichever axis the bar runs, Home and End, the `tab` / `tabpanel` roles and
 * the `aria-controls` wiring between them, and the measurement that puts the
 * indicator under the chosen tab. What is here is the surface and the ladders.
 *
 * The tabs and the panels are composed rather than passed as data, unlike
 * `PlSelect` — because a panel is a subtree, and there is no useful shape for
 * "an array of arbitrary React trees" that is not just children.
 */
export const PlTabs = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlTabsProps>(function PlTabs(
  {
    variant = 'glass',
    size = 'md',
    color = 'primary',
    density = 'default',
    value,
    defaultValue,
    onValueChange,
    orientation = 'horizontal',
    activateOnFocus = false,
    loopFocus = true,
    fullWidth = false,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const context = React.useMemo(
    () => ({ variant, size, density, orientation, fullWidth }),
    [variant, size, density, orientation, fullWidth]
  );

  // Everything a caller writes between the tags is either a tab or a panel, and
  // the two go in different boxes — so they are sorted here rather than made the
  // caller's problem with a `<PlTabList>` wrapper they would have to remember.
  const tabs: React.ReactNode[] = [];
  const panels: React.ReactNode[] = [];

  React.Children.forEach(children, (child) => {
    if (React.isValidElement(child) && child.type === PlTabPanel) {
      panels.push(child);
    } else if (child !== null && child !== undefined && child !== false) {
      tabs.push(child);
    }
  });

  return (
    <TabsContext.Provider value={context}>
      <BaseUITabs.Root
        ref={ref}
        value={value}
        defaultValue={defaultValue}
        onValueChange={(next) => onValueChange?.(next as PlTabValue | null)}
        orientation={orientation}
        className={[
          'flex min-w-0',
          orientation === 'vertical' ? 'flex-row gap-4' : 'flex-col gap-4',
          className ?? ''
        ]
          .filter(Boolean)
          .join(' ')}
        style={{ ...surfaceSlots(color, 0), ...style }}
        {...props}
      >
        <BaseUITabs.List
          activateOnFocus={activateOnFocus}
          loopFocus={loopFocus}
          className={[
            'relative shrink-0',
            listClasses[variant][orientation],
            variant === 'solid' ? radiusClasses[size] : '',
            fullWidth && orientation === 'horizontal' ? 'w-full' : '',
            // A bar with more tabs than room scrolls rather than wrapping: a tab
            // bar on two lines has stopped being a bar, and the indicator has
            // nowhere sensible to sit.
            orientation === 'horizontal' ? 'overflow-x-auto overflow-y-hidden' : ''
          ]
            .filter(Boolean)
            .join(' ')}
        >
          {tabs}

          <BaseUITabs.Indicator
            className={[
              'pointer-events-none',
              indicatorClasses[variant][orientation],
              indicatorSurfaceClasses[variant],
              variant === 'solid' ? radiusClasses[size] : 'rounded-full',
              // The same easing everything else uses, on the four properties the
              // measurement actually writes.
              '[transition-property:left,top,width,height]',
              '[transition-duration:var(--plass-duration)]',
              '[transition-timing-function:var(--plass-ease)]'
            ].join(' ')}
          />
        </BaseUITabs.List>

        {panels}
      </BaseUITabs.Root>
    </TabsContext.Provider>
  );
});
