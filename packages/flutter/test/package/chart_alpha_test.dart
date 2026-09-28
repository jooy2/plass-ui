// A colour given to a series or a point with an alpha of its own keeps it, and
// what the chart does to the colour, a fade or a shade, goes on top of it, as
// the React chart's `opacity`, `fill-opacity` and stops do.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/canvas.dart';
import '../support/host.dart';

/// A colour at half its alpha.
const Color _half = Color(0x80336699);

const List<PlassChartCategory> _months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
];

const List<PlassChartSeries> _series = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Direct',
    color: _half,
    data: <PlassChartDatum>[PlassChartDatum(4), PlassChartDatum(8), PlassChartDatum(6)],
  ),
  PlassChartSeries(
    name: 'Search',
    data: <PlassChartDatum>[PlassChartDatum(3), PlassChartDatum(5), PlassChartDatum(7)],
  ),
];

/// A point at [y] in [_half].
PlassChartDatum _point(double y, {PlassChartCategory? x}) =>
    PlassChartDatum.point(PlassChartPoint(x: x, y: y, color: _half));

/// What the chart's own painters draw, as they stand now.
RecordingCanvas _paint(WidgetTester tester, Finder chart) {
  final RecordingCanvas canvas = RecordingCanvas();

  for (final Element element
      in find.descendant(of: chart, matching: find.byType(CustomPaint)).evaluate()) {
    final CustomPaint paint = element.widget as CustomPaint;
    final RenderBox box = element.renderObject! as RenderBox;

    paint.painter?.paint(canvas, box.size);
  }

  return canvas;
}

/// The alpha of every fill, stroke, dot and cell drawn in [_half]'s hue.
List<double> _alphas(RecordingCanvas canvas) {
  bool hue(Paint paint) => (paint.color.toARGB32() & 0xFFFFFF) == (_half.toARGB32() & 0xFFFFFF);

  return <Paint>[
    ...canvas.paints,
    for (final (Offset, double, Paint) circle in canvas.circles) circle.$3,
    ...canvas.rrects,
  ].where(hue).map((Paint paint) => paint.color.a).toList();
}

Future<void> _pump(WidgetTester tester, Widget chart) async {
  tester.view.physicalSize = const Size(600, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(chart, width: 500));
  await tester.pumpAndSettle();
}

void main() {
  final Map<String, Widget> charts = <String, Widget>{
    'PlLineChart': const PlLineChart(
      series: _series,
      categories: _months,
      markers: PlChartMarkers.all,
    ),
    'PlAreaChart, stacked': const PlAreaChart(
      series: _series,
      categories: _months,
      stacking: PlAreaStacking.total,
    ),
    'PlBarChart': const PlBarChart(series: _series, categories: _months),
    'PlScatterChart': PlScatterChart(
      series: <PlassChartSeries>[
        PlassChartSeries(
          name: 'Spend',
          data: <PlassChartDatum>[
            _point(22, x: const PlassChartCategory.number(10)),
            _point(31, x: const PlassChartCategory.number(20)),
          ],
        ),
      ],
    ),
    'PlPieChart': PlPieChart(
      data: <PlassChartDatum>[_point(40), const PlassChartDatum(60)],
      categories: _months.sublist(0, 2),
    ),
    'PlHeatmapChart': PlHeatmapChart(
      series: <PlassChartSeries>[
        PlassChartSeries(name: 'Mon', data: <PlassChartDatum>[_point(2), const PlassChartDatum(9)]),
      ],
      categories: _months.sublist(0, 2),
    ),
  };

  for (final MapEntry<String, Widget> chart in charts.entries) {
    testWidgets('${chart.key} keeps the alpha of a colour it is given', (
      WidgetTester tester,
    ) async {
      await _pump(tester, chart.value);

      final List<double> alphas = _alphas(_paint(tester, find.byType(chart.value.runtimeType)));

      // Drawn in the colour, and never above the half it was given: a shade
      // or a tint of it lands under it, not at a whole alpha of its own.
      expect(alphas, isNotEmpty);
      expect(alphas, everyElement(lessThanOrEqualTo(_half.a + 1e-6)));
    });
  }
}
