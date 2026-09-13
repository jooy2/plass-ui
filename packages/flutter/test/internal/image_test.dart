import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/image.dart';

void main() {
  group('quartersOf', () {
    test('counts the four quarters', () {
      expect(<int>[0, 90, 180, 270].map(quartersOf), <int>[0, 1, 2, 3]);
    });

    test('reads a turn the other way as the clockwise one it means', () {
      expect(quartersOf(-90), 3);
      expect(quartersOf(-180), 2);
    });

    test('takes a whole turn and more back round', () {
      expect(quartersOf(360), 0);
      expect(quartersOf(450), 1);
      expect(quartersOf(-450), 3);
    });

    test('goes to the nearer quarter, and up from halfway', () {
      // The same answers `internal/image.ts` gives, `-45` included.
      expect(quartersOf(44), 0);
      expect(quartersOf(45), 1);
      expect(quartersOf(-45), 0);
      expect(quartersOf(-46), 3);
    });

    test('is no turn at all for a number that is not one', () {
      expect(quartersOf(double.nan), 0);
      expect(quartersOf(double.infinity), 0);
    });
  });

  group('isSideways', () {
    test('is true for the odd quarters only', () {
      expect(<int>[0, 1, 2, 3].map(isSideways), <bool>[false, true, false, true]);
    });
  });
}
