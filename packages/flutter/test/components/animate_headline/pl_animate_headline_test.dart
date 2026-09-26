import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/surface.dart';

import '../../support/host.dart';

/// The opacity each line is drawn at, in order.
List<double> opacitiesOf(WidgetTester tester) {
  return tester
      .widgetList<PlassFiltered>(
        find.descendant(of: find.byType(PlAnimateHeadline), matching: find.byType(PlassFiltered)),
      )
      .map((PlassFiltered layer) => layer.opacity)
      .toList();
}

List<Widget> get _lines => const <Widget>[Text('faster'), Text('simpler'), Text('cheaper')];

void main() {
  group('PlAnimateHeadline', () {
    testWidgets('adds no opacity layer for the line that is up', (WidgetTester tester) async {
      await tester.pumpWidget(host(PlAnimateHeadline(children: _lines), width: 200));

      // The line that is up is drawn at 1 until the reel turns, and the others
      // at 0, which is nothing painted and no layer either.
      expect(tester.layers.whereType<OpacityLayer>(), isEmpty);
    });

    testWidgets('reads only the line that is up', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(host(PlAnimateHeadline(children: _lines), width: 200));

      expect(semanticsLabels(tester), <String>['faster']);

      handle.dispose();
    });

    testWidgets('reads both lines for the whole of a swap, and then the new one', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      // A rise short enough that the line coming up is inside the box on the
      // first frame, rather than clipped out of it, and out of the semantics
      // for that reason alone.
      Widget headline(int index) => host(
        PlAnimateHeadline(
          index: index,
          rise: 4,
          duration: const Duration(milliseconds: 200),
          children: _lines,
        ),
        width: 200,
      );

      await tester.pumpWidget(headline(0));
      await tester.pumpWidget(headline(1));

      // The first frame of the swap, with the line coming up still at 0: both
      // are read, as the React build shows a line that is coming up or leaving
      // from the first frame of the swap to the last.
      expect(opacitiesOf(tester), <double>[1, 0, 0]);
      expect(semanticsLabels(tester), <String>['faster', 'simpler']);

      await tester.pumpAndSettle();

      expect(semanticsLabels(tester), <String>['simpler']);

      handle.dispose();
    });

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

      testWidgets('keeps turning inside a parent that rebuilds more often than the interval', (
        WidgetTester tester,
      ) async {
        final List<int> seen = <int>[];
        late StateSetter rebuild;

        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                rebuild = setState;

                // A new `onIndexChange` on every rebuild, as an inline closure is.
                return PlAnimateHeadline(
                  interval: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 50),
                  onIndexChange: (int index) => seen.add(index),
                  children: _lines,
                );
              },
            ),
            width: 200,
          ),
        );

        // Rebuilt every 50ms for twice the interval, with no quiet stretch in
        // which a timer restarted on every rebuild could still fire.
        for (int step = 0; step < 10; step += 1) {
          rebuild(() {});
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(seen, isNotEmpty);

        await tester.pumpWidget(host(const SizedBox.shrink(), width: 200));
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
