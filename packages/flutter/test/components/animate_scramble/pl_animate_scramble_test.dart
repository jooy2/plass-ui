import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const String _line = 'Ship it on Friday';

/// What a sighted reader sees right now.
String _drawn(WidgetTester tester) => tester.widget<Text>(find.byType(Text)).data!;

Future<void> _pump(WidgetTester tester, Widget child, {bool disableAnimations = false}) async {
  await tester.pumpWidget(
    host(child, width: 320, height: 120, disableAnimations: disableAnimations),
  );
  await tester.pump();
}

void main() {
  group('PlAnimateScramble', () {
    testWidgets('starts as noise rather than as the line', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlAnimateScramble(text: _line, trigger: PlassAnimateTrigger.manual),
      );

      expect(_drawn(tester), isNot(_line));
    });

    testWidgets('settles on the line it was given', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlAnimateScramble(
          text: _line,
          trigger: PlassAnimateTrigger.manual,
          play: true,
          duration: Duration(milliseconds: 100),
        ),
      );

      await tester.pumpAndSettle();

      expect(_drawn(tester), _line);
    });

    group('the noise', () {
      testWidgets('is made of the line’s own characters', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlAnimateScramble(text: _line, trigger: PlassAnimateTrigger.manual),
        );

        final Set<String> own = _line.split('').toSet();

        for (final String character in _drawn(tester).split('')) {
          expect(own.contains(character), isTrue);
        }
      });

      testWidgets('does the same in a script with no Latin letters in it', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlAnimateScramble(text: '금요일에 배포합니다', trigger: PlassAnimateTrigger.manual),
        );

        expect(_drawn(tester), isNot(matches(RegExp('[A-Za-z]'))));
      });

      testWidgets('takes a pool of its own', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlAnimateScramble(
            text: _line,
            characters: '01',
            trigger: PlassAnimateTrigger.manual,
          ),
        );

        expect(_drawn(tester).replaceAll(' ', ''), matches(RegExp(r'^[01]+$')));
      });

      testWidgets('never scrambles the spaces, and never changes the length', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlAnimateScramble(text: _line, trigger: PlassAnimateTrigger.manual),
        );

        final String drawn = _drawn(tester);

        expect(drawn.length, _line.length);

        for (int index = 0; index < _line.length; index += 1) {
          if (_line[index] == ' ') {
            expect(drawn[index], ' ');
          }
        }
      });
    });

    testWidgets('is simply the line where the platform asked for less motion', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlAnimateScramble(text: _line, trigger: PlassAnimateTrigger.manual),
        disableAnimations: true,
      );

      expect(_drawn(tester), _line);
    });

    testWidgets('tells a screen reader the line rather than the noise', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await _pump(
        tester,
        const PlAnimateScramble(text: _line, trigger: PlassAnimateTrigger.manual),
      );

      expect(find.bySemanticsLabel(_line), findsOneWidget);
      expect(_drawn(tester), isNot(_line));

      handle.dispose();
    });
  });
}
