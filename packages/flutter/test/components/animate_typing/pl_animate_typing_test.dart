import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// What is actually drawn: the rich text that is being typed, not the invisible
/// copy holding the box.
String visibleOf(WidgetTester tester) {
  final Text drawn = tester.widget<Text>(
    find.byWidgetPredicate((Widget candidate) => candidate is Text && candidate.textSpan != null),
  );

  return ((drawn.textSpan! as TextSpan).children!.first as TextSpan).text ?? '';
}

void main() {
  group('PlAnimateTyping', () {
    testWidgets('gives a screen reader the whole string once', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(const PlAnimateTyping('Deploying to production', caret: false), width: 400),
      );

      expect(
        tester.getSemantics(find.byType(PlAnimateTyping)).getSemanticsData().label,
        'Deploying to production',
      );

      handle.dispose();
    });

    testWidgets('types it out one grapheme at a time', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlAnimateTyping('Hello', speed: 100, caret: false), width: 400),
      );

      expect(visibleOf(tester), '');

      await tester.pump(const Duration(milliseconds: 25));

      // A prefix, and not the whole string: it is being revealed rather than
      // switched on.
      expect(visibleOf(tester), isNot(''));
      expect('Hello'.startsWith(visibleOf(tester)), isTrue);
      expect(visibleOf(tester).length, lessThan(5));

      await tester.pump(const Duration(milliseconds: 60));
      expect(visibleOf(tester), 'Hello');
    });

    testWidgets('counts graphemes rather than code points', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlAnimateTyping('ab👩‍👩‍👧', speed: 100, caret: false), width: 400),
      );

      // Three graphemes, not nine code points: the family arrives whole rather
      // than being assembled out of parts that mean nothing on their own.
      await tester.pump(const Duration(milliseconds: 35));

      expect(visibleOf(tester), 'ab👩‍👩‍👧');
    });

    testWidgets('holds the box the whole string will need from the first frame', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateTyping('Deploying to production', speed: 100), width: 400),
      );

      final Size empty = tester.getSize(find.byType(PlAnimateTyping));

      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.getSize(find.byType(PlAnimateTyping)), empty);
    });

    group('caret', () {
      testWidgets('draws a block after the text', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAnimateTyping('Hi'), width: 400));

        expect(find.text('|'), findsOneWidget);
      });

      testWidgets('takes whatever character it was given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAnimateTyping('Hi', caretChar: '▌'), width: 400));

        expect(find.text('▌'), findsOneWidget);
      });

      testWidgets('can be turned off', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAnimateTyping('Hi', caret: false), width: 400));

        expect(find.text('|'), findsNothing);
      });
    });

    testWidgets('waits empty until it is played, rather than showing the whole line', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PlAnimateTyping(
            'Hello',
            speed: 100,
            caret: false,
            trigger: PlassAnimateTrigger.manual,
          ),
          width: 400,
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      expect(visibleOf(tester), '');

      await tester.pumpWidget(
        host(
          const PlAnimateTyping(
            'Hello',
            speed: 100,
            caret: false,
            trigger: PlassAnimateTrigger.manual,
            play: true,
          ),
          width: 400,
        ),
      );

      await tester.pump(const Duration(milliseconds: 60));

      expect(visibleOf(tester), 'Hello');
    });

    testWidgets('deletes the line again before repeating, one grapheme at a time', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PlAnimateTyping(
            'Hello',
            speed: 100,
            eraseSpeed: 100,
            hold: Duration(milliseconds: 100),
            erase: true,
            repeat: 2,
            caret: false,
          ),
          width: 400,
        ),
      );

      final List<String> seen = <String>[];

      for (int frame = 0; frame < 40; frame += 1) {
        await tester.pump(const Duration(milliseconds: 10));
        seen.add(visibleOf(tester));
      }

      // Without `erase` the only strings after the full one would be 'Hello'
      // and ''. With it there is a frame on every prefix, on the way back down.
      final int full = seen.indexOf('Hello');
      final List<String> after = seen.sublist(full);

      expect(full, greaterThanOrEqualTo(0));
      expect(after, contains('Hell'));
      expect(after, contains('H'));
      expect(after, contains(''));
    });

    testWidgets('is simply there where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateTyping('Hello', caret: false), width: 400, disableAnimations: true),
      );

      expect(visibleOf(tester), 'Hello');
    });
  });
}
