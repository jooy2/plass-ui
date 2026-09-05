'use client';

import * as React from 'react';

/** Where a watermark sits on the picture. */
export type PlassWatermarkPlacement =
  'top-start' | 'top-end' | 'bottom-start' | 'bottom-end' | 'tile';

/** A mark laid over a picture. A bare string is the text, in the usual corner. */
export interface PlassWatermarkOptions {
  /** What it says. */
  text: string;
  /** One in a corner, or `'tile'` for the whole picture. @default 'bottom-end' */
  placement?: PlassWatermarkPlacement;
  /** How far through it the picture shows. @default 0.55 in a corner, 0.14 tiled */
  opacity?: number;
  /** The turn a tiled mark is set at, in degrees. @default -24 */
  angle?: number;
  /** The ink. White is what reads on a photograph. @default 'white' */
  color?: string;
  /** The type size, in pixels. @default 13 in a corner, 15 tiled */
  fontSize?: number;
}

/** Normalised, so a bare string and a full object are one thing downstream. */
export function watermarkOptions(
  watermark: string | PlassWatermarkOptions
): Required<PlassWatermarkOptions> {
  const given = typeof watermark === 'string' ? { text: watermark } : watermark;
  const placement = given.placement ?? 'bottom-end';
  const tiled = placement === 'tile';

  return {
    text: given.text,
    placement,
    opacity: given.opacity ?? (tiled ? 0.14 : 0.55),
    angle: given.angle ?? -24,
    color: given.color ?? 'white',
    fontSize: given.fontSize ?? (tiled ? 15 : 13)
  };
}

/** XML's five, so a mark reading `Ada & Co <2026>` is a mark and not a parse error. */
function escapeXml(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

/**
 * One tile of a repeating mark, as an SVG data URI.
 *
 * A background image rather than a wall of elements. A photograph wants the
 * mark often enough that a tiled layer is forty or fifty copies of it, and forty
 * or fifty `<span>`s is forty or fifty things for the browser to lay out, for a
 * screen reader to be told to ignore, and for the caller's own CSS to trip over.
 * One declaration repeats itself for free.
 *
 * The tile is sized off the text rather than fixed, so a long mark spaces itself
 * out instead of overlapping the next copy along.
 */
function tileUri(text: string, color: string, fontSize: number): string {
  // Roughly the width of the string at this size. It only has to be generous —
  // the tile is a spacing decision, not a layout one.
  const width = Math.max(120, Math.round(text.length * fontSize * 0.68) + 48);
  const height = Math.round(fontSize * 4.6);
  const svg =
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}">` +
    `<text x="0" y="${Math.round(height / 2)}" fill="${color}" ` +
    `font-family="system-ui, sans-serif" font-size="${fontSize}" font-weight="600">` +
    `${escapeXml(text)}</text></svg>`;

  return `url("data:image/svg+xml,${encodeURIComponent(svg)}")`;
}

const cornerClasses: Record<Exclude<PlassWatermarkPlacement, 'tile'>, string> = {
  'top-start': 'top-2 start-2',
  'top-end': 'top-2 end-2',
  'bottom-start': 'bottom-2 start-2',
  'bottom-end': 'bottom-2 end-2'
};

/**
 * A mark over a picture, in a corner or across the whole of it.
 *
 * It is `aria-hidden` and takes no pointer: a watermark is a claim about the
 * file rather than something the page is telling a reader, and a screen reader
 * announcing "Ada & Co" between the picture and its caption is reading out a
 * stamp. The `alt` text is where a picture says what it is.
 *
 * The tiled layer is **rotated as one layer** rather than each copy being turned
 * on its own, which is what keeps the repeat seamless — turning the tiles inside
 * a straight grid leaves the grid's own lines showing through. It is drawn
 * oversized and centred so the corners the turn opens up are still covered.
 *
 * That rotation is a `transform`, and the house rule it sits beside is about
 * *controls*: a surface under a finger must not resample the label being pressed.
 * Nothing here is pressed and the angle never changes, so it is the same
 * allowance the chevrons in `PlGalleryViewer` are drawn with.
 */
export function PlassWatermark({ watermark }: { watermark: string | PlassWatermarkOptions }) {
  const { text, placement, opacity, angle, color, fontSize } = watermarkOptions(watermark);

  if (text === '') {
    return null;
  }

  if (placement === 'tile') {
    return (
      <span aria-hidden="true" className="pointer-events-none absolute inset-0 overflow-hidden">
        <span
          className="absolute block"
          style={{
            // Half again the box in both directions, pulled back by a quarter,
            // so the turn never brings an uncovered corner into view.
            inset: '-25%',
            width: '150%',
            height: '150%',
            opacity,
            transform: `rotate(${angle}deg)`,
            backgroundImage: tileUri(text, color, fontSize),
            backgroundRepeat: 'repeat'
          }}
        />
      </span>
    );
  }

  return (
    <span
      aria-hidden="true"
      className={`pointer-events-none absolute select-none font-semibold ${cornerClasses[placement]}`}
      style={{
        opacity,
        color,
        fontSize,
        // A photograph is not a background you can predict, so the mark carries
        // its own contrast rather than trusting what happens to be under it.
        textShadow: '0 1px 2px rgb(0 0 0 / 0.55)'
      }}
    >
      {text}
    </span>
  );
}
