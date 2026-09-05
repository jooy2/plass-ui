import 'package:flutter/semantics.dart';
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
  });
}
