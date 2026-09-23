'use client';

/**
 * The box a `PlTable`'s grid scrolls in, and the one part of the table that has
 * to run in the browser.
 *
 * A table wider than its sheet scrolls sideways, and one under a `maxHeight`
 * scrolls down. When no cell in it takes the focus — a table of plain values,
 * which is most of them — whatever is past the edge is out of reach of anyone
 * without a pointer. So while the box scrolls it is a tab stop, which hands the
 * arrow keys to the browser's own scrolling of a focused scroll container, and
 * a group named by the table's caption, so the stop is announced as the table
 * it scrolls. A box that fits has nothing to scroll, and a stop on it would be
 * one more press on the way past. It is the arrangement `PlScrollZone` makes
 * for its strip.
 *
 * Whether the box scrolls is a measurement, and a measurement is a hook, which
 * is the one thing `PlTable` must not call: a server component renders it with
 * `render` callbacks, and those cannot cross into a client one. So the hook is
 * here, in a module of its own, and the table hands it what it has already
 * rendered — the grid's rows, and the caption the box is named by. The caption
 * is drawn here as well because the name needs its id, and an id is a hook too.
 */

import * as React from 'react';
import { cx, focusRingInsetClasses, srOnlyClasses } from './styles.js';

export interface PlassTableScrollProps {
  /** The box's own classes: its overflow on each axis. */
  className: string;
  /** The box's own style: the cap, when there is one. */
  style?: React.CSSProperties;
  /** The `<table>`'s classes. */
  tableClassName: string;
  /** The `<table>`'s inline style. */
  tableStyle: React.CSSProperties;
  /** The table's name, written into its `<caption>`. */
  caption?: React.ReactNode;
  /** Everything in the `<table>` after the caption. */
  children: React.ReactNode;
}

export function PlassTableScroll({
  className,
  style,
  tableClassName,
  tableStyle,
  caption,
  children
}: PlassTableScrollProps) {
  const boxRef = React.useRef<HTMLDivElement>(null);
  const captionId = React.useId();
  const [scrolls, setScrolls] = React.useState(false);

  React.useEffect(() => {
    const box = boxRef.current;

    if (!box) {
      return;
    }

    // A pixel over is rounding rather than something to scroll to: a grid as
    // wide as its box can come out a fraction wider once the columns are laid
    // out.
    const measure = () =>
      setScrolls(box.scrollWidth - box.clientWidth > 1 || box.scrollHeight - box.clientHeight > 1);

    measure();

    if (typeof ResizeObserver === 'undefined') {
      return;
    }

    const observer = new ResizeObserver(measure);

    observer.observe(box);

    // The grid as well, for rows that arrive or grow inside a box that keeps
    // its own size.
    if (box.firstElementChild) {
      observer.observe(box.firstElementChild);
    }

    return () => observer.disconnect();
  }, []);

  const named = scrolls && Boolean(caption);

  return (
    <div
      ref={boxRef}
      // Inset, because the sheet around the box clips at its rounded edge.
      className={cx(className, focusRingInsetClasses)}
      style={style}
      tabIndex={scrolls ? 0 : undefined}
      role={named ? 'group' : undefined}
      aria-labelledby={named ? captionId : undefined}
    >
      <table className={tableClassName} style={tableStyle}>
        {/* The accessible name, and nothing a sighted reader meets: the same
            words are already drawn above the sheet. */}
        {caption ? (
          <caption id={captionId} className={srOnlyClasses}>
            {caption}
          </caption>
        ) : null}
        {children}
      </table>
    </div>
  );
}
