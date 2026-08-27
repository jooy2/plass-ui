import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  controlHeightClasses,
  controlSquareClasses,
  cx,
  focusRingClasses,
  glassClasses,
  hasContent,
  iconSizeClasses,
  srOnlyClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassDensity,
  PlassElevation,
  PlassPosition,
  PlassSize,
  PlassStyleProps
} from '../../types.js';

/** A destination's value. The same restraint `PlBottomNavigation` puts on its own. */
export type PlFloatingBottomNavigationValue = string | number;

/**
 * What an item inherits from the bar around it.
 *
 * `size`, `color`, `variant` and which destination is current all belong to the
 * *set*. A row of discs where the third one is a size out is not a row.
 */
interface FloatingBarContextValue {
  value: PlFloatingBottomNavigationValue | null;
  change: (value: PlFloatingBottomNavigationValue) => void;
  size: PlassSize;
  disabled: boolean;
}

const FloatingBarContext = /* @__PURE__ */ React.createContext<FloatingBarContextValue>({
  value: null,
  change: () => {},
  size: 'md',
  disabled: false
});

export interface PlFloatingBottomNavigationProps
  extends
    Omit<PlassStyleProps, 'variant'>,
    Omit<React.ComponentPropsWithoutRef<'nav'>, 'color' | 'defaultValue' | 'onChange'> {
  /**
   * What the capsule is made of.
   *
   * `glass` is the default and the whole point: a clear sheet over a blurred
   * backdrop with a hairline around it, floating clear of the page. `solid` is
   * the same sheet at its most opaque, for a bar that sits over photography.
   * `ghost` has no capsule at all — the discs float on their own.
   * @default 'glass'
   */
  variant?: PlassStyleProps['variant'];
  /** The destination the reader is on. Use with `onValueChange` for a controlled bar. */
  value?: PlFloatingBottomNavigationValue | null;
  /** Which starts current, for an uncontrolled bar. */
  defaultValue?: PlFloatingBottomNavigationValue | null;
  onValueChange?: (value: PlFloatingBottomNavigationValue) => void;
  /**
   * How the bar sits in the page's scroll.
   * @default 'fixed'
   */
  position?: PlassPosition;
  /**
   * Keeps the bar clear of the home indicator on a phone, by adding
   * `env(safe-area-inset-bottom)` to the gap under it.
   * @default true
   */
  safeArea?: boolean;
  /**
   * Drop shadow depth. `2`, against the `0` a bar attached to the window edge
   * takes.
   *
   * That is not an inconsistency: this bar is defined by **not** being part of
   * the page. Every other sheet in the library rests on the page and earns its
   * separation from the glass edge, so a shadow is opt-in; this one hovers over
   * whatever is underneath it, and a capsule lying flat on the content it is
   * floating over reads as a mistake.
   * @default 2
   */
  elevation?: PlassElevation;
  /** Every destination stops answering. */
  disabled?: boolean;
  /** The name the bar is announced by — "Main", "Sections". */
  label?: string;
  /**
   * Renders something other than a `<nav>`. Rarely what you want here: a row of
   * destinations is navigation.
   */
  render?: useRender.RenderProp;
  /** The `PlFloatingBottomNavigationItem`s. */
  children?: React.ReactNode;
}

export interface PlFloatingBottomNavigationItemProps extends Omit<
  React.ComponentPropsWithoutRef<'button'>,
  'value' | 'color'
> {
  /** Identifies the destination. What `onValueChange` reports. */
  value: PlFloatingBottomNavigationValue;
  /** The glyph. It is the whole of what a reader sees. */
  icon?: React.ReactNode;
  /** Renders the item as a link rather than as a button. */
  href?: string;
  /** Unavailable, but still part of the set. */
  disabled?: boolean;
  /**
   * The destination's name.
   *
   * **Never drawn, always read.** A row of glyphs with no names is a row of
   * unnamed buttons, which is the defect this prop exists to make impossible.
   */
  children?: React.ReactNode;
}

