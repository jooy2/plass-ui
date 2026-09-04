/**
 * The geometry a spotlight is cut out of, as arithmetic rather than as a
 * component.
 *
 * A tour dims the page and takes one thing out of the dimming. Everything hard
 * about that is a rectangle and a rounded corner, so it is here: it can be read
 * without a browser, tested without one, and it is the same shape the Flutter
 * build punches with `Path.combine`.
 */

/** Where the thing being pointed at is, in viewport coordinates. */
export interface PlassSpot {
  top: number;
  left: number;
  width: number;
  height: number;
}

/** A rectangle grown by [padding] on every side, never to a negative size. */
export function inflate(rect: PlassSpot, padding: number): PlassSpot {
  return {
    top: rect.top - padding,
    left: rect.left - padding,
    width: Math.max(0, rect.width + padding * 2),
    height: Math.max(0, rect.height + padding * 2)
  };
}

/** One rounded rectangle, as an SVG path. */
function roundedRect(spot: PlassSpot, radius: number): string {
  const { top: y, left: x, width: w, height: h } = spot;
  // A radius larger than half the shorter side draws a bow tie rather than a
  // rounded corner, which is what a two-pixel-tall target would ask for.
  const r = Math.max(0, Math.min(radius, w / 2, h / 2));

  if (r === 0) {
    return `M${x},${y}H${x + w}V${y + h}H${x}Z`;
  }

  return (
    `M${x + r},${y}` +
    `H${x + w - r}A${r},${r} 0 0 1 ${x + w},${y + r}` +
    `V${y + h - r}A${r},${r} 0 0 1 ${x + w - r},${y + h}` +
    `H${x + r}A${r},${r} 0 0 1 ${x},${y + h - r}` +
    `V${y + r}A${r},${r} 0 0 1 ${x + r},${y}Z`
  );
}

/**
 * How far the scrim's own shape is drawn past its edges.
 *
 * The outer rectangle only has to cover the element the clip is applied to, and
 * that element is `position: fixed; inset: 0` — so rather than measuring the
 * viewport and re-measuring it on every resize, the shape is simply drawn
 * bigger than any screen. A clip path larger than its element clips nothing
 * away, and not reading `window` is what lets this be called during a render
 * that has no window to read.
 */
const EDGE = 100000;

/**
 * The whole scrim with a hole in it, as a `clip-path` value.
 *
 * A clip and not a shadow, and that is the decision the whole component rests
 * on. The obvious way to draw a hole is one element the size of the target
 * carrying a box shadow larger than any screen; it works, and it buys nothing
 * else. A clip buys two things that matter:
 *
 * **The dimming can blur.** A `box-shadow` paints a colour. A clipped element
 * can carry a `backdrop-filter`, so the page around the spotlight is blurred as
 * well as dimmed — which is this library's own material rather than a grey wash
 * over it.
 *
 * **The hole is a hole for the pointer too.** A clipped-away region is not
 * hit-tested, so the scrim can take the pointer everywhere it is painted and
 * nowhere it is not. The reader can use the control being pointed at and
 * nothing else, which is what separates a tour from a dialog with a picture of
 * a control in it — and it falls out of the geometry rather than being a second
 * mechanism that has to agree with it.
 *
 * `null` is a step with no target: the whole page dims and nothing is cut out,
 * which is what a welcome step and a closing step are.
 */
export function spotlightPath(spot: PlassSpot | null, radius: number): string {
  const outer = `M0,0H${EDGE}V${EDGE}H0Z`;

  if (spot === null || spot.width <= 0 || spot.height <= 0) {
    return `path(evenodd,'${outer}')`;
  }

  return `path(evenodd,'${outer}${roundedRect(spot, radius)}')`;
}
