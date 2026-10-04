/**
 * What "this matches what I typed" means, once.
 *
 * Two components let a reader type at a list of their own — `PlTransfer` and
 * `PlCommandPalette` — and a `matches` in each of them is two answers to one
 * question. They would disagree, and not because anybody chose: a reader who
 * has learned what the filter in one part of a product does has learned the
 * wrong thing about the rest of it.
 *
 * It is also where the fixed cost of typing lives. `String.prototype.normalize`
 * is the expensive call here by a wide margin, so the shape of this is folding
 * a haystack **once** and a needle **once** rather than folding both on every
 * comparison — which is what a `matches(item, query)` signature quietly asks
 * for, and what would put a `normalize` on every row on every keystroke.
 */

/** The combining marks `NFD` splits an accented letter into. */
const COMBINING = /[\u0300-\u036f]/g;

/**
 * What a haystack's parts are joined on: a character no keyboard produces, so a
 * query cannot span the seam between two fields and find a row on text that is
 * not next to itself.
 */
const SEAM = '\u0000';

/**
 * A value as something a query can be matched against.
 *
 * Case-folded and stripped of combining marks, so `jose` finds `José` and
 * `SEOUL` finds `Seoul`. `NFD` splits an accented letter into the letter and
 * its accent and the range then deletes the accent; a search field is the one
 * place where losing that distinction is the point.
 *
 * Anything that is not a primitive folds to the empty string. What a reader
 * sees came out of the caller's own rendering, and guessing at the text inside
 * a React element is how a list ends up not finding a row that is on the
 * screen — a row that wants to be searchable says so in a string.
 */
export function searchText(value: unknown): string {
  if (value === null || value === undefined || typeof value === 'object') {
    return '';
  }

  return String(value).normalize('NFD').replace(COMBINING, '').toLowerCase();
}

/** Every string a row can be found by, folded once and joined into one haystack. */
export function searchHaystack(values: readonly unknown[]): string {
  return values.map(searchText).join(SEAM);
}

/**
 * `searchText` of what `read` finds on an item, remembered per item.
 *
 * Only the needle changes from one keystroke to the next, so a filter that
 * folds its items as it goes folds every one of them again for every character
 * typed. This folds an item the first time a query reaches it and hands the
 * same text back after that, for as long as `read` finds the same value on it —
 * an item whose text changed is folded again, so nothing it answers is stale.
 * Kept by the item itself, weakly, so an item nobody holds any more takes its
 * text with it.
 */
export function cachedSearchText<Item extends object>(
  read: (item: Item) => unknown
): (item: Item) => string {
  const folded = new WeakMap<Item, { value: unknown; text: string }>();

  return (item) => {
    const value = read(item);
    const known = folded.get(item);

    if (known && Object.is(known.value, value)) {
      return known.text;
    }

    const text = searchText(value);

    folded.set(item, { value, text });

    return text;
  };
}
