/**
 * The cutting behind `PlAnimateScramble`, on text whose characters take more
 * than one UTF-16 code unit.
 *
 * `packages/flutter/test/internal/scramble_test.dart` asks the same questions,
 * because the two builds have to cut a line into the same pieces.
 */
import { describe, expect, it } from 'vitest';
import { poolOf, scrambleAt } from '../../src/internal/scramble.js';

/**
 * Whether the text holds half of a surrogate pair on its own, which draws as a
 * broken glyph.
 */
function hasBrokenGlyph(text: string): boolean {
  return Array.from(text).some((character) => {
    const unit = character.charCodeAt(0);

    return character.length === 1 && unit >= 0xd800 && unit <= 0xdfff;
  });
}

describe('scrambleAt', () => {
  it('draws every frame out of whole characters', () => {
    const line = 'go \u{1F680}';
    const pool = poolOf(line);

    // The pool holds a rocket, which is two code units. Indexed by code unit,
    // the noise is half of one as often as not.
    for (let seed = 0; seed < 8; seed += 1) {
      expect(hasBrokenGlyph(scrambleAt(line, pool, 0, seed))).toBe(false);
    }

    expect(scrambleAt(line, pool, 1, 0)).toBe(line);
  });

  it('settles a character built out of several code points in one step', () => {
    // Three characters to a reader, four code points to JavaScript: a flag is
    // two regional indicators. Counted by code point, a third of the way
    // through settles half of the flag and scrambles the other half.
    expect(scrambleAt('\u{1F1F0}\u{1F1F7}ab', '01', 0.34, 1)).toMatch(/^\u{1F1F0}\u{1F1F7}/u);
  });
});
