/**
 * Reading a node as the words it draws, and cutting those words the way a
 * reader cuts them.
 *
 * Both halves exist because more than one component needs them and all of them
 * have to arrive at the same answer as the Flutter build, which reads a widget
 * with `plassTextOf` in `lib/src/internal/text.dart` and cuts with
 * `String.characters`.
 */

import * as React from 'react';

/**
 * Everything in a node, flattened to its text.
 *
 * Strings and numbers are their own text, a list is its parts joined, and an
 * element contributes the text of its `children` and nothing else — a walk in,
 * not a render. What a component draws for itself is only decided when it
 * renders and cannot be read here, so a `<PlIcon />` among the children adds
 * nothing, which is exactly right for every caller: a picture of a thing is not
 * its name.
 *
 * Six places need it, and all six need it for the same reason — a string
 * where React would otherwise hand them a tree. `PlBreadcrumb` puts a step's
 * `name` into structured data, `PlChip` and `PlTransfer` hand a chip's words
 * and a list's heading to the label pack so that a language can put a name
 * where its own grammar puts it, `PlSelect` holds its trigger open at the
 * width of its labels' words without drawing a picture in any of them,
 * `PlAnimateTyping` types a string one grapheme at a time, because there is no
 * honest way to reveal half of a `<strong>`, and a chart's axis writes what a
 * `tickFormat` returned into an SVG `<text>`, which holds words and no markup.
 */
export function textOf(node: React.ReactNode): string {
  if (typeof node === 'string' || typeof node === 'number') {
    return String(node);
  }

  if (Array.isArray(node)) {
    return node.map(textOf).join('');
  }

  if (React.isValidElement<{ children?: React.ReactNode }>(node)) {
    return textOf(node.props.children);
  }

  return '';
}

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
