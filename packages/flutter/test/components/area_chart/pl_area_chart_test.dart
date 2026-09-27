import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/chart.dart';

import '../../support/canvas.dart';
import '../../support/host.dart';

final List<PlassChartSeries> series = <PlassChartSeries>[
  const PlassChartSeries(
    name: 'Direct',
    data: <PlassChartDatum>[PlassChartDatum(30), PlassChartDatum(40), PlassChartDatum(50)],
  ),
  const PlassChartSeries(
    name: 'Search',
    data: <PlassChartDatum>[PlassChartDatum(10), PlassChartDatum(10), PlassChartDatum(50)],
  ),
];

const List<PlassChartCategory> months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(500, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 500));
  await tester.pumpAndSettle();
}

/// Paints the plot as it stands now.
RecordingCanvas _paintArea(WidgetTester tester) {
  final canvas = RecordingCanvas();
  final Finder plot = find.byWidgetPredicate(
    (Widget widget) => widget is CustomPaint && widget.painter != null && widget.size.height > 40,
  );

  tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

  return canvas;
}

void main() {
  group('PlAreaChart', () {
    testWidgets('draws a plot and names itself', (WidgetTester tester) async {
      await _pump(tester, PlAreaChart(series: series, categories: months));

      expect(find.bySemanticsLabel('Chart'), findsOneWidget);
    });

    testWidgets('names every series in the legend', (WidgetTester tester) async {
      await _pump(tester, PlAreaChart(series: series, categories: months));

      expect(find.text('Direct'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('takes every stacking it names', (WidgetTester tester) async {
      for (final PlAreaStacking stacking in PlAreaStacking.values) {
        await _pump(tester, PlAreaChart(series: series, categories: months, stacking: stacking));

        expect(find.byType(PlAreaChart), findsOneWidget);
      }
    });

    testWidgets('normalises each category to a hundred when it is full', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PlAreaChart(series: series, categories: months, stacking: PlAreaStacking.full),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      // The summary keeps the number the caller passed rather than the share —
      // a chart that can only tell you percentages has thrown the data away.
      expect(node.value, contains('Direct'));
      expect(node.value, contains('Search'));
    });

    testWidgets('writes the caller number in its format when it is full', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PlAreaChart(
          series: const <PlassChartSeries>[
            PlassChartSeries(name: 'New', data: <PlassChartDatum>[PlassChartDatum(4000)]),
            PlassChartSeries(name: 'Renewed', data: <PlassChartDatum>[PlassChartDatum(16000)]),
          ],
          stacking: PlAreaStacking.full,
          format: (double value) => '\$${value.toInt()}',
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Chart')).value,
        r'New: $4000. Renewed: $16000',
      );
    });

    testWidgets('keeps a gap a gap', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlAreaChart(
          series: <PlassChartSeries>[
            PlassChartSeries(
              name: 'Direct',
              data: <PlassChartDatum>[
                PlassChartDatum(30),
                PlassChartDatum.gap(),
                PlassChartDatum(50),
              ],
            ),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('50'));
    });

    testWidgets('says nothing is there when every value is a gap', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlAreaChart(
          series: <PlassChartSeries>[
            PlassChartSeries(data: <PlassChartDatum>[PlassChartDatum.gap()]),
          ],
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('fades a series as one layer, its band and its line whole inside it', (
      WidgetTester tester,
    ) async {
      for (final PlAreaStacking stacking in <PlAreaStacking>[
        PlAreaStacking.none,
        PlAreaStacking.total,
      ]) {
        await _pump(tester, PlAreaChart(series: series, categories: months, stacking: stacking));

        expect(_paintArea(tester).layers, isEmpty, reason: stacking.name);

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(find.bySemanticsLabel('Search')));
        await tester.pumpAndSettle();

        // Direct is drawn into a layer faded to 0.28, and Search outside any.
        // Inside it, a band that is not stacked is its wash under a line of the
        // full colour, and a stacked band is its flat tint at 0.7, each as it
        // is drawn at rest.
        final RecordingCanvas canvas = _paintArea(tester);

        expect(canvas.layers, <Matcher>[closeTo(0.28, 1e-6)], reason: stacking.name);

        if (stacking == PlAreaStacking.none) {
          expect(canvas.paints.map((Paint paint) => paint.color.a), <double>[1, 1, 1, 1]);
          expect(canvas.opacities, <Matcher>[
            closeTo(0.28, 1e-6),
            closeTo(0.28, 1e-6),
            equals(1),
            equals(1),
          ]);
        } else {
          expect(canvas.paints.map((Paint paint) => paint.color.a), <Matcher>[
            closeTo(0.7, 1e-6),
            closeTo(0.7, 1e-6),
          ]);
          expect(canvas.opacities, <Matcher>[closeTo(0.7 * 0.28, 1e-6), closeTo(0.7, 1e-6)]);
        }

        await mouse.removePointer();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('takes the height it was given', (WidgetTester tester) async {
      await _pump(
        tester,
        PlAreaChart(series: <PlassChartSeries>[series.first], categories: months, height: 160),
      );

      expect(tester.getSize(find.byType(PlAreaChart)).height, closeTo(160, 0.5));
    });

    group('markers on stacked bands', () {
      testWidgets('draws each band\'s markers on its top, at the running total', (
        WidgetTester tester,
      ) async {
        // Where a band that is not stacked draws the markers of those totals:
        // Direct's own values, and Search's on top of them.
        await _pump(
          tester,
          PlAreaChart(
            series: _series(<double>[30, 40, 50], <double>[40, 50, 100]),
            categories: months,
            markers: PlChartMarkers.all,
          ),
        );

        final List<Offset> totals = _paintMarks(tester).centres;

        for (final PlChartMarkers markers in <PlChartMarkers>[
          PlChartMarkers.all,
          PlChartMarkers.auto,
        ]) {
          await _pump(
            tester,
            PlAreaChart(
              series: series,
              categories: months,
              stacking: PlAreaStacking.total,
              markers: markers,
            ),
          );

          final _MarkCanvas canvas = _paintMarks(tester);
          final double radius = markerRadii[PlassSize.md]!;

          // A ring and a dot for each of the six points, at the size a marker
          // takes on a line.
          _expectAt(canvas.centres, totals, markers.name);
          expect(canvas.radii, <double>[
            for (int i = 0; i < 6; i += 1) ...<double>[radius + 1, radius - 1],
          ], reason: markers.name);
        }

        // And `auto` stops at fourteen points, as it does on a line.
        await _pump(
          tester,
          PlAreaChart(
            series: _series(
              <double>[for (int i = 0; i < 15; i += 1) 10],
              <double>[for (int i = 0; i < 15; i += 1) 20],
            ),
            stacking: PlAreaStacking.total,
            markers: PlChartMarkers.auto,
          ),
        );

        expect(_paintMarks(tester).centres, isEmpty);
      });

      testWidgets('draws them at the running share when the bands are full', (
        WidgetTester tester,
      ) async {
        // Direct's share of each month, and Search's on top of it, which is all.
        await _pump(
          tester,
          PlAreaChart(
            series: _series(<double>[75, 80, 50], <double>[100, 100, 100]),
            categories: months,
            markers: PlChartMarkers.all,
            yAxis: PlChartAxis(min: 0, max: 100, format: (double value) => '${value.toInt()}%'),
          ),
        );

        final List<Offset> shares = _paintMarks(tester).centres;

        await _pump(
          tester,
          PlAreaChart(
            series: series,
            categories: months,
            stacking: PlAreaStacking.full,
            markers: PlChartMarkers.all,
          ),
        );

        _expectAt(_paintMarks(tester).centres, shares, 'full');
      });

      testWidgets('draws only the markers of the column being read when they are off', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlAreaChart(series: series, categories: months, stacking: PlAreaStacking.total),
        );

        expect(_paintMarks(tester).centres, isEmpty);

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        // Onto January, the first column.
        await mouse.moveTo(tester.getTopLeft(_plot()) + const Offset(2, 4));
        await tester.pump();

        // Direct's January marker and Search's above it, each put there at the
        // size a marker under the crosshair is, a pixel larger than at rest.
        final double radius = markerRadii[PlassSize.md]!;
        final _MarkCanvas canvas = _paintMarks(tester);

        expect(canvas.radii, <double>[radius + 2, radius, radius + 2, radius]);
        expect(canvas.centres[2].dx, canvas.centres[0].dx);
        expect(canvas.centres[2].dy, lessThan(canvas.centres[0].dy));

        await tester.pumpAndSettle();

        expect(_paintMarks(tester).radii, <double>[radius + 2, radius, radius + 2, radius]);
      });

      testWidgets('draws a band\'s markers before the band above it, which lies over them', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlAreaChart(
            series: series,
            categories: months,
            stacking: PlAreaStacking.total,
            markers: PlChartMarkers.all,
          ),
        );

        // As the React series are drawn, each in a group of its own: Direct's
        // band and its three markers, then Search's band and its three.
        expect(_paintMarks(tester).calls, <String>[
          'path',
          for (int i = 0; i < 6; i += 1) 'disc',
          'path',
          for (int i = 0; i < 6; i += 1) 'disc',
        ]);
      });
    });
  });
}

/// Two series named as [series] is, holding [direct] and [search].
List<PlassChartSeries> _series(List<double> direct, List<double> search) {
  return <PlassChartSeries>[
    PlassChartSeries(
      name: 'Direct',
      data: <PlassChartDatum>[for (final double value in direct) PlassChartDatum(value)],
    ),
    PlassChartSeries(
      name: 'Search',
      data: <PlassChartDatum>[for (final double value in search) PlassChartDatum(value)],
    ),
  ];
}

/// The plot's painter, which is the tallest `CustomPaint` with one.
Finder _plot() {
  return find
      .byWidgetPredicate(
        (Widget widget) =>
            widget is CustomPaint && widget.painter != null && widget.size.height > 40,
      )
      .first;
}

/// The plot as it is painted now, as the paths and discs drawn.
_MarkCanvas _paintMarks(WidgetTester tester) {
  final _MarkCanvas canvas = _MarkCanvas();

  tester.widget<CustomPaint>(_plot()).painter!.paint(canvas, tester.getSize(_plot()));

  return canvas;
}

/// Checks that the discs in [actual] stand where those in [expected] do.
void _expectAt(List<Offset> actual, List<Offset> expected, String reason) {
  expect(actual, hasLength(expected.length), reason: reason);

  for (int i = 0; i < expected.length; i += 1) {
    expect(actual[i].dx, closeTo(expected[i].dx, 1e-6), reason: '$reason, disc $i');
    expect(actual[i].dy, closeTo(expected[i].dy, 1e-6), reason: '$reason, disc $i');
  }
}

/// A canvas that writes down every path and disc drawn on it, in order, with
/// each disc's centre and radius, and drops everything else.
class _MarkCanvas implements Canvas {
  final List<String> calls = <String>[];
  final List<Offset> centres = <Offset>[];
  final List<double> radii = <double>[];

  @override
  void drawPath(Path path, Paint paint) => calls.add('path');

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    calls.add('disc');
    centres.add(c);
    radii.add(radius);
  }

  @override
  void noSuchMethod(Invocation invocation) {}
}
