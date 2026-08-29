import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The opacity each line is drawn at, in order.
List<double> opacitiesOf(WidgetTester tester) {
  return tester
      .widgetList<Opacity>(
        find.descendant(of: find.byType(PlAnimateHeadline), matching: find.byType(Opacity)),
      )
      .map((Opacity layer) => layer.opacity)
      .toList();
}

List<Widget> get _lines => const <Widget>[Text('faster'), Text('simpler'), Text('cheaper')];

void main() {
  group('PlAnimateHeadline', () {
    testWidgets('keeps every line in the tree, in one cell', (WidgetTester tester) async {
      await tester.pumpWidget(host(PlAnimateHeadline(children: _lines), width: 200));

      expect(find.text('faster'), findsOneWidget);
      expect(find.text('simpler'), findsOneWidget);
      expect(find.text('cheaper'), findsOneWidget);
      expect(opacitiesOf(tester), hasLength(3));
    });

    testWidgets('shows the first line and no other', (WidgetTester tester) async {
      await tester.pumpWidget(host(PlAnimateHeadline(children: _lines), width: 200));

      expect(opacitiesOf(tester), <double>[1, 0, 0]);
    });

    testWidgets('starts an uncontrolled reel wherever it was told to', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(PlAnimateHeadline(defaultIndex: 1, children: _lines), width: 200),
      );

      expect(opacitiesOf(tester), <double>[0, 1, 0]);
    });

    group('controlled', () {
      testWidgets('shows whichever line the caller says', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlAnimateHeadline(index: 0, children: _lines), width: 200));

        await tester.pumpWidget(host(PlAnimateHeadline(index: 1, children: _lines), width: 200));
        await tester.pumpAndSettle();

        expect(opacitiesOf(tester), <double>[0, 1, 0]);
      });

      testWidgets('clamps an index past the end onto the last line', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlAnimateHeadline(index: 9, children: _lines), width: 200));

        expect(opacitiesOf(tester), <double>[0, 0, 1]);
      });

      testWidgets('does not run a timer of its own, which would fight the caller', (
        WidgetTester tester,
      ) async {
        int changes = 0;

        await tester.pumpWidget(
          host(
            PlAnimateHeadline(
              index: 0,
              interval: const Duration(milliseconds: 20),
              onIndexChange: (int _) => changes += 1,
              children: _lines,
            ),
            width: 200,
          ),
        );

        await tester.pump(const Duration(milliseconds: 200));

        expect(changes, 0);
      });
    });

    group('uncontrolled', () {
      testWidgets('turns on its own and reports each line as it comes up', (
        WidgetTester tester,
      ) async {
        final List<int> seen = <int>[];

        await tester.pumpWidget(
          host(
            PlAnimateHeadline(
              interval: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 50),
              onIndexChange: seen.add,
              children: _lines,
            ),
            width: 200,
          ),
        );

        // No `pumpAndSettle` here: a looping reel never settles.
        await tester.pump(const Duration(milliseconds: 120));
        await tester.pump(const Duration(milliseconds: 60));

        expect(seen, <int>[1]);
        expect(opacitiesOf(tester), <double>[0, 1, 0]);
      });

      testWidgets('stops on the last line when it is not looping', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlAnimateHeadline(
              loop: false,
              defaultIndex: 2,
              interval: const Duration(milliseconds: 50),
              children: _lines,
            ),
            width: 200,
          ),
        );

        await tester.pump(const Duration(milliseconds: 400));

        expect(opacitiesOf(tester), <double>[0, 0, 1]);
      });

      testWidgets('holds still while it is paused', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlAnimateHeadline(
              paused: true,
              interval: const Duration(milliseconds: 50),
              children: _lines,
            ),
            width: 200,
          ),
        );

        await tester.pump(const Duration(milliseconds: 400));

        expect(opacitiesOf(tester), <double>[1, 0, 0]);
      });
    });

    testWidgets('travels one line height unless a rise says otherwise', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(PlAnimateHeadline(children: _lines), width: 200));

      expect(
        find.descendant(
          of: find.byType(PlAnimateHeadline),
          matching: find.byType(FractionalTranslation),
        ),
        findsWidgets,
      );

      await tester.pumpWidget(host(PlAnimateHeadline(rise: 24, children: _lines), width: 200));

      expect(
        find.descendant(
          of: find.byType(PlAnimateHeadline),
          matching: find.byType(FractionalTranslation),
        ),
        findsNothing,
      );
    });

    testWidgets('clips, so a line on its way out does not show past the box', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(PlAnimateHeadline(children: _lines), width: 200));

      expect(
        find.descendant(of: find.byType(PlAnimateHeadline), matching: find.byType(ClipRect)),
        findsOneWidget,
      );
    });
  });
}
