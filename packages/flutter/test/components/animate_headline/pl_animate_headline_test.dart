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

      testWidgets('stops turning while it is scrolled out of view, and holds the line it '
          'stopped on for what was left of its interval when it is back', (
        WidgetTester tester,
      ) async {
        final List<int> seen = <int>[];
        final ScrollController page = ScrollController();

        addTearDown(page.dispose);

        await tester.pumpWidget(
          scrollingPage(
            page,
            SizedBox(
              width: 200,
              child: PlAnimateHeadline(
                interval: const Duration(milliseconds: 1000),
                duration: const Duration(milliseconds: 50),
                onIndexChange: seen.add,
                children: _lines,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        page.jumpTo(600);
        await pumpScrolled(tester);

        // It used to go on turning, a line a second, for nobody.
        expect(await redrawsIn(tester), isFalse);
        expect(seen, isEmpty);

        page.jumpTo(0);
        await pumpScrolled(tester);
        await tester.pump(const Duration(milliseconds: 499));

        // Half the interval had gone by when it was scrolled away. It used to
        // wait a whole one again.
        expect(seen, isEmpty);

        await tester.pump(const Duration(milliseconds: 1));

        expect(seen, <int>[1]);
      });

      group('its wait for the next line', () {
        Widget reel(
          List<int> seen, {
          bool paused = false,
          bool play = true,
          PlassAnimateTrigger trigger = PlassAnimateTrigger.mount,
          Duration interval = const Duration(milliseconds: 1000),
          Duration delay = Duration.zero,
          bool loop = true,
          int lines = 3,
        }) {
          return host(
            PlAnimateHeadline(
              paused: paused,
              trigger: trigger,
              play: play,
              interval: interval,
              delay: delay,
              loop: loop,
              duration: const Duration(milliseconds: 50),
              onIndexChange: seen.add,
              children: _lines.sublist(0, lines),
            ),
            width: 200,
          );
        }

        testWidgets('goes on with what was left of it once a pause is let go', (
          WidgetTester tester,
        ) async {
          final List<int> seen = <int>[];

          await tester.pumpWidget(reel(seen));
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpWidget(reel(seen, paused: true));
          await tester.pump(const Duration(seconds: 2));

          expect(seen, isEmpty);

          await tester.pumpWidget(reel(seen));
          await tester.pump(const Duration(milliseconds: 599));

          // It used to wait a whole interval again.
          expect(seen, isEmpty);

          await tester.pump(const Duration(milliseconds: 1));

          expect(seen, <int>[1]);
        });

        testWidgets('goes on with what was left of the interval of a line it turned to', (
          WidgetTester tester,
        ) async {
          final List<int> seen = <int>[];

          await tester.pumpWidget(reel(seen));
          await tester.pump(const Duration(milliseconds: 1000));

          expect(seen, <int>[1]);

          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpWidget(reel(seen, paused: true));
          await tester.pump(const Duration(seconds: 2));
          await tester.pumpWidget(reel(seen));
          await tester.pump(const Duration(milliseconds: 599));

          expect(seen, <int>[1]);

          await tester.pump(const Duration(milliseconds: 1));

          expect(seen, <int>[1, 2]);
        });

        testWidgets('goes on with what was left of its delay as well before the first turn', (
          WidgetTester tester,
        ) async {
          final List<int> seen = <int>[];
          const Duration delay = Duration(milliseconds: 500);

          await tester.pumpWidget(reel(seen, delay: delay));
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pumpWidget(reel(seen, delay: delay, paused: true));
          await tester.pump(const Duration(seconds: 2));
          await tester.pumpWidget(reel(seen, delay: delay));
          await tester.pump(const Duration(milliseconds: 1199));

          // It used to wait the whole delay and the whole interval again.
          expect(seen, isEmpty);

          await tester.pump(const Duration(milliseconds: 1));

          expect(seen, <int>[1]);
        });

        for (final (String name, int interval, int after) in <(String, int, int)>[
          ('a shorter', 700, 300),
          ('a longer', 1500, 1100),
        ]) {
          testWidgets('measures $name interval from when the wait began', (
            WidgetTester tester,
          ) async {
            final List<int> seen = <int>[];

            await tester.pumpWidget(reel(seen));
            await tester.pump(const Duration(milliseconds: 400));
            await tester.pumpWidget(reel(seen, interval: Duration(milliseconds: interval)));
            await tester.pump(Duration(milliseconds: after - 1));

            // It used to wait the whole of the new interval from the change.
            expect(seen, isEmpty);

            await tester.pump(const Duration(milliseconds: 1));

            expect(seen, <int>[1]);
          });
        }

        testWidgets('turns at once when the wait is already past a new interval', (
          WidgetTester tester,
        ) async {
          final List<int> seen = <int>[];

          await tester.pumpWidget(reel(seen));
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpWidget(reel(seen, interval: const Duration(milliseconds: 300)));
          await tester.pump(Duration.zero);

          // It used to wait the whole of the new interval from the change.
          expect(seen, <int>[1]);
        });

        testWidgets('measures a new delay from when the wait began, before the first turn', (
          WidgetTester tester,
        ) async {
          final List<int> seen = <int>[];

          await tester.pumpWidget(reel(seen, delay: const Duration(milliseconds: 1000)));
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpWidget(reel(seen, delay: const Duration(milliseconds: 200)));
          await tester.pump(const Duration(milliseconds: 799));

          expect(seen, isEmpty);

          await tester.pump(const Duration(milliseconds: 1));

          expect(seen, <int>[1]);
        });

        testWidgets('measures a new interval given while it is paused once it is let go', (
          WidgetTester tester,
        ) async {
          final List<int> seen = <int>[];

          await tester.pumpWidget(reel(seen));
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpWidget(reel(seen, paused: true));
          await tester.pumpWidget(
            reel(seen, paused: true, interval: const Duration(milliseconds: 600)),
          );
          await tester.pump(const Duration(seconds: 2));
          await tester.pumpWidget(reel(seen, interval: const Duration(milliseconds: 600)));
          await tester.pump(const Duration(milliseconds: 199));

          expect(seen, isEmpty);

          await tester.pump(const Duration(milliseconds: 1));

          expect(seen, <int>[1]);
        });

        testWidgets('goes on with the wait of the last line once a line is added after it', (
          WidgetTester tester,
        ) async {
          final List<int> seen = <int>[];

          await tester.pumpWidget(reel(seen, loop: false, lines: 2));
          await tester.pump(const Duration(milliseconds: 1000));

          expect(seen, <int>[1]);

          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpWidget(reel(seen, loop: false));
          await tester.pump(const Duration(milliseconds: 599));

          // The line has been up for its interval once 600ms more have gone
          // by. It used to wait a whole interval again from the change.
          expect(seen, <int>[1]);

          await tester.pump(const Duration(milliseconds: 1));

          expect(seen, <int>[1, 2]);
        });

        testWidgets('goes on with the wait of a line it holds alone once a second is added', (
          WidgetTester tester,
        ) async {
          final List<int> seen = <int>[];

          await tester.pumpWidget(reel(seen, lines: 1));
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpWidget(reel(seen, lines: 2));
          await tester.pump(const Duration(milliseconds: 599));

          expect(seen, isEmpty);

          await tester.pump(const Duration(milliseconds: 1));

          expect(seen, <int>[1]);
        });

        testWidgets('goes on with the wait of the last line once loop is turned on', (
          WidgetTester tester,
        ) async {
          final List<int> seen = <int>[];

          await tester.pumpWidget(reel(seen, loop: false));
          await tester.pump(const Duration(milliseconds: 1000));
          await tester.pump(const Duration(milliseconds: 1000));

          expect(seen, <int>[1, 2]);

          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpWidget(reel(seen));
          await tester.pump(const Duration(milliseconds: 599));

          // It used to wait a whole interval again from the change.
          expect(seen, <int>[1, 2]);

          await tester.pump(const Duration(milliseconds: 1));

          expect(seen, <int>[1, 2, 0]);
        });

        for (final (String name, int lines, bool loop) in <(String, int, bool)>[
          ('a line is added', 2, true),
          ('loop is turned off', 3, false),
        ]) {
          testWidgets('goes on with the wait under way when $name', (WidgetTester tester) async {
            final List<int> seen = <int>[];

            await tester.pumpWidget(reel(seen, lines: lines));
            await tester.pump(const Duration(milliseconds: 400));
            await tester.pumpWidget(reel(seen, loop: loop));
            await tester.pump(const Duration(milliseconds: 599));

            // It used to wait a whole interval again from the change.
            expect(seen, isEmpty);

            await tester.pump(const Duration(milliseconds: 1));

            expect(seen, <int>[1]);
          });
        }

        testWidgets('holds the line that comes up a whole interval when the one up is removed', (
          WidgetTester tester,
        ) async {
          final List<int> seen = <int>[];

          await tester.pumpWidget(reel(seen));
          await tester.pump(const Duration(milliseconds: 1000));
          await tester.pump(const Duration(milliseconds: 1000));

          expect(seen, <int>[1, 2]);

          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpWidget(reel(seen, lines: 2));
          await tester.pump(const Duration(milliseconds: 999));

          // The line before it comes up, and is held for a whole interval, as
          // it was.
          expect(seen, <int>[1, 2]);
          expect(opacitiesOf(tester).last, 1);

          await tester.pump(const Duration(milliseconds: 1));

          expect(seen, <int>[1, 2, 0]);
        });

        testWidgets('waits a whole interval again once its trigger takes it back and lets it go', (
          WidgetTester tester,
        ) async {
          final List<int> seen = <int>[];
          const PlassAnimateTrigger manual = PlassAnimateTrigger.manual;

          await tester.pumpWidget(reel(seen, trigger: manual));
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpWidget(reel(seen, trigger: manual, play: false));
          await tester.pump(const Duration(seconds: 2));
          await tester.pumpWidget(reel(seen, trigger: manual));
          await tester.pump(const Duration(milliseconds: 999));

          // A new run, which waits from the beginning, as it did.
          expect(seen, isEmpty);

          await tester.pump(const Duration(milliseconds: 1));

          expect(seen, <int>[1]);
        });
      });
    });

    testWidgets('travels one line height unless a rise says otherwise', (
      WidgetTester tester,
    ) async {
      /// How far below where it rests the second line starts as it comes up.
      Future<double> travel({double? rise}) async {
        Widget build(int index) =>
            host(PlAnimateHeadline(index: index, rise: rise, children: _lines), width: 200);

        await tester.pumpWidget(build(0));
        await tester.pumpAndSettle();
        await tester.pumpWidget(build(1));

        final double start = tester.getRect(find.text('simpler')).top;

        await tester.pumpAndSettle();

        return start - tester.getRect(find.text('simpler')).top;
      }

      final double own = await travel();

      expect(own, moreOrLessEquals(tester.getSize(find.text('simpler')).height));

      // A new headline, so the swap starts from the first line again.
      await tester.pumpWidget(const SizedBox());

      expect(await travel(rise: 24), moreOrLessEquals(24));
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
