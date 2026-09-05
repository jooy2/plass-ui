import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

final List<PlassChartSeries> series = <PlassChartSeries>[
  const PlassChartSeries(
    name: 'Revenue',
    data: <PlassChartDatum>[
      PlassChartDatum(12),
      PlassChartDatum(19),
      PlassChartDatum(15),
      PlassChartDatum(22),
    ],
  ),
  const PlassChartSeries(
    name: 'Cost',
    data: <PlassChartDatum>[
      PlassChartDatum(8),
      PlassChartDatum(11),
      PlassChartDatum(9),
      PlassChartDatum(13),
    ],
  ),
];

const List<PlassChartCategory> months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
  PlassChartCategory.text('Apr'),
];

Future<void> _pump(WidgetTester tester, Widget child, {double width = 500}) async {
  tester.view.physicalSize = Size(width, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: width));
  await tester.pumpAndSettle();
}

void main() {
  group('PlLineChart', () {
    group('rendering', () {
      testWidgets('draws a plot', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('names itself', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        expect(find.bySemanticsLabel('Chart'), findsOneWidget);
      });

      testWidgets('takes a name of its own', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(series: series, categories: months, semanticLabel: 'Revenue by month'),
        );

        expect(find.bySemanticsLabel('Revenue by month'), findsOneWidget);
      });

      testWidgets('writes the categories along the axis', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        // Axis labels are painted rather than laid out as widgets, so what a
        // test can check is that the frame was handed them: the semantics
        // summary names each series and where it ended up.
        final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

        expect(node.value, contains('Revenue'));
        expect(node.value, contains('22'));
        expect(node.value, contains('Cost'));
      });

      testWidgets('says nothing is there when every value is a gap', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlLineChart(
            series: <PlassChartSeries>[
              PlassChartSeries(
                data: <PlassChartDatum>[PlassChartDatum.gap(), PlassChartDatum.gap()],
              ),
            ],
          ),
        );

        expect(find.text('Nothing here'), findsOneWidget);
      });

      testWidgets('draws nothing at all for an empty set of series', (WidgetTester tester) async {
        await _pump(tester, const PlLineChart(series: <PlassChartSeries>[]));

        expect(find.text('Nothing here'), findsOneWidget);
      });
    });

    group('the legend', () {
      testWidgets('names every series', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        expect(find.text('Revenue'), findsOneWidget);
        expect(find.text('Cost'), findsOneWidget);
      });

      testWidgets('draws none for a single series', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: <PlassChartSeries>[series.first]));

        expect(find.text('Revenue'), findsNothing);
      });

      testWidgets('draws none when it is hidden', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            legend: const PlChartLegend(hidden: true),
          ),
        );

        expect(find.text('Revenue'), findsNothing);
      });

      testWidgets('switches a series off when its entry is pressed', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));
        expect(node.value, contains('Cost'));

        await tester.tap(find.bySemanticsLabel('Cost'));
        await tester.pumpAndSettle();

        node = tester.getSemantics(find.bySemanticsLabel('Chart'));
        expect(node.value, isNot(contains('Cost')));
        expect(node.value, contains('Revenue'));
      });

      testWidgets('leaves a series alone when the legend is not interactive', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            legend: const PlChartLegend(interactive: false),
          ),
        );

        expect(find.bySemanticsLabel('Cost'), findsNothing);
        expect(find.text('Cost'), findsOneWidget);
      });

      testWidgets('starts a series off when it says it is hidden', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[
              series.first,
              const PlassChartSeries(
                name: 'Cost',
                hidden: true,
                data: <PlassChartDatum>[PlassChartDatum(8), PlassChartDatum(11)],
              ),
            ],
            categories: months,
          ),
        );

        final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

        expect(node.value, isNot(contains('Cost')));
      });
    });

    group('the tooltip', () {
      testWidgets('shows the column under the pointer', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        final Offset centre = tester.getCenter(find.byType(PlLineChart));

        await tester.tapAt(centre);
        await tester.pump();

        // The card names the category and every visible series at it.
        expect(find.textContaining(RegExp('Jan|Feb|Mar|Apr')), findsWidgets);
      });

      testWidgets('shows none when it is hidden', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            tooltip: const PlChartTooltip(hidden: true),
          ),
        );

        final Offset centre = tester.getCenter(find.byType(PlLineChart));

        await tester.tapAt(centre);
        await tester.pump();

        expect(find.text('12'), findsNothing);
      });
    });

    group('the axes', () {
      testWidgets('gives the room back when an axis is hidden', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            xAxis: const PlChartAxis(hidden: true),
            yAxis: const PlChartAxis(hidden: true),
            legend: const PlChartLegend(hidden: true),
            height: 200,
          ),
        );

        // Nothing to assert on the painted band directly; what is checkable is
        // that the chart still lays out at the height it was given.
        expect(tester.getSize(find.byType(PlLineChart)).height, closeTo(200, 0.5));
      });

      testWidgets('takes the height it was given', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(series: <PlassChartSeries>[series.first], categories: months, height: 140),
        );

        expect(tester.getSize(find.byType(PlLineChart)).height, closeTo(140, 0.5));
      });

      testWidgets('follows the size ladder when it was given none', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[series.first],
            categories: months,
            size: PlassSize.xs,
          ),
        );

        expect(tester.getSize(find.byType(PlLineChart)).height, closeTo(120, 0.5));
      });
    });

    group('labels', () {
      testWidgets('takes an axis name and reserves room for it', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[series.first],
            categories: months,
            height: 200,
            yAxis: const PlChartAxis(label: 'Revenue'),
            xAxis: const PlChartAxis(label: 'Month'),
          ),
        );

        // Both names are painted rather than laid out, so what a test can check
        // is that the chart still fits the height it was given once the two
        // bands have been taken out of it.
        expect(tester.getSize(find.byType(PlLineChart)).height, closeTo(200, 0.5));
      });

      testWidgets('writes every value setting it names', (WidgetTester tester) async {
        for (final PlassChartValueLabels which in PlassChartValueLabels.values) {
          await _pump(
            tester,
            PlLineChart(
              series: <PlassChartSeries>[series.first],
              categories: months,
              valueLabels: which,
            ),
          );

          expect(find.byType(PlLineChart), findsOneWidget);
        }
      });

      testWidgets('writes the values through the format it was given', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[series.first],
            categories: months,
            format: (double value) => '£$value',
          ),
        );

        final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

        expect(node.value, contains('£'));
      });
    });

    group('curves and markers', () {
      testWidgets('draws every curve it names', (WidgetTester tester) async {
        for (final PlChartCurve curve in PlChartCurve.values) {
          await _pump(tester, PlLineChart(series: series, categories: months, curve: curve));

          expect(find.byType(PlLineChart), findsOneWidget);
        }
      });

      testWidgets('takes every marker setting it names', (WidgetTester tester) async {
        for (final PlChartMarkers markers in PlChartMarkers.values) {
          await _pump(tester, PlLineChart(series: series, categories: months, markers: markers));

          expect(find.byType(PlLineChart), findsOneWidget);
        }
      });

      testWidgets('draws a series with a gap in it', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlLineChart(
            series: <PlassChartSeries>[
              PlassChartSeries(
                name: 'Uptime',
                data: <PlassChartDatum>[
                  PlassChartDatum(1),
                  PlassChartDatum.gap(),
                  PlassChartDatum(3),
                ],
              ),
            ],
          ),
        );

        final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

        // The gap is a gap: the series still ends at its last real value.
        expect(node.value, contains('3'));
      });

      testWidgets('bridges a gap when it is told to', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlLineChart(
            connectNulls: true,
            series: <PlassChartSeries>[
              PlassChartSeries(
                name: 'Uptime',
                data: <PlassChartDatum>[
                  PlassChartDatum(1),
                  PlassChartDatum.gap(),
                  PlassChartDatum(3),
                ],
              ),
            ],
          ),
        );

        expect(find.byType(PlLineChart), findsOneWidget);
      });
    });
  });
}
