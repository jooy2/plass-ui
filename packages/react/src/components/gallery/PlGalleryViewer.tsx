'use client';

import * as React from 'react';
import { useLabels } from '../../internal/labels.js';
import { ChevronIcon } from '../../internal/icons.js';
import { cx, metaTextClasses } from '../../internal/styles.js';
import { PlIconButton } from '../icon-button/PlIconButton.js';
import { PlOverlay } from '../overlay/PlOverlay.js';
import type { PlGalleryItem } from './PlGallery.js';
import type { PlassColor, PlassSize } from '../../types.js';

export interface PlGalleryViewerProps {
  items: readonly PlGalleryItem[];
  /** Which picture is open, or `null` for none. */
  index: number | null;
  onIndexChange: (index: number | null) => void;
  size: PlassSize;
  color: PlassColor;
  /** The overlay's own name — the gallery's. */
  label: string;
  /** Resolved by the gallery, so the viewer resolves nothing a second time. */
  itemLabel: (index: number, total: number) => string;
}

/**
 * One picture from a `PlGallery`, full size, with the rest of the set an arrow
 * key away.
 *
 * A file of its own rather than a branch inside `PlGallery`, and that is the
 * whole point of it: this is the only thing in the component that needs an
 * overlay, and an overlay is more than the gallery that opens it. Reached
 * through `React.lazy`, a wall of thumbnails costs nothing for a viewer nobody
 * opened.
 *
 * It is not a `PlCarousel`. A carousel is a set somebody is being shown in
 * order; this is one picture with a way to the next — so there is no autoplay,
 * no wrap, and the arrows stop at the ends rather than looping back to a
 * photograph the reader has already seen.
 */
export function PlGalleryViewer({
  items,
  index,
  onIndexChange,
  size,
  color,
  label,
  itemLabel
}: PlGalleryViewerProps) {
  const labels = useLabels();
  const open = index !== null;
  const current = index === null ? undefined : items[index];
  const atStart = index === null || index <= 0;
  const atEnd = index === null || index >= items.length - 1;

  const go = (to: number) => {
    if (to >= 0 && to < items.length) {
      onIndexChange(to);
    }
  };

  /*
   * The arrows are bound on the overlay rather than on the buttons, because the
   * focus is wherever the reader last put it — on a button, on the picture, on
   * the sheet — and a key that only worked from one of those is a key that
   * looks broken from the other two. Escape is the overlay's own and is left
   * alone.
   */
  const onKeyDown = (event: React.KeyboardEvent) => {
    if (index === null || event.metaKey || event.ctrlKey || event.altKey) {
      return;
    }

    if (event.key === 'ArrowRight') {
      event.preventDefault();
      go(index + 1);
    } else if (event.key === 'ArrowLeft') {
      event.preventDefault();
      go(index - 1);
    }
  };

  return (
    <PlOverlay
      open={open}
      onOpenChange={(next) => {
        if (!next) {
          onIndexChange(null);
        }
      }}
      tone="glass"
      dismissible
      size={size}
      color={color}
      label={label}
      onKeyDown={onKeyDown}
    >
      <div className="flex max-w-[90vw] flex-col gap-3">
        <div className="relative flex items-center justify-center">
          {current ? (
            <img
              // Keyed on the picture, so moving to the next one starts its own
              // load rather than showing the previous file under a new caption.
              key={current.id ?? current.src}
              src={current.full ?? current.src}
              alt={current.alt}
              className="max-h-[80vh] max-w-[90vw] object-contain"
            />
          ) : null}

          {items.length > 1 ? (
            <div className="pointer-events-none absolute inset-x-0 flex items-center justify-between px-1">
              <PlIconButton
                variant="solid"
                elevation={1}
                size={size}
                color={color}
                label={labels.previous}
                disabled={atStart}
                className="pointer-events-auto"
                // Drawn pointing down and turned, which is the one allowance the
                // no-transform rule makes — and turned the other way under RTL,
                // where "previous" is on the other side of the frame.
                icon={
                  <span className="flex items-center rotate-90 rtl:-rotate-90">
                    <ChevronIcon />
                  </span>
                }
                onClick={() => go((index ?? 0) - 1)}
              />
              <PlIconButton
                variant="solid"
                elevation={1}
                size={size}
                color={color}
                label={labels.next}
                disabled={atEnd}
                className="pointer-events-auto"
                icon={
                  <span className="flex items-center -rotate-90 rtl:rotate-90">
                    <ChevronIcon />
                  </span>
                }
                onClick={() => go((index ?? 0) + 1)}
              />
            </div>
          ) : null}
        </div>

        {current && (current.title || current.description) ? (
          <div className="flex min-w-0 flex-col gap-0.5 text-center">
            {current.title ? (
              <span className="truncate font-medium text-(--plass-fg)">{current.title}</span>
            ) : null}
            {current.description ? (
              <span className={cx('truncate text-(--plass-muted-fg)', metaTextClasses[size])}>
                {current.description}
              </span>
            ) : null}
          </div>
        ) : null}

        {items.length > 1 ? (
          <p
            className={cx('m-0 text-center text-(--plass-muted-fg)', metaTextClasses[size])}
            // Announced when it changes, so an arrow key says where it landed to
            // a reader who cannot see the picture it landed on.
            aria-live="polite"
          >
            {itemLabel((index ?? 0) + 1, items.length)}
          </p>
        ) : null}
      </div>
    </PlOverlay>
  );
}
