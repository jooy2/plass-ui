'use client';

import * as React from 'react';
import { PlOverlay } from '../overlay/PlOverlay.js';
import { cx } from '../../internal/styles.js';
import type { PlassColor } from '../../types.js';

export interface PlImagePreviewProps {
  /** Whether the picture is open over the page. */
  open: boolean;
  onOpenChange: (open: boolean) => void;
  /** The file to show, at whatever size it really is. */
  src?: string;
  /** The picture's description, carried over from the thumbnail. */
  alt: string;
  /** The accessible name of the overlay itself. */
  label: string;
  /** The family the overlay takes. */
  color: PlassColor;
  /**
   * Carried in from the thumbnail. A mark or a refusal that comes off the
   * moment the picture is opened large is not a mark or a refusal — and large
   * is the copy somebody wanted in the first place.
   */
  protect?: boolean;
}

/**
 * A `PlImage` opened over the page.
 *
 * It is a separate module because it is a separate download. This is a whole
 * overlay and the chrome around it — several times the weight of the picture
 * component that opens it — and `preview` is off by default, so a page drawing
 * a wall of thumbnails would otherwise be paying for a lightbox it never shows.
 * Reached through `React.lazy`, the chunk arrives after the first paint on the
 * pages that ask for one and is never fetched by the pages that do not.
 *
 * The same bargain `PlGallery` makes with `PlGalleryViewer`, for the same
 * reason.
 */
export function PlImagePreview({
  open,
  onOpenChange,
  src,
  alt,
  label,
  color,
  protect = false
}: PlImagePreviewProps) {
  return (
    <PlOverlay
      open={open}
      onOpenChange={onOpenChange}
      tone="glass"
      dismissible
      color={color}
      label={label}
    >
      <img
        src={src}
        alt={alt}
        className={cx(
          'max-h-[85vh] max-w-[90vw] object-contain',
          protect ? 'select-none [-webkit-touch-callout:none]' : ''
        )}
        draggable={protect ? false : undefined}
        onDragStart={protect ? (event) => event.preventDefault() : undefined}
        onContextMenu={protect ? (event) => event.preventDefault() : undefined}
      />
    </PlOverlay>
  );
}
