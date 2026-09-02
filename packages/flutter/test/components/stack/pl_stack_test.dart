import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// Five 32px squares, which is what every measurement below is made of.
List<Widget> _five({int count = 5}) {
  return <Widget>[
    for (int index = 0; index < count; index += 1)
      SizedBox(key: ValueKey<int>(index), width: 32, height: 32, child: Text('$index')),
  ];
}

/// Where each item ended up, relative to the pile's own top-left corner.
List<Offset> _offsets(WidgetTester tester, {int count = 5}) {
  final Offset origin = tester.getTopLeft(find.byType(PlStack));

  return <Offset>[
    for (int index = 0; index < count; index += 1)
      tester.getTopLeft(find.byKey(ValueKey<int>(index))) - origin,
  ];
}

void main() {
  group('PlStack', () {
    group('the box', () {
      testWidgets('measures exactly what it draws, in all three directions', (
        WidgetTester tester,
      ) async {
        // The whole argument for this being a layout rather than a transform: a
        // translated pile is laid out one item wide, paints outside its own box,
        // and everything after it is placed against a size the reader never
        // sees. Five 32px items at 10px of overlap is 5 x 32 - 4 x 10 across.
        const Map<PlStackDirection, Size> expected = <PlStackDirection, Size>{
          PlStackDirection.horizontal: Size(120, 32),
          PlStackDirection.vertical: Size(32, 120),
          PlStackDirection.diagonal: Size(120, 72),
        };

        for (final MapEntry<PlStackDirection, Size> entry in expected.entries) {
          await tester.pumpWidget(
            host(PlStack(direction: entry.key, overlap: 10, children: _five())),
          );

          expect(tester.getSize(find.byType(PlStack)), entry.value, reason: '${entry.key}');
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('lays every item out at its own size', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlStack(overlap: 10, children: _five())));

        for (int index = 0; index < 5; index += 1) {
          expect(tester.getSize(find.byKey(ValueKey<int>(index))), const Size(32, 32));
        }
      });
    });

    group('the flow', () {
      testWidgets('advances by the item less the overlap', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlStack(overlap: 10, children: _five())));

        expect(_offsets(tester), const <Offset>[
          Offset(0, 0),
          Offset(22, 0),
          Offset(44, 0),
          Offset(66, 0),
          Offset(88, 0),
        ]);
      });

      testWidgets('runs down the page when it is told to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlStack(direction: PlStackDirection.vertical, overlap: 10, children: _five())),
        );

        expect(_offsets(tester).map((Offset offset) => offset.dy), <double>[0, 22, 44, 66, 88]);
        expect(_offsets(tester).every((Offset offset) => offset.dx == 0), isTrue);
      });

      testWidgets('multiplies the drop by the index on the axis it does not flow on', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlStack(direction: PlStackDirection.diagonal, overlap: 10, drop: 10, children: _five()),
          ),
        );

        // A flow only overlaps on the axis it flows along. The other one has to
        // be multiplied by the item's own index, or every item sits at the same
        // height and the fan is a row.
        expect(_offsets(tester), const <Offset>[
          Offset(0, 0),
          Offset(22, 10),
          Offset(44, 20),
          Offset(66, 30),
          Offset(88, 40),
        ]);
      });

      testWidgets('falls back to the overlap for the drop', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlStack(direction: PlStackDirection.diagonal, overlap: 10, children: _five())),
        );

        expect(_offsets(tester)[4], const Offset(88, 40));
      });

      testWidgets('grows from the reader’s start, so it mirrors under RTL', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(PlStack(overlap: 10, children: _five()), textDirection: TextDirection.rtl),
        );

        // The first item is at the right-hand end of a 120px box, and the pile
        // grows leftwards from it.
        expect(_offsets(tester).map((Offset offset) => offset.dx), <double>[88, 66, 44, 22, 0]);
      });
    });

    group('max, total and overflow', () {
      testWidgets('stops at max and hands the rest to the builder as a number', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlStack(
              max: 2,
              overflow: (int hidden) => SizedBox(width: 32, height: 32, child: Text('+$hidden')),
              children: _five(),
            ),
          ),
        );

        expect(find.text('0'), findsOneWidget);
        expect(find.text('2'), findsNothing);
        expect(find.text('+3'), findsOneWidget);
      });

      testWidgets('counts against total when it was handed only the first few', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlStack(
              total: 11,
              overflow: (int hidden) => SizedBox(width: 32, height: 32, child: Text('+$hidden')),
              children: _five(),
            ),
          ),
        );

        expect(find.text('+6'), findsOneWidget);
      });

      testWidgets('leaves the count out entirely with no way to draw one', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(PlStack(max: 2, children: _five())));

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsNothing);
      });
    });

    group('the order', () {
      testWidgets('lets the last item take the press where they overlap', (
        WidgetTester tester,
      ) async {
        final List<int> pressed = <int>[];

        await tester.pumpWidget(
          host(
            PlStack(
              overlap: 20,
              children: <Widget>[
                for (int index = 0; index < 2; index += 1)
                  GestureDetector(
                    onTap: () => pressed.add(index),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(width: 32, height: 32),
                  ),
              ],
            ),
          ),
        );

        // The overlap runs from x=12 to x=32, and the item a reader can see
        // there is the one their finger has to land on.
        await tester.tapAt(tester.getTopLeft(find.byType(PlStack)) + const Offset(20, 16));

        expect(pressed, <int>[1]);
      });

      testWidgets('turns it round for a deck, whose top card is read first', (
        WidgetTester tester,
      ) async {
        final List<int> pressed = <int>[];

        await tester.pumpWidget(
          host(
            PlStack(
              overlap: 20,
              front: PlStackFront.first,
              children: <Widget>[
                for (int index = 0; index < 2; index += 1)
                  GestureDetector(
                    onTap: () => pressed.add(index),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(width: 32, height: 32),
                  ),
              ],
            ),
          ),
        );

        await tester.tapAt(tester.getTopLeft(find.byType(PlStack)) + const Offset(20, 16));

        expect(pressed, <int>[0]);
      });
    });

    group('depth', () {
      testWidgets('costs nothing while nobody asked for it', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlStack(children: _five())));

        expect(
          find.descendant(of: find.byType(PlStack), matching: find.byType(Opacity)),
          findsNothing,
        );
        expect(
          find.descendant(of: find.byType(PlStack), matching: find.byType(Transform)),
          findsNothing,
        );
      });

      testWidgets('compounds away from whichever end is in front', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlStack(opacityStep: 0.5, children: _five(count: 3))));

        // The front item is always at full strength, so turning `front` round
        // does not also have to turn the depth round.
        expect(
          tester
              .widgetList<Opacity>(
                find.descendant(of: find.byType(PlStack), matching: find.byType(Opacity)),
              )
              .map((Opacity opacity) => opacity.opacity),
          <double>[0.25, 0.5, 1],
        );
      });

      testWidgets('scales at paint time, so the pile does not close up behind it', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(PlStack(overlap: 10, scaleStep: 0.5, children: _five())));

        // A scaled item takes exactly the room it took before, which is what
        // keeps the step even while the items recede.
        expect(tester.getSize(find.byType(PlStack)), const Size(120, 32));
      });
    });

    testWidgets('draws no ring until it is given the shape of one', (WidgetTester tester) async {
      await tester.pumpWidget(host(PlStack(overlap: 10, children: _five())));

      expect(
        find.descendant(of: find.byType(PlStack), matching: find.byType(DecoratedBox)),
        findsNothing,
      );

      await tester.pumpWidget(
        host(PlStack(overlap: 10, ring: BorderRadius.circular(999), children: _five())),
      );

      // A radius rather than a `bool`, and the one place this diverges from the
      // React build: there CSS gives a ring the element's own `border-radius`
      // for nothing, and here nothing can read a child's shape.
      expect(
        find.descendant(of: find.byType(PlStack), matching: find.byType(DecoratedBox)),
        findsNWidgets(5),
      );

      // Painted as a spread shadow, so it costs no layout and the overlap
      // arithmetic is still about the item rather than the item plus its ring.
      expect(tester.getSize(find.byType(PlStack)), const Size(120, 32));
    });

    testWidgets('names the pile for a screen reader when it is told what it is', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(host(PlStack(semanticLabel: 'Reviewers', children: _five())));

      expect(find.bySemanticsLabel('Reviewers'), findsOneWidget);

      handle.dispose();
    });
  });
}
