// The rules a cartesian chart draws that are not data: the grid, the rule at
// zero and the category axis' own line, as the React chart's `ChartAxes` draws
// them.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/canvas.dart';
import '../support/host.dart';

/// Every straight line the chart's own painters draw, as they stand now.
List<(Offset, Offset, Paint)> _lines(WidgetTester tester, Finder chart) {
  final RecordingCanvas canvas = RecordingCanvas();

  for (final Element element
      in find.descendant(of: chart, matching: find.byType(CustomPaint)).evaluate()) {
    final CustomPaint paint = element.widget as CustomPaint;
    final RenderBox box = element.renderObject! as RenderBox;

    paint.painter?.paint(canvas, box.size);
  }

  return canvas.lines;
}

/// Whether [line] is drawn in [ink], compared as the 32 bits a paint holds.
bool _ink((Offset, Offset, Paint) line, Color ink) => line.$3.color.toARGB32() == ink.toARGB32();

Future<void> _pump(WidgetTester tester, Widget chart) async {
  tester.view.physicalSize = const Size(600, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(chart, width: 500));
  await tester.pumpAndSettle();
}

void main() {
  final PlassTokens tokens = PlassTokens.light();

  testWidgets('draws the rule at zero in the baseline ink and the category axis on it', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const PlBarChart(
        categories: <PlassChartCategory>[
          PlassChartCategory.text('Q1'),
          PlassChartCategory.text('Q2'),
        ],
        series: <PlassChartSeries>[
          PlassChartSeries(
            name: 'Net',
            data: <PlassChartDatum>[PlassChartDatum(-20), PlassChartDatum(40)],
          ),
        ],
      ),
    );

    final List<(Offset, Offset, Paint)> lines = _lines(tester, find.byType(PlBarChart));
    final Iterable<(Offset, Offset, Paint)> baseline = lines.where(
      ((Offset, Offset, Paint) line) => _ink(line, tokens.chartBaseline),
    );
    final Iterable<(Offset, Offset, Paint)> axis = lines.where(
      ((Offset, Offset, Paint) line) => _ink(line, tokens.chartAxis),
    );

    // The gridline at zero in the baseline ink, where the bars also draw
    // theirs, and the category axis' rule on that line rather than at the
    // foot of the plot.
    expect(baseline, isNotEmpty);
    expect(axis, hasLength(1));
    expect(baseline.map(((Offset, Offset, Paint) line) => line.$1.dy).toSet(), <double>{
      axis.single.$1.dy,
    });
    expect(lines.where(((Offset, Offset, Paint) line) => _ink(line, tokens.chartGrid)), isNotEmpty);
  });

  testWidgets('draws the category axis\' own gridlines on a scatter and not on a line chart', (
    WidgetTester tester,
  ) async {
    bool vertical((Offset, Offset, Paint) line) =>
        line.$1.dx == line.$2.dx && _ink(line, tokens.chartGrid);

    await _pump(
      tester,
      const PlScatterChart(
        series: <PlassChartSeries>[
          PlassChartSeries(
            name: 'Spend',
            data: <PlassChartDatum>[
              PlassChartDatum.point(PlassChartPoint(x: PlassChartCategory.number(10), y: 3)),
              PlassChartDatum.point(PlassChartPoint(x: PlassChartCategory.number(40), y: 8)),
            ],
          ),
        ],
      ),
    );

    // A second value axis casts them, as the React scatter's `categoryGrid`.
    expect(_lines(tester, find.byType(PlScatterChart)).where(vertical), isNotEmpty);

    await _pump(
      tester,
      const PlLineChart(
        categories: <PlassChartCategory>[
          PlassChartCategory.text('Mon'),
          PlassChartCategory.text('Tue'),
        ],
        series: <PlassChartSeries>[
          PlassChartSeries(
            name: 'Visits',
            data: <PlassChartDatum>[PlassChartDatum(3), PlassChartDatum(5)],
          ),
        ],
      ),
    );

    // A band of categories does not, unless asked.
    expect(_lines(tester, find.byType(PlLineChart)).where(vertical), isEmpty);
  });
}
