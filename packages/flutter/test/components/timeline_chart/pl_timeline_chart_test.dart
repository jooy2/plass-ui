import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

PlassChartCategory _at(int day) => PlassChartCategory.date(DateTime(2026, 1, day));

List<PlassTimelineSeries> _plan() => <PlassTimelineSeries>[
  PlassTimelineSeries(
    name: 'Design',
    data: <PlassTimelinePoint>[
      PlassTimelinePoint(start: _at(1), end: _at(9), label: 'Wireframes'),
      PlassTimelinePoint(start: _at(11), end: _at(18), label: 'Visuals'),
    ],
  ),
  PlassTimelineSeries(
    name: 'Build',
    data: <PlassTimelinePoint>[
      PlassTimelinePoint(start: _at(8), end: _at(26), label: 'Implementation'),
    ],
  ),
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(600, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 600));
  await tester.pumpAndSettle();
}

void main() {
  group('PlTimelineChart', () {
    testWidgets('draws a plot and names itself', (WidgetTester tester) async {
      await _pump(tester, PlTimelineChart(series: _plan(), semanticLabel: 'Plan'));

      expect(find.bySemanticsLabel('Plan'), findsOneWidget);
    });

    testWidgets('reads out every span with the dates it runs between', (WidgetTester tester) async {
      await _pump(tester, PlTimelineChart(series: _plan(), semanticLabel: 'Plan'));

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Plan'));

      expect(node.value, contains('Design: Wireframes Jan 1'));
      expect(node.value, contains('Build: Implementation Jan 8'));
    });

    testWidgets('reads out the day with each time when the hours run over more than one day', (
      WidgetTester tester,
    ) async {
      PlassTimelinePoint shift(int day) => PlassTimelinePoint(
        start: PlassChartCategory.date(DateTime(2026, 1, day, 9)),
        end: PlassChartCategory.date(DateTime(2026, 1, day, 17)),
      );

      await _pump(
        tester,
        PlTimelineChart(
          series: <PlassTimelineSeries>[
            PlassTimelineSeries(name: 'Desk', data: <PlassTimelinePoint>[shift(5), shift(6)]),
          ],
          semanticLabel: 'Shifts',
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Shifts')).value,
        'Desk: Jan 5, 2026, 09:00 – Jan 5, 2026, 17:00; Jan 6, 2026, 09:00 – Jan 6, 2026, 17:00',
      );

      await _pump(
        tester,
        PlTimelineChart(
          series: <PlassTimelineSeries>[
            PlassTimelineSeries(name: 'Desk', data: <PlassTimelinePoint>[shift(5)]),
          ],
          semanticLabel: 'Shifts',
        ),
      );

      expect(tester.getSemantics(find.bySemanticsLabel('Shifts')).value, 'Desk: 09:00 – 17:00');
    });

    testWidgets('draws a span the caller wrote backwards either way round', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PlTimelineChart(
          semanticLabel: 'Plan',
          series: <PlassTimelineSeries>[
            PlassTimelineSeries(
              name: 'Design',
              data: <PlassTimelinePoint>[PlassTimelinePoint(start: _at(20), end: _at(4))],
            ),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Plan'));

      // Read out low end first, whichever way the caller wrote it.
      expect(node.value, contains('Jan 4'));
      expect(node.value.indexOf('Jan 4'), lessThan(node.value.indexOf('Jan 20')));
    });

    testWidgets('leaves a span with no times out of the reading', (WidgetTester tester) async {
      await _pump(
        tester,
        PlTimelineChart(
          semanticLabel: 'Plan',
          series: <PlassTimelineSeries>[
            PlassTimelineSeries(
              name: 'Design',
              data: <PlassTimelinePoint>[
                // Text is not an instant, so this span has nowhere to be.
                PlassTimelinePoint(start: const PlassChartCategory.text('soon'), end: _at(9)),
                PlassTimelinePoint(start: _at(2), end: _at(6)),
              ],
            ),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Plan'));

      expect(node.value, 'Design: Jan 2, 2026 – Jan 6, 2026');
    });

    testWidgets('says nothing is there when no row has a span', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlTimelineChart(
          series: <PlassTimelineSeries>[
            PlassTimelineSeries(name: 'Design', data: <PlassTimelinePoint>[]),
          ],
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('names the rows down the side rather than in a legend', (
      WidgetTester tester,
    ) async {
      await _pump(tester, PlTimelineChart(series: _plan(), semanticLabel: 'Plan'));

      // A Gantt's rows *are* its axis, so there is nothing to press.
      expect(find.bySemanticsLabel('Design'), findsNothing);
      expect(find.byType(PlTimelineChart), findsOneWidget);
    });

    testWidgets('takes its own ends over the data', (WidgetTester tester) async {
      await _pump(
        tester,
        PlTimelineChart(
          series: _plan(),
          min: _at(1),
          max: PlassChartCategory.date(DateTime(2026, 3, 1)),
          semanticLabel: 'Plan',
        ),
      );

      expect(find.byType(PlTimelineChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('leaves a span outside min and max out of the readout and the reading', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PlTimelineChart(
          series: <PlassTimelineSeries>[
            PlassTimelineSeries(
              name: 'Design',
              data: <PlassTimelinePoint>[
                // A day that ends a day and a half before `min`, which puts it
                // under the row's name rather than off the side of the chart.
                PlassTimelinePoint(
                  start: PlassChartCategory.date(DateTime(2026, 1, 8, 12)),
                  end: PlassChartCategory.date(DateTime(2026, 1, 9, 12)),
                  label: 'Before',
                ),
                PlassTimelinePoint(start: _at(12), end: _at(20), label: 'Inside'),
              ],
            ),
          ],
          min: _at(10),
          max: _at(30),
          height: 220,
          semanticLabel: 'Plan',
        ),
      );

      final Rect box = tester.getRect(find.byType(CustomPaint).first);
      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      final seen = <String>{};

      await mouse.addPointer(location: box.topLeft);

      // Along the whole row, its name included.
      for (double x = box.left; x <= box.right; x += 4) {
        await mouse.moveTo(Offset(x, box.top + box.height * 0.45));
        await tester.pump();

        for (final String name in <String>['Before', 'Inside']) {
          if (find.text(name).evaluate().isNotEmpty) {
            seen.add(name);
          }
        }
      }

      expect(seen, <String>{'Inside'});
      expect(tester.getSemantics(find.bySemanticsLabel('Plan')).value, isNot(contains('Before')));
    });

    testWidgets('takes a bar thickness cap and square ends', (WidgetTester tester) async {
      await _pump(
        tester,
        PlTimelineChart(series: _plan(), barSize: 8, rounded: false, semanticLabel: 'Plan'),
      );

      expect(find.byType(PlTimelineChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows a readout naming the span under the press', (WidgetTester tester) async {
      await _pump(tester, PlTimelineChart(series: _plan(), height: 220, semanticLabel: 'Plan'));

      final Rect box = tester.getRect(find.byType(CustomPaint).first);

      // Anywhere along the top row's first bar.
      for (double t = 0.35; t <= 0.9; t += 0.1) {
        await tester.tapAt(Offset(box.left + box.width * t, box.top + box.height * 0.25));
        await tester.pumpAndSettle();

        if (find.text('Wireframes').evaluate().isNotEmpty) {
          return;
        }
      }

      fail('no span was ever under the press');
    });

    testWidgets('shows the readout for a span on a row after the first', (
      WidgetTester tester,
    ) async {
      await _pump(tester, PlTimelineChart(series: _plan(), height: 220, semanticLabel: 'Plan'));

      final Rect box = tester.getRect(find.byType(CustomPaint).first);
      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: box.topLeft);

      // Along the second row, whose one span runs most of the way across.
      for (double x = box.left; x <= box.right; x += 8) {
        await mouse.moveTo(Offset(x, box.top + box.height * 0.6));
        await tester.pump();

        expect(tester.takeException(), isNull);

        if (find.text('Implementation').evaluate().isNotEmpty) {
          return;
        }
      }

      fail('no span on the second row was ever under the pointer');
    });

    testWidgets('walks the spans with the arrow keys in the order they were written', (
      WidgetTester tester,
    ) async {
      final FocusNode before = FocusNode();

      addTearDown(before.dispose);
      await _pump(
        tester,
        afterFocusStop(before, PlTimelineChart(series: _plan(), semanticLabel: 'Plan')),
      );

      before.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      String said() => find.semantics.byFlag(SemanticsFlag.isLiveRegion).evaluate().single.label;

      // The rows run down the side, so the keys that walk them do too, and a
      // span that names itself is read by its name and the two days it spans.
      for (final (LogicalKeyboardKey key, String reading) in <(LogicalKeyboardKey, String)>[
        (LogicalKeyboardKey.arrowDown, 'Wireframes, Jan 1, 2026 – Jan 9, 2026'),
        (LogicalKeyboardKey.arrowDown, 'Visuals, Jan 11, 2026 – Jan 18, 2026'),
        (LogicalKeyboardKey.arrowDown, 'Implementation, Jan 8, 2026 – Jan 26, 2026'),
        (LogicalKeyboardKey.arrowUp, 'Visuals, Jan 11, 2026 – Jan 18, 2026'),
      ]) {
        await tester.sendKeyEvent(key);
        await tester.pump();

        expect(said(), reading, reason: '$key');
      }
    });
  });
}
