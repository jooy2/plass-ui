/**
 * The arithmetic a `PlImage` turns and mirrors its picture with, and the
 * declarations that draw the two.
 *
 * The arithmetic is here rather than in the component for the reason
 * `internal/gallery.ts` is: **the Dart build needs the same answers.** A turn
 * that rounded a stray `45` to a different quarter on the two sides would be one
 * picture lying two different ways. The declarations are here because the
 * preview draws the same turn and mirror from a chunk of its own.
 */
import type * as React from 'react';

/** A turn, as a count of clockwise quarters. */
export type PlassQuarters = 0 | 1 | 2 | 3;

/**
 * Which way a picture is mirrored, along the axes it is shown on.
 *
 * Declared here rather than beside the component because the declarations
 * below are written from it; `PlImageFlip` is this under the component's name.
 */
export type PlassImageFlip = 'none' | 'horizontal' | 'vertical' | 'both';

/**
 * A turn in degrees as a count of clockwise quarters, whatever number arrived.
 *
 * The type holds a TypeScript caller to `0`, `90`, `180` and `270`; this is for
 * everyone else. `-90` is the `270` it means, `450` is `90`, anything between
 * two quarters goes to the nearer one, and a number that is not finite is no
 * turn at all.
 */
export function quartersOf(degrees: number): PlassQuarters {
  if (!Number.isFinite(degrees)) {
    return 0;
  }

  return (((Math.round(degrees / 90) % 4) + 4) % 4) as PlassQuarters;
}

/** Whether a turn puts the picture on its side, swapping its width and height. */
export function isSideways(quarters: PlassQuarters): boolean {
  return quarters % 2 === 1;
}

/**
 * The turn and the mirror, as the declarations that draw them.
 *
 * The individual `rotate` and `scale` properties rather than `transform`, which
 * leaves `transform` to whoever else wants the picture: an inline `transform`
 * here would silently beat a hover effect or a class of the caller's own.
 *
 * The two compose in a fixed order, and scale comes first: it acts on the
 * element before the element is turned. So on a quarter turn, a mirror along one
 * axis of the screen is a mirror along the other axis of the element, and the
 * two are swapped here rather than making a caller think about it.
 *
 * On its side the picture is laid out at the box's height by the box's width
 * and turned into place, and that is what lets `fit` work at all. `object-fit`
 * fits the element's own box, and a picture turned inside the box it was given
 * would overhang it on one axis and fall short on the other. The container
 * units read the box, which is a size container only while this is the case;
 * `maxWidth` is cleared because a reset caps an `<img>` at the width of its
 * parent, and on a tall box that is shorter than the length the turned picture
 * needs.
 */
export function poseStyle(
  quarters: PlassQuarters,
  flip: PlassImageFlip
): React.CSSProperties | null {
  const across = flip === 'horizontal' || flip === 'both';
  const down = flip === 'vertical' || flip === 'both';

  if (quarters === 0 && !across && !down) {
    return null;
  }

  const [mirrorX, mirrorY] = isSideways(quarters) ? [down, across] : [across, down];

  return {
    scale: mirrorX || mirrorY ? `${mirrorX ? -1 : 1} ${mirrorY ? -1 : 1}` : undefined,
    rotate: quarters === 0 ? undefined : `${quarters * 90}deg`,
    ...(isSideways(quarters)
      ? {
          position: 'absolute',
          top: '50%',
          left: '50%',
          width: '100cqh',
          height: '100cqw',
          maxWidth: 'none',
          translate: '-50% -50%'
        }
      : null)
  };
}
