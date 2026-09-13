/**
 * The arithmetic a `PlImage` turns, mirrors and places its picture with, and the
 * declarations that draw the turn and the mirror.
 *
 * The arithmetic is here rather than in the component for the reason
 * `internal/gallery.ts` is: **the Dart build needs the same answers.** A turn
 * that rounded a stray `45` to a different quarter on the two sides would be one
 * picture lying two different ways, and a crop that kept a different part of it
 * would be two pictures. The declarations are here because the preview draws
 * the same turn and mirror from a chunk of its own.
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

/**
 * The geometry of a copy of the picture drawn underneath it: the same turn and
 * mirror, over the same box grown by `bleed` on every side.
 *
 * A blur fades to transparent over about two of its radii at the element's
 * edge, so a blurred copy drawn at the box's own size would show the page
 * through a soft frame. Grown past the box, it has the fringe clipped off by the
 * box's `overflow: hidden` instead.
 */
export function layerStyle(
  quarters: PlassQuarters,
  flip: PlassImageFlip,
  bleed: number
): React.CSSProperties {
  const grown = (length: string) => (bleed === 0 ? length : `calc(${length} + ${bleed * 2}px)`);

  if (isSideways(quarters)) {
    return { ...poseStyle(quarters, flip), width: grown('100cqh'), height: grown('100cqw') };
  }

  return {
    ...poseStyle(quarters, flip),
    position: 'absolute',
    top: `${-bleed}px`,
    left: `${-bleed}px`,
    width: grown('100%'),
    height: grown('100%'),
    maxWidth: 'none'
  };
}

/**
 * A position as the fractions of the free space across and down, or `null` for
 * anything past the keywords and percentages `PlImagePosition` offers.
 *
 * The part of CSS's grammar a caller writes. A keyword says its own axis, a
 * percentage is across when it comes first and down when it comes second, and
 * `center` says nothing, which leaves the axis at the middle. A length has no
 * fraction to turn, so it is `null`.
 */
export function positionFractions(position: string): [number, number] | null {
  const fractions: [number, number] = [0.5, 0.5];
  const words = position.trim().toLowerCase().split(/\s+/);

  for (let index = 0; index < words.length; index += 1) {
    // Even sides are across and odd ones down; the first two are the near edge.
    const side = ['left', 'top', 'right', 'bottom'].indexOf(words[index]);

    if (side >= 0) {
      fractions[side % 2] = side > 1 ? 1 : 0;
    } else if (/^-?\d*\.?\d+%$/.test(words[index])) {
      fractions[index === 0 ? 0 : 1] = parseFloat(words[index]) / 100;
    } else if (words[index] !== 'center') {
      return null;
    }
  }

  return fractions;
}

/**
 * A place on the picture as it is shown, as the same place on the element that
 * is actually turned and mirrored.
 *
 * `object-position` works in the element's own frame, before it is transformed,
 * so `top` on a picture turned upside down would keep what ends up at the
 * bottom. The mirror is undone first, because it acts on the axes of the screen
 * after the turn. Then the turn, a quarter at a time: one quarter clockwise lays
 * the element's left edge along the top of the screen, so what is across on the
 * screen was down the element.
 */
export function elementFractions(
  [shownAcross, shownDown]: readonly [number, number],
  quarters: PlassQuarters,
  mirrorAcross: boolean,
  mirrorDown: boolean
): [number, number] {
  let across = mirrorAcross ? 1 - shownAcross : shownAcross;
  let down = mirrorDown ? 1 - shownDown : shownDown;

  for (let turn = 0; turn < quarters; turn += 1) {
    [across, down] = [down, 1 - across];
  }

  return [across, down];
}

/**
 * The `object-position` that keeps `position` where the reader sees it.
 *
 * Always written as two percentages rounded to two decimals, which every engine
 * serialises the same way. A string the parser cannot read is handed through as
 * it was written.
 */
export function objectPosition(
  position: string,
  quarters: PlassQuarters,
  flip: PlassImageFlip
): string {
  const shown = positionFractions(position);

  if (shown === null) {
    return position;
  }

  const [across, down] = elementFractions(
    shown,
    quarters,
    flip === 'horizontal' || flip === 'both',
    flip === 'vertical' || flip === 'both'
  );
  const percent = (fraction: number) => `${Math.round(fraction * 10000) / 100}%`;

  return `${percent(across)} ${percent(down)}`;
}
