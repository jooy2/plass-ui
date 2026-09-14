import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const String _line = 'Ship it on Friday';

/// The parts, in the order they were laid out.
List<String> _parts(WidgetTester tester) {
  return tester.widgetList<Text>(find.byType(Text)).map((Text text) => text.data!).toList();
}

/// Where each part was laid out, in the same order.
List<Rect> _rects(WidgetTester tester) {
  final Finder parts = find.byType(Text);

  return <Rect>[
    for (int index = 0; index < parts.evaluate().length; index += 1)
      tester.getRect(parts.at(index)),
  ];
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 320, height: 160));
  await tester.pump();
}

void main() {
  group('PlAnimateSplit', () {
    group('the cut', () {
      testWidgets('is by word by default, with the gaps kept', (WidgetTester tester) async {
        await _pump(tester, const PlAnimateSplit(text: _line));

        // The space is glued onto the word before it, which is what keeps a
        // line breaking between words rather than in front of a lone space.
        expect(_parts(tester), <String>['Ship ', 'it ', 'on ', 'Friday']);
      });

      testWidgets('is by character when it was asked for', (WidgetTester tester) async {
        await _pump(tester, const PlAnimateSplit(text: 'Ship', by: PlAnimateSplitBy.character));

        expect(_parts(tester), <String>['S', 'h', 'i', 'p']);
      });

      testWidgets('puts the whole line back together', (WidgetTester tester) async {
        await _pump(tester, const PlAnimateSplit(text: _line));

        expect(_parts(tester).join(), _line);
      });

      testWidgets('wraps a line cut by character between words, not partway through one', (
        WidgetTester tester,
      ) async {
        // Sixteen glyphs wide, in the test font that draws every glyph as a
        // square of its size. The line is nineteen and its second word fifteen,
        // so the gap is the one place it can wrap.
        await tester.pumpWidget(
          host(
            const PlAnimateSplit(
              text: 'Say internationally',
              by: PlAnimateSplitBy.character,
              style: TextStyle(fontSize: 10),
            ),
            width: 160,
            height: 160,
          ),
        );
        await tester.pumpAndSettle();

        final Finder parts = find.byType(Text);
        final List<double> tops = <double>[
          for (int index = 0; index < parts.evaluate().length; index += 1)
            tester.getTopLeft(parts.at(index)).dy,
        ];

        expect(tops[3], greaterThan(tops[0]));
        expect(tops.skip(3).toSet(), hasLength(1));
      });

      testWidgets('wraps a word wider than the whole line inside itself rather than overflowing', (
        WidgetTester tester,
      ) async {
        // Ten glyphs wide, and the word is fifteen.
        await tester.pumpWidget(
          host(
            const PlAnimateSplit(
              text: 'internationally',
              by: PlAnimateSplitBy.character,
              style: TextStyle(fontSize: 10),
            ),
            width: 100,
            height: 160,
          ),
        );
        await tester.pumpAndSettle();

        final Rect box = tester.getRect(find.byType(PlAnimateSplit));

        for (final Rect part in _rects(tester)) {
          expect(part.right, lessThanOrEqualTo(box.right));
        }
      });

      testWidgets('wraps a line in a script without spaces between its characters', (
        WidgetTester tester,
      ) async {
        // Twelve glyphs wide. A Japanese sentence has no gaps to wrap in: it
        // starts on the line of the word before it and wraps between its
        // characters, rather than dropping below that word as one block.
        await tester.pumpWidget(
          host(
            const PlAnimateSplit(
              text: 'Hi 日本語の文章はとても長いです',
              by: PlAnimateSplitBy.character,
              style: TextStyle(fontSize: 10),
            ),
            width: 120,
            height: 160,
          ),
        );
        await tester.pumpAndSettle();

        final Rect box = tester.getRect(find.byType(PlAnimateSplit));
        final List<Rect> parts = _rects(tester);

        expect(parts[2].top, lessThan(parts[0].bottom));
        expect(parts.last.top, greaterThanOrEqualTo(parts[0].bottom));

        for (final Rect part in parts) {
          expect(part.right, lessThanOrEqualTo(box.right));
        }
      });
    });

    group('the entrance', () {
      testWidgets('starts every part away from home and lands them all', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlAnimateSplit(
            text: _line,
            duration: Duration(milliseconds: 100),
            stagger: Duration(milliseconds: 40),
          ),
        );

        final double away = tester.getTopLeft(find.text('Friday')).dy;

        await tester.pumpAndSettle();

        // The last part travels furthest in time and still ends where it
        // belongs.
        expect(tester.getTopLeft(find.text('Friday')).dy, lessThan(away));
      });

      testWidgets('tells it off across the parts', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlAnimateSplit(
            text: _line,
            duration: Duration(milliseconds: 100),
            stagger: Duration(milliseconds: 200),
          ),
        );

        await tester.pump(const Duration(milliseconds: 120));

        // The first word has landed and the last one has not started.
        final double first = tester.getTopLeft(find.text('Ship ')).dy;
        final double last = tester.getTopLeft(find.text('Friday')).dy;

        expect(last, greaterThan(first));

        await tester.pumpAndSettle();
      });
    });

    testWidgets('tells a screen reader the line rather than the parts', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await _pump(tester, const PlAnimateSplit(text: _line));

      // The defect this pattern is known for is a headline read out one word at
      // a time.
      expect(find.bySemanticsLabel(_line), findsOneWidget);

      handle.dispose();
      await tester.pumpAndSettle();
    });
  });
}
