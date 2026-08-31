'use client';

import * as React from 'react';
import { PlIconButton } from '../icon-button/PlIconButton.js';
import { useDefaults } from '../../internal/defaults.js';
import { usePrefersReducedMotion } from '../../internal/media.js';
import { cx, transitionClasses } from '../../internal/styles.js';
import type { PlassColor, PlassElevation, PlassSize, PlassVariant } from '../../types.js';

/** What is scrolled, and what is watched. */
export type PlBackTopTarget =
  Window | HTMLElement | React.RefObject<HTMLElement | null> | (() => Window | HTMLElement | null);

export interface PlBackTopProps extends Omit<React.ComponentPropsWithoutRef<'button'>, 'color'> {
  /**
   * What is scrolled. The window by default; a ref or an element for a panel
   * that scrolls inside the page.
   */
  target?: PlBackTopTarget;
  /**
   * How far down the reader has to be before it appears, in pixels.
   *
   * 400 is roughly one screen on a laptop, which is the point at which "go
   * back to the top" stops being a thing they could just do by scrolling.
   * @default 400
   */
  visibilityHeight?: number;
  /** What it does, in words, and its accessible name. @default 'Back to top' */
  label?: string;
  /** The glyph. An upward chevron by default. */
  icon?: React.ReactNode;
  /**
   * Whether it pins itself to the bottom corner of the window.
   *
   * On by default, because that is what this component is. Turn it off to put
   * the button somewhere of your own — the end of an article, a toolbar — and
   * keep the appearing and the scrolling.
   * @default true
   */
  floating?: boolean;
  /** @default 'glass' */
  variant?: PlassVariant;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** @default 2 */
  elevation?: PlassElevation;
}

function ChevronUp() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M4.5 9.5 8 6l3.5 3.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function resolve(target: PlBackTopTarget | undefined): Window | HTMLElement | null {
  if (target === undefined) {
    return typeof window === 'undefined' ? null : window;
  }

  if (typeof target === 'function') {
    return target();
  }

  if ('current' in target) {
    return target.current;
  }

  return target;
}

function scrollTopOf(node: Window | HTMLElement): number {
  return node instanceof Window ? node.scrollY : node.scrollTop;
}

/**
 * The way back up, once there is a way back up to want.
 *
 * It is **hidden until it is useful** and that is the whole design: a button
 * pinned to the corner of every page from the first paint is one more thing
 * covering the content, and on a page short enough not to scroll it is a
 * control that does nothing. It appears when the reader is a screen or so down,
 * which is the point at which scrolling back stops being something they would
 * just do.
 *
 * The scroll is smooth, and **not** under `prefers-reduced-motion` — a page
 * that flies past a reader who asked for less movement is the exact case that
 * setting exists for. It jumps instead, which arrives at the same place.
 */
export const PlBackTop = /* @__PURE__ */ React.forwardRef<HTMLButtonElement, PlBackTopProps>(
  function PlBackTop(
    {
      target,
      visibilityHeight = 400,
      label = 'Back to top',
      icon,
      floating = true,
      variant = 'glass',
      size: sizeProp,
      color: colorProp,
      elevation = 2,
      className,
      onClick,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';
    const still = usePrefersReducedMotion();

    const [shown, setShown] = React.useState(false);

    React.useEffect(() => {
      const node = resolve(target);

      if (!node) {
        return undefined;
      }

      const read = () => setShown(scrollTopOf(node) > visibilityHeight);

      // Read once on mount as well as on every scroll: a page restored halfway
      // down — a back navigation, an anchor in the URL — has already done its
      // scrolling before this listener existed.
      read();
      node.addEventListener('scroll', read, { passive: true });

      return () => node.removeEventListener('scroll', read);
      // `target` is a ref or an element and is stable; a function form is
      // called once per change, which is the caller's to control.
    }, [target, visibilityHeight]);

    const toTop = (event: React.MouseEvent<HTMLButtonElement>) => {
      onClick?.(event);

      if (event.defaultPrevented) {
        return;
      }

      resolve(target)?.scrollTo({ top: 0, behavior: still ? 'auto' : 'smooth' });
    };

    return (
      <PlIconButton
        ref={ref}
        label={label}
        icon={icon ?? <ChevronUp />}
        variant={variant}
        size={size}
        color={color}
        elevation={elevation}
        onClick={toTop}
        // Hidden from the pointer *and* from the tab order while it is not
        // useful, rather than merely faded: a control a reader can tab to and
        // cannot see is worse than one that is not there.
        aria-hidden={shown ? undefined : true}
        tabIndex={shown ? undefined : -1}
        className={cx(
          floating ? 'fixed end-6 bottom-6 z-30' : '',
          transitionClasses,
          shown ? 'opacity-100' : 'pointer-events-none opacity-0',
          className
        )}
        {...props}
      />
    );
  }
);