/** How far off the floor the capsule sits, on the size ladder. */
const floatGapClasses: Record<PlassSize, string> = {
  xs: 'pb-2',
  sm: 'pb-3',
  md: 'pb-4',
  lg: 'pb-5',
  xl: 'pb-6'
};

/** The same, with the home indicator added underneath it. */
const floatGapSafeClasses: Record<PlassSize, string> = {
  xs: 'pb-[calc(env(safe-area-inset-bottom)+0.5rem)]',
  sm: 'pb-[calc(env(safe-area-inset-bottom)+0.75rem)]',
  md: 'pb-[calc(env(safe-area-inset-bottom)+1rem)]',
  lg: 'pb-[calc(env(safe-area-inset-bottom)+1.25rem)]',
  xl: 'pb-[calc(env(safe-area-inset-bottom)+1.5rem)]'
};

/** The air inside the capsule, around the discs. */
const capsulePaddingClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'p-1', sm: 'p-1', md: 'p-1.5', lg: 'p-2', xl: 'p-2.5' },
  compact: { xs: 'p-0.5', sm: 'p-0.5', md: 'p-1', lg: 'p-1', xl: 'p-1.5' }
};

/** Between two discs. */
const discGapClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'gap-1', sm: 'gap-1', md: 'gap-1.5', lg: 'gap-2', xl: 'gap-2.5' },
  compact: { xs: 'gap-0.5', sm: 'gap-0.5', md: 'gap-1', lg: 'gap-1', xl: 'gap-1.5' }
};

const positionClasses: Record<PlassPosition, string> = {
  static: '',
  sticky: 'sticky bottom-0 z-20',
  fixed: 'fixed inset-x-0 bottom-0 z-30'
};

/**
 * The capsule.
 *
 * `rounded-full` is one of the very few places the library allows a pill, and it
 * is allowed for the reason a `PlSegmentedButton`'s groove is: this is not a
 * sheet lying on the page, it is an object floating clear of one. The house
 * fillet is about a sheet with its corners cut, and a sheet that is not on
 * anything has no corners to cut.
 */
