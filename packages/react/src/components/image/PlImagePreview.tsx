'use client';

import * as React from 'react';
import { PlOverlay } from '../overlay/PlOverlay.js';
import { cx } from '../../internal/styles.js';
import { isSideways, poseStyle } from '../../internal/image.js';
import { PlassWatermark } from '../../internal/watermark.js';
import type { PlassImageFlip, PlassQuarters } from '../../internal/image.js';
import type { PlassWatermarkOptions } from '../../internal/watermark.js';
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
  /**
   * Carried in from the thumbnail, for the same reason `protect` is: a mark that
   * comes off the moment the picture is opened large has marked the copy nobody
   * wanted.
   */
  watermark?: string | PlassWatermarkOptions;
  /**
   * How many quarters the thumbnail is turned, carried in so the picture opens
   * the way it was shown.
   */
  quarters?: PlassQuarters;
  /** The thumbnail's mirror, carried in for the same reason as its turn. */
  flip?: PlassImageFlip;
  /**
   * The file's own pixel size, where the thumbnail knows it. A picture on its
   * side is opened in a box of the turned shape, and this is that shape.
   */
  file?: { width: number; height: number } | null;
}

/**
 * The height a preview is capped at, and the width.
 *
 * Named once, because a picture on its side cannot be capped by its own
 * `max-height`: it is turned, so its height on the screen is its width in the
 * layout. The turned box is capped by the same two numbers instead.
 */
const HEIGHT_CAP = '85vh';
const WIDTH_CAP = '90vw';

/**
 * The box a picture on its side is opened in.
 *
 * An `<img>` sized by its own content cannot be turned in place: it keeps the
 * file's footprint, so a portrait turned onto its side would spill out sideways
 * and leave a gap above and below. The box is the turned shape instead, no wider
 * than the screen allows, than the file holds, or than the height cap turns
 * into. A file nothing has measured yet gets a square, which `contain` fills
 * correctly whatever arrives.
 */
function turnedBox(file: { width: number; height: number } | null): React.CSSProperties {
  if (file === null) {
    return {
      aspectRatio: '1',
      width: `min(${WIDTH_CAP}, ${HEIGHT_CAP})`,
      containerType: 'size'
    };
  }

  return {
    aspectRatio: `${file.height} / ${file.width}`,
    width: `min(${WIDTH_CAP}, ${file.height}px, calc(${HEIGHT_CAP} * ${file.height / file.width}))`,
    containerType: 'size'
  };
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
  protect = false,
  watermark,
  quarters = 0,
  flip = 'none',
  file = null
}: PlImagePreviewProps) {
  const sideways = isSideways(quarters);

  return (
    <PlOverlay
      open={open}
      onOpenChange={onOpenChange}
      tone="glass"
      dismissible
      color={color}
      label={label}
    >
      <span className="relative block" style={sideways ? turnedBox(file) : undefined}>
        <img
          src={src}
          alt={alt}
          className={cx(
            'block object-contain',
            sideways ? '' : 'max-h-[85vh] max-w-[90vw]',
            protect ? 'select-none [-webkit-touch-callout:none]' : ''
          )}
          // The same declarations the thumbnail was drawn with, so a turned
          // picture is laid out at the box's height by its width and fitted.
          style={poseStyle(quarters, flip) ?? undefined}
          draggable={protect ? false : undefined}
          onDragStart={protect ? (event) => event.preventDefault() : undefined}
          onContextMenu={protect ? (event) => event.preventDefault() : undefined}
        />

        {watermark === undefined ? null : <PlassWatermark watermark={watermark} />}
      </span>
    </PlOverlay>
  );
}
