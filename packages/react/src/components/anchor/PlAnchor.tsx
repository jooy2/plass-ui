'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import {
  controlTextLeadingClasses,
  cx,
  focusRingClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassSize } from '../../types.js';

/** One heading in the list. */
export interface PlAnchorItem {
  /**
   * The fragment it points at — `#getting-started`. The `id` it names is what
   * the list watches, so a heading with no `id` cannot be tracked.
   */
  href: string;
  /** What the row says. */
  label: React.ReactNode;
  /**
   * How deep the heading sits, from `0`. Only the indent depends on it.
   * @default 0
   */
  depth?: number;
}

export interface PlAnchorProps extends Omit<React.ComponentPropsWithoutRef<'nav'>, 'onSelect'> {
  /** The headings, in the order they appear in the document. */
  items: readonly PlAnchorItem[];
  /**
   * The `href` of the row that is lit, taking the tracking over.
   *
   * For a list driven by a router rather than by the scroll — a documentation
   * site whose sections are separate pages, say. Leaving it out is the ordinary
   * case and the reason the component exists.
   */
  active?: string;
  /**
   * How far below the top of the window the reading line sits, in pixels.
   *
   * The height of whatever is pinned over the page. Without it a heading goes
   * on counting as the *next* one after it has already slid out of sight behind
   * a sticky header — so the list stays a section behind the reader for the
   * height of the bar.
   * @default 0
   */
  offset?: number;
  /** Called with the item that was clicked, before the browser moves. */
  onSelect?: (item: PlAnchorItem, event: React.MouseEvent<HTMLAnchorElement>) => void;
  /** A heading for the list itself. Drawn above it. */
  label?: React.ReactNode;
  /** Accessible name of the navigation region. Never drawn. @default 'On this page' */
  navLabel?: string;
  /** @default 'sm' */
  size?: PlassSize;
  /** The family the lit row takes. @default 'primary' */
  color?: PlassColor;
}

/** How far one level of depth indents a row. */
const INDENT = '0.75rem';

/**
 * Which heading is being read, given where the page is scrolled to.
 *
 * **The last one whose top has passed the line**, and not simply the one that
 * is on screen: three headings can be visible at once, and the one a reader is
 * inside is the highest of them that is already above them. This is why the
 * tracking is a measurement rather than an `IntersectionObserver` — an
 * observer answers "is it visible", and the question here is "which one did I
 * pass last".
 *
 * Two ends need saying separately. Above the first heading nothing is lit,
 * because the reader has not reached a section yet. At the very bottom the last
 * item is lit whatever the measurement says: a short final section never
 * reaches the line, and a list that could not light its own last row is a list
 * that goes dead exactly where a reader is looking for it.
 */
function readingAt(items: readonly PlAnchorItem[], offset: number): string | undefined {
  if (items.length === 0) {
    return undefined;
  }

  const page = document.documentElement.scrollHeight;
  // Only on a page there is something to scroll: a document that fits on the
  // screen is *always* at its own bottom, and lighting the last row there would
  // be saying a reader had reached the end before they had read anything.
  const scrollable = page > window.innerHeight + 1;
  const bottom = scrollable && window.innerHeight + window.scrollY >= page - 2;

  if (bottom) {
    return items[items.length - 1].href;
  }

  let current: string | undefined;

  for (const item of items) {
    const target = document.getElementById(item.href.replace(/^#/, ''));

    if (!target) {
      continue;
    }

    if (target.getBoundingClientRect().top - offset <= 1) {
      current = item.href;
    }
  }

  return current;
}

/**
 * A table of contents that follows the reader down the page.
 *
 * It takes its headings as **data** rather than as children, which is the
 * opposite of most of this library and the right way round here: a table of
 * contents is generated — from a Markdown file, from a CMS, from the document's
 * own headings — and the thing that generates it produces a flat list, in
 * document order, with a level on each entry.
 *
 * **It is a flat list and not a nested one**, and that is a decision rather
 * than a shortcut. Real documents skip levels — an `h2` followed by an `h4` —
 * so a nesting built from a flat list is a guess at a shape nobody wrote. The
 * depth is carried by the indent, and the reading order is the document's own.
 *
 * The tracking is the component. What is lit is **the last heading whose top has
 * passed the reading line**, not whichever heading happens to be on screen:
 * three can be visible at once, and the one the reader is inside is the highest
 * of them that is already above them. `offset` is where that line sits, and it
 * is the height of whatever is pinned over the page — without it a heading goes
 * on counting as the next one after it has slid out of sight behind the bar,
 * and the list stays a section behind.
 */
export const PlAnchor = /* @__PURE__ */ React.forwardRef<HTMLElement, PlAnchorProps>(
  function PlAnchor(
    {
      items,
      active,
      offset = 0,
      onSelect,
      label,
      navLabel: navLabelProp,
      size: sizeProp,
      color: colorProp,
      className,
      style,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const labels = useLabels();
    const navLabel = navLabelProp ?? labels.onThisPage;
    const size = sizeProp ?? defaults.size ?? 'sm';
    const color = colorProp ?? defaults.color ?? 'primary';

    const [tracked, setTracked] = React.useState<string | undefined>(undefined);
    const controlled = active !== undefined;

    React.useEffect(() => {
      if (controlled) {
        return;
      }

      let frame = 0;

      const measure = () => {
        frame = 0;
        setTracked(readingAt(items, offset));
      };

      // One measurement per frame at most. Scroll fires far more often than the
      // page paints, and the answer cannot change between two paints.
      const onScroll = () => {
        frame ||= requestAnimationFrame(measure);
      };

      measure();
      window.addEventListener('scroll', onScroll, { passive: true });
      window.addEventListener('resize', onScroll, { passive: true });

      return () => {
        if (frame) cancelAnimationFrame(frame);
        window.removeEventListener('scroll', onScroll);
        window.removeEventListener('resize', onScroll);
      };
    }, [controlled, items, offset]);

    const current = controlled ? active : tracked;

    return (
      <nav
        ref={ref}
        aria-label={navLabel}
        className={cx('flex flex-col gap-2', controlTextLeadingClasses[size], className)}
        style={{ ...surfaceSlots(color, 0), ...style }}
        {...props}
      >
        {label ? <span className="font-semibold text-(--plass-fg)">{label}</span> : null}

        <ul className="m-0 flex list-none flex-col gap-0.5 p-0">
          {items.map((item) => {
            const lit = item.href === current;

            return (
              <li key={item.href} className="min-w-0">
                <a
                  href={item.href}
                  // `location` rather than `page` or `true`: this is where the
                  // reader is *within* the document, which is the one thing the
                  // value exists for.
                  aria-current={lit ? 'location' : undefined}
                  onClick={(event) => onSelect?.(item, event)}
                  className={cx(
                    'block truncate rounded-(--plass-radius-xs) px-2 py-1',
                    'border-s-2',
                    transitionClasses,
                    focusRingClasses,
                    lit
                      ? '[border-color:var(--p-accent)] bg-(--p-soft) font-medium text-(--p-accent)'
                      : 'border-transparent text-(--plass-muted-fg) hover:bg-(--plass-glass-hover) hover:text-(--plass-fg)'
                  )}
                  style={{ paddingInlineStart: `calc(0.5rem + ${item.depth ?? 0} * ${INDENT})` }}
                >
                  {item.label}
                </a>
              </li>
            );
          })}
        </ul>
      </nav>
    );
  }
);
