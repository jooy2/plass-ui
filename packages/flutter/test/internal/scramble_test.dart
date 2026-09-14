/// The cutting behind `PlAnimateSplit` and `PlAnimateScramble`, on text whose
/// characters take more than one UTF-16 code unit.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/scramble.dart';

/// Whether [text] holds half of a surrogate pair on its own, which draws as a
/// broken glyph.
bool _hasBrokenGlyph(String text) {
  return text.runes.any((int rune) => rune >= 0xD800 && rune <= 0xDFFF);
}

void main() {
  group('splitParts', () {
    test('keeps a character built out of several code points in one part', () {
      // A letter with a combining accent, and a flag made of two regional
      // indicators.
      expect(splitParts('é\u{1F1F0}\u{1F1F7}', byCharacter: true), <String>[
        'é',
        '\u{1F1F0}\u{1F1F7}',
      ]);
    });
  });

  group('scrambleAt', () {
    test('draws every frame out of whole characters', () {
      const String line = 'go \u{1F680}';
      final String pool = poolOf(line);

      for (int seed = 0; seed < 8; seed += 1) {
        expect(_hasBrokenGlyph(scrambleAt(line, pool, 0, seed)), isFalse, reason: 'seed $seed');
      }

      expect(scrambleAt(line, pool, 1, 0), line);
    });
  });
}
