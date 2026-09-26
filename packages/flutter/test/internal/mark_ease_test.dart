/// That a chart mark eases towards its state over the duration it is given,
/// sets off back from where it stands when the state turns round, runs on a
/// clock of its own beside the other marks, and arrives at once for a zero
/// duration without running a frame for it.
library;

import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/mark_ease.dart';

const Duration _length = Duration(milliseconds: 100);

void main() {
  group('PlassMarkEase', () {
    late PlassMarkEase ease;

    setUp(() => ease = PlassMarkEase(const TestVSync()));
    tearDown(() => ease.dispose());

    /// Aims [on] on a straight line over [_length].
    void aim(Set<Object> on) => ease.aim(on, duration: _length, curve: Curves.linear);

    testWidgets('starts every key at rest', (WidgetTester tester) async {
      expect(ease.of('a'), 0);
    });

    testWidgets('eases a key to its state, and back from where it stands', (
      WidgetTester tester,
    ) async {
      aim(<Object>{'a'});

      // The clock starts on the first frame, as an animation's does.
      await tester.pump();
      expect(ease.of('a'), 0);

      await tester.pump(_length ~/ 2);
      expect(ease.of('a'), closeTo(0.5, 1e-9));

      aim(<Object>{});
      await tester.pump();
      expect(ease.of('a'), closeTo(0.5, 1e-9));

      await tester.pump(_length ~/ 2);
      expect(ease.of('a'), closeTo(0.25, 1e-9));

      await tester.pump(_length);
      expect(ease.of('a'), 0);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('keeps a key heading the same way on its own clock', (WidgetTester tester) async {
      aim(<Object>{'a'});
      await tester.pump();
      await tester.pump(_length ~/ 2);

      aim(<Object>{'a', 'b'});
      await tester.pump();
      await tester.pump(_length ~/ 2);

      // The first arrived when it would have, and the second is halfway.
      expect(ease.of('a'), 1);
      expect(ease.of('b'), closeTo(0.5, 1e-9));

      await tester.pump(_length);
    });

    testWidgets('stands exactly where it arrived, with nothing left running', (
      WidgetTester tester,
    ) async {
      aim(<Object>{'a'});
      await tester.pump();
      await tester.pump(_length * 3);

      expect(ease.of('a'), 1);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('puts every key where it is going at once for a zero duration', (
      WidgetTester tester,
    ) async {
      aim(<Object>{'a'});
      await tester.pump();
      await tester.pump(_length ~/ 2);

      ease.aim(<Object>{'b'}, duration: Duration.zero, curve: Curves.linear);

      expect(ease.of('a'), 0);
      expect(ease.of('b'), 1);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('eases on the curve it is given', (WidgetTester tester) async {
      ease.aim(<Object>{'a'}, duration: _length, curve: Curves.easeIn);
      await tester.pump();
      await tester.pump(_length ~/ 2);

      expect(ease.of('a'), closeTo(Curves.easeIn.transform(0.5), 1e-9));

      await tester.pump(_length);
    });

    testWidgets('tells its listeners on every frame it moves', (WidgetTester tester) async {
      int told = 0;

      ease.addListener(() => told += 1);
      aim(<Object>{'a'});
      await tester.pump();
      await tester.pump(_length ~/ 2);
      await tester.pump(_length);

      expect(told, 3);
    });
  });
}
