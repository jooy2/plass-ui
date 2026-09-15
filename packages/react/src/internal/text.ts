/**
 * Cutting a string the way a reader cuts it.
 *
 * Three components take a line apart — a typewriter, a split entrance and a
 * scramble — and all three have to arrive at the same pieces as the Flutter
 * build, which cuts with `String.characters`.
 */

/**
 * The segmenter, built once.
 *
 * `new Intl.Segmenter` is not free and a scramble asks for its characters
 * twenty times a second, so the object is kept rather than made per call. It
 * takes no locale for the same reason it can be shared: no caller passes one,
 * and where a grapheme ends is all but the same question in every language.
 *
 * `undefined` is "not looked for yet" and `null` is "this runtime has none".
 */
let shared: Intl.Segmenter | null | undefined;

function segmenter(): Intl.Segmenter | null {
  if (shared === undefined) {
    shared =
      typeof Intl !== 'undefined' && 'Segmenter' in Intl
        ? new Intl.Segmenter(undefined, { granularity: 'grapheme' })
        : null;
  }

  return shared;
}

/**
 * The text cut the way a reader would cut it.
 *
 * Not `[...text]`, and not `text.split('')`. A code point is not a character:
 * `👩‍👩‍👧` is seven of them, a flag is two, and `한` typed on a Korean keyboard
 * can be three. Cut by code point, each of those comes back as pieces that
 * mean nothing on their own and draw as broken glyphs. `Intl.Segmenter` knows
 * where the boundaries actually are; the spread is the fallback for a runtime
 * that does not have it.
 */
export function graphemesOf(text: string): string[] {
  const cutter = segmenter();

  return cutter === null ? [...text] : [...cutter.segment(text)].map((part) => part.segment);
}