const capsuleClasses: Record<'solid' | 'glass' | 'ghost', string> = {
  solid: /* @__PURE__ */ [
    glassClasses,
    'bg-(--plass-glass-press)',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    glassClasses,
    'border bg-(--plass-glass)',
    '[border-color:var(--plass-glass-line)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: ''
};

/**
 * A row of round destinations floating clear of the bottom edge of the window.
 *
 * The other half of `PlBottomNavigation`, and a different object rather than a
 * variant of one: that bar is **attached** to the edge of the window — full
 * width, a hairline against the content, its sheet running under the home
 * indicator — and this one is **not part of the page at all**. Everything that
 * follows comes from that one difference: the capsule, the gap under it, the
 * shadow it defaults to, and the pill corners it is allowed.
 *
 * Every destination is a disc with a glyph in it and no name drawn, which is
 * what keeps a row of five inside the width of a phone. The name is still
 * required and still read out — a row of glyphs with no accessible names is the
 * defect `PlIconButton`'s `label` exists to make impossible, and it would be
 * exactly as easy to ship here.
 *
 * The current destination is a key of **tinted glass** riding in the clear
 * sheet, which is the design language's own sentence with nothing added to it.
 */
export const PlFloatingBottomNavigation = /* @__PURE__ */ React.forwardRef<
  HTMLElement,
  PlFloatingBottomNavigationProps
>(function PlFloatingBottomNavigation(
  {
    variant = 'glass',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 2,
    value: valueProp,
    defaultValue = null,
    onValueChange,
    position = 'fixed',
    safeArea = true,
    disabled = false,
    label,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const [uncontrolled, setUncontrolled] = React.useState<PlFloatingBottomNavigationValue | null>(
    defaultValue
  );
  const controlled = valueProp !== undefined;
  const value = controlled ? valueProp : uncontrolled;

  const change = React.useCallback(
    (next: PlFloatingBottomNavigationValue) => {
      if (!controlled) {
        setUncontrolled(next);
      }

      onValueChange?.(next);
    },
    [controlled, onValueChange]
  );

  const context = React.useMemo(
    () => ({ value: value ?? null, change, size, disabled }),
    [value, change, size, disabled]
  );

  const classNames = cx(
    'flex w-full justify-center px-4',
    // The strip the capsule is centred in spans the window, and a transparent
    // band across the bottom of a page that swallowed presses would be a band
    // nobody could scroll through. Only the capsule takes them back.
    position === 'static' ? '' : 'pointer-events-none',
    safeArea ? floatGapSafeClasses[size] : floatGapClasses[size],
    positionClasses[position],
    className
  );

  return useRender({
    render: render ?? <nav />,
    ref,
    props: {
      'aria-label': label,
      className: classNames,
      style: { ...surfaceSlots(color, elevation), ...style },
      children: (
        <FloatingBarContext.Provider value={context}>
          <div
            className={cx(
              'pointer-events-auto inline-flex items-center rounded-full',
              capsuleClasses[variant],
              capsulePaddingClasses[density][size],
              discGapClasses[density][size],
              transitionClasses
            )}
          >
            {children}
          </div>
        </FloatingBarContext.Provider>
      ),
      ...props
    }
  });
});

/**
 * One destination, as a disc.
 *
 * It has no `size`, no `color` and no `variant` of its own: all three belong to
 * the bar, which is the only place they can be set once and mean the same thing
 * for every disc.
 */
export const PlFloatingBottomNavigationItem = /* @__PURE__ */ React.forwardRef<
  HTMLElement,
  PlFloatingBottomNavigationItemProps
>(function PlFloatingBottomNavigationItem(
  { value, icon, href, disabled: disabledProp = false, className, children, onClick, ...props },
  ref
) {
  const bar = React.useContext(FloatingBarContext);
  const disabled = disabledProp || bar.disabled;
  const selected = bar.value !== null && bar.value === value;

  const classNames = cx(
    'relative inline-flex shrink-0 items-center justify-center rounded-full',
    controlHeightClasses[bar.size],
    controlSquareClasses[bar.size],
    '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
    transitionClasses,
    // Offset rather than inset: a disc inside a capsule that is only padding has
    // room around it, and a flush ring on a circle is the circle's own edge
    // thickening — which is the one shape where that reads as a border rather
    // than as focus.
    focusRingClasses,
    disabled
      ? 'cursor-not-allowed opacity-50 saturate-[0.35] text-(--plass-muted-fg)'
      : selected
        ? [
            'cursor-pointer text-(--p-on-solid) [background-image:var(--p-fill)]',
            '[box-shadow:var(--plass-shadow-1),var(--p-lift)]',
            'hover:brightness-105 active:brightness-95'
          ].join(' ')
        : 'cursor-pointer text-(--plass-muted-fg) hover:text-(--plass-fg) hover:bg-(--plass-glass-hover)',
    className
  );

  const body = (
    <>
      {hasContent(icon) ? (
        <span
          className={cx('flex shrink-0 items-center justify-center', iconSizeClasses[bar.size])}
        >
          {icon}
        </span>
      ) : null}

      {/*
        Never drawn, always read. A disc with a glyph in it has no accessible
        name at all, and this is the only thing standing between the component
        and a row of unnamed buttons.
      */}
      {hasContent(children) ? <span className={srOnlyClasses}>{children}</span> : null}
    </>
  );

  const press = (event: React.MouseEvent<HTMLElement>) => {
    if (disabled) {
      event.preventDefault();
      return;
    }

    bar.change(value);
    onClick?.(event as React.MouseEvent<HTMLButtonElement>);
  };

  if (href) {
    return (
      <a
        ref={ref as React.Ref<HTMLAnchorElement>}
        href={disabled ? undefined : href}
        aria-current={selected ? 'page' : undefined}
        aria-disabled={disabled || undefined}
        className={classNames}
        onClick={press}
        {...(props as React.ComponentPropsWithoutRef<'a'>)}
      >
        {body}
      </a>
    );
  }

  return (
    <button
      ref={ref as React.Ref<HTMLButtonElement>}
      type="button"
      disabled={disabled}
      aria-current={selected ? 'page' : undefined}
      className={classNames}
      onClick={press}
      {...props}
    >
      {body}
    </button>
  );
});
