/**
 * The arithmetic a `PlGallery` lays itself out with.
 *
 * It is here rather than in the component for the reason `internal/steps.ts`
 * is: **the Dart build needs the same answers.** A masonry that dealt its
 * columns differently on the two sides would be one gallery with two orders,
 * and the order is the only thing about a masonry a reader can check.
 *
 * Nothing in here measures anything. Every function takes the ratios the caller
 * declared, which is what lets the whole arrangement be right in the first
 * frame the browser paints and stay put as the files arrive — the bargain
 * `PlImage`'s own `ratio` makes, one level up, and the reason a gallery of
 * forty photographs does not reflow forty times.
 */

/**
 * A tile's proportion as the number the layouts do arithmetic on.
 *
 * A ratio is `16 / 9` as often as it is `1.78`, because that is how CSS writes
 * one and this library does not make a caller translate it.
 */
export function ratioOf(value: number | string | undefined, fallback: number): number {
  if (value === undefined) {
    return fallback;
  }

  if (typeof value === 'number') {
    return value > 0 ? value : fallback;
  }

  const [width, height] = value.split('/');
  const parsed = height === undefined ? Number(width) : Number(width) / Number(height);

  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

/**
 * The items dealt into columns, shortest column first.
 *
 * Not CSS `columns`, which fills the first column top to bottom before it
 * starts the second — so a set numbered 1 to 12 reads *down* the left edge, and
 * the first three pictures a reader meets are stacked on top of each other.
 * Dealt this way the first row is items 1, 2 and 3, which is the order they
 * were given in.
 *
 * The heights are the ratios rather than anything measured, which is what makes
 * this run on the server and hold still while the files arrive.
 */
export function dealColumns(ratios: readonly number[], columns: number): number[][] {
  const lanes: number[][] = Array.from({ length: columns }, () => []);
  const heights = new Array<number>(columns).fill(0);

  ratios.forEach((ratio, index) => {
    let shortest = 0;

    for (let lane = 1; lane < columns; lane += 1) {
      if (heights[lane] < heights[shortest]) {
        shortest = lane;
      }
    }

    lanes[shortest].push(index);
    // One unit of width over the ratio is the height that unit of width draws.
    heights[shortest] += 1 / ratio;
  });

  return lanes;
}
