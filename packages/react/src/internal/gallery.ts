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
import { isSideways, quartersOf } from './image.js';
import { breakpoints, resolveAt } from './responsive.js';
import type { PlassResponsive } from '../types.js';

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
 * Whether an item's picture is turned onto its side.
 *
 * The gallery and its viewer both ask, so they ask here: a tile laid out on its
 * side that opened upright, or the other way round, would be one picture shown
 * two ways.
 */
export function isTurned(rotate: number | undefined): boolean {
  return rotate !== undefined && isSideways(quartersOf(rotate));
}

/**
 * The proportion an item is shown at: its file's own, or the inverse for a
 * picture on its side.
 *
 * An item's `ratio` stays the stored file's proportion, which is what a caller
 * has to hand, so every piece of layout arithmetic that runs before anything
 * loads reads it through this.
 */
export function shownRatio(ratio: number, rotate: number | undefined): number {
  return isTurned(rotate) ? 1 / ratio : ratio;
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

/**
 * One row track of a masonry: a share of the column width, the height of the
 * captions that end there, or the gap.
 */
export type PlassMasonryTrack = number | 'caption' | 'gap';

/** Where one tile sits in a masonry's grid, as `grid-column` and `grid-row` count. */
export interface PlassMasonryTile {
  /** The lane, from 1. */
  column: number;
  /** The row line the tile starts on. */
  start: number;
  /** The row line it ends on. */
  end: number;
}

/**
 * The same deal as `dealColumns`, written as the rows of one CSS grid rather
 * than as a list per lane.
 *
 * A list per lane put the document in lane order: Tab went 1, 4, 7 through
 * twelve pictures in three lanes, and a tile that changed lane when the count
 * did was a new element, with its picture's state thrown away. Placed in one
 * grid, every tile stays where it was given and only its placement changes.
 * The web build needs this and the Dart build does not, because a Flutter
 * layout is not a document.
 *
 * Every edge where a tile ends, in any lane, is a row line. The track up to it
 * is a share, sized in `fr` by its distance from the edge before, in column
 * widths. In a grid whose height is its content every `fr` then comes out one
 * column width long, so a tile spanning its shares is exactly as tall as its
 * picture. After the share come the captions that end on that edge, in a track
 * of their own so their height is not spread over the pictures, and then the
 * gap, when a tile starts there.
 *
 * What a stylesheet cannot know is where an edge in one lane falls among the
 * edges of another once the gaps and captions are added, because that depends
 * on the width. A tile that runs past the end of a tile in another lane spans
 * that tile's caption and gap tracks as well, and is that much taller than its
 * picture.
 */
export function masonryRows(
  ratios: readonly number[],
  columns: number,
  captions: boolean
): { tracks: PlassMasonryTrack[]; tiles: PlassMasonryTile[] } {
  const lanes = dealColumns(ratios, columns);
  const laneOf: number[] = [];
  const bottoms: number[] = [];
  // The tile above each one in its lane, or -1 for the first.
  const above: number[] = [];

  lanes.forEach((lane, index) => {
    let height = 0;

    lane.forEach((at, position) => {
      height += 1 / ratios[at];
      laneOf[at] = index;
      bottoms[at] = height;
      above[at] = position === 0 ? -1 : lane[position - 1];
    });
  });

  // Edges closer than a thousandth of a column width are one edge, so the same
  // ratios summed in two lanes end on one line whatever the floating point
  // made of them.
  const edges: number[] = [];
  const edgeOf: number[] = [];

  for (const at of ratios.map((_, index) => index).sort((a, b) => bottoms[a] - bottoms[b])) {
    if (edges.length === 0 || bottoms[at] - edges[edges.length - 1] > 1e-3) {
      edges.push(bottoms[at]);
    }

    edgeOf[at] = edges.length - 1;
  }

  const followed = new Set(above.filter((at) => at !== -1).map((at) => edgeOf[at]));
  const tracks: PlassMasonryTrack[] = [];
  const endLines: number[] = [];
  const startLines: number[] = [];

  edges.forEach((edge, index) => {
    tracks.push(edge - (index === 0 ? 0 : edges[index - 1]));

    if (captions) {
      tracks.push('caption');
    }

    endLines[index] = tracks.length + 1;

    if (followed.has(index)) {
      tracks.push('gap');
    }

    startLines[index] = tracks.length + 1;
  });

  const tiles = ratios.map((_, at) => ({
    column: laneOf[at] + 1,
    start: above[at] === -1 ? 1 : startLines[edgeOf[above[at]]],
    end: endLines[edgeOf[at]]
  }));

  return { tracks, tiles };
}

/**
 * A column count as a gallery uses it: a whole number of lanes, and at least
 * one. The column slot and the masonry deal both read it through here, so the
 * columns the stylesheet draws are the columns the tiles were dealt into.
 */
export function laneCount(value: number): number {
  return Math.max(1, Math.round(value));
}

/**
 * A masonry dealt at every rung of the breakpoint ladder, as the slots the
 * stylesheet switches between.
 *
 * Which lane a tile lands in depends on the heights of the tiles before it, so
 * a stylesheet cannot work it out — but it can choose between answers worked
 * out ahead of time. The deal is made once per lane count the columns name,
 * and the rung it starts at is written as slots: the list's rows as
 * `--p-lane-rows-{rung}`, and each tile's place and the number of rows it spans
 * as `--p-lane-area-{rung}` and `--p-lane-span-{rung}`. A rung that changes
 * nothing is left out, and the stylesheet carries the rung below up through it,
 * so a server's markup is laid out right at every width before any script has
 * run, and a resize redraws without React hearing about it.
 *
 * `track` writes one row track as CSS, because the gap and the caption rows
 * are lengths only the gallery knows.
 */
export function masonrySlots(
  ratios: readonly number[],
  columns: PlassResponsive<number>,
  captions: boolean,
  track: (track: PlassMasonryTrack) => string
): { list: Record<string, string>; tiles: Array<Record<string, string>> } {
  const list: Record<string, string> = {};
  const tiles: Array<Record<string, string>> = ratios.map(() => ({}));
  const lastArea: string[] = [];
  const lastSpan: string[] = [];
  let lastRows: string | undefined;
  let lastCount: number | undefined;

  for (const rung of breakpoints) {
    // Two below the first rung the columns name, which is what the stylesheet
    // draws there too.
    const count = laneCount(resolveAt(columns, rung) ?? 2);

    if (count === lastCount) {
      continue;
    }

    lastCount = count;

    const dealt = masonryRows(ratios, count, captions);
    const rows = dealt.tracks.map(track).join(' ');

    if (rows !== lastRows) {
      list[`--p-lane-rows-${rung}`] = rows;
      lastRows = rows;
    }

    dealt.tiles.forEach(({ column, start, end }, index) => {
      const area = `${start} / ${column} / ${end}`;
      const span = String(end - start);

      if (area !== lastArea[index]) {
        tiles[index][`--p-lane-area-${rung}`] = area;
        lastArea[index] = area;
      }

      if (span !== lastSpan[index]) {
        tiles[index][`--p-lane-span-${rung}`] = span;
        lastSpan[index] = span;
      }
    });
  }

  return { list, tiles };
}
