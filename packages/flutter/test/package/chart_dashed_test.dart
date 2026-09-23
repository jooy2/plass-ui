// That `PlassChartSeries.dashed` draws a dashed line.
//
// The field was documented and listed in the props table, and the painter never
// read it — a caller marking a forecast got a solid line and nothing to say it
// was a forecast. A test of a *contract* rather than of a widget, which is why
// it is here: line and area are two widgets over one painter, and `dashed` has
// to mean the same thing in both — on the plot, and in the legend's key for it.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/canvas.dart';
import '../support/host.dart';

const List<PlassChartDatum> data = <PlassChartDatum>[
  PlassChartDatum(12),
  PlassChartDatum(19),
  PlassChartDatum(15),
  PlassChartDatum(22),
];

Future<void> pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(500, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 500));
  await tester.pumpAndSettle();
}

/// Every path the plot drew, with the paint it was drawn with.
RecordingCanvas draw(WidgetTester tester) {
  final canvas = RecordingCanvas();
  final Finder plot = find.byWidgetPredicate(
    (Widget widget) => widget is CustomPaint && widget.painter != null && widget.size.height > 40,
  );

  tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

  return canvas;
}

/// How many contours the stroked paths are made of — one each for a solid line,
/// many for a dashed one.
List<int> strokedContours(RecordingCanvas canvas) {
  final List<int> counts = <int>[];

  for (int i = 0; i < canvas.paths.length; i += 1) {
    if (canvas.paints[i].style == PaintingStyle.stroke) {
      counts.add(canvas.contours[i]);
    }
  }

  return counts;
}

void main() {
  testWidgets('a line chart draws a solid series as one stroke', (WidgetTester tester) async {
    await pump(
      tester,
      const PlLineChart(
        series: <PlassChartSeries>[PlassChartSeries(name: 'Revenue', data: data)],
      ),
    );

    expect(strokedContours(draw(tester)), <int>[1]);
  });

  testWidgets('a `dashed` series is cut into dashes', (WidgetTester tester) async {
    await pump(
      tester,
      const PlLineChart(
        series: <PlassChartSeries>[PlassChartSeries(name: 'Forecast', data: data, dashed: true)],
      ),
    );

    final List<int> counts = strokedContours(draw(tester));

    expect(counts, hasLength(1));
    // The number depends on how long the line is, which depends on the plot —
    // what matters is that it is many rather than one.
    expect(counts.single, greaterThan(5));
  });

  testWidgets('dashes only the series that asked, leaving the others solid', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      const PlLineChart(
        series: <PlassChartSeries>[
          PlassChartSeries(name: 'Actual', data: data),
          PlassChartSeries(name: 'Forecast', data: data, dashed: true),
        ],
      ),
    );

    final List<int> counts = strokedContours(draw(tester));

    expect(counts, hasLength(2));
    expect(counts.first, 1);
    expect(counts.last, greaterThan(5));
  });

  testWidgets('an area chart dashes the line over its wash', (WidgetTester tester) async {
    await pump(
      tester,
      const PlAreaChart(
        series: <PlassChartSeries>[PlassChartSeries(name: 'Forecast', data: data, dashed: true)],
      ),
    );

    final List<int> counts = strokedContours(draw(tester));

    expect(counts, hasLength(1));
    expect(counts.single, greaterThan(5));
  });

  testWidgets('leaves a stacked band alone, which has no line along its top', (
    WidgetTester tester,
  ) async {
    // A stacked band's fill *is* its mark, so nothing is stroked along its edge
    // and there is nothing for `dashed` to cut.
    await pump(
      tester,
      const PlAreaChart(
        stacking: PlAreaStacking.total,
        series: <PlassChartSeries>[
          PlassChartSeries(name: 'Actual', data: data),
          PlassChartSeries(name: 'Forecast', data: data, dashed: true),
        ],
      ),
    );

    for (final int count in strokedContours(draw(tester))) {
      expect(count, 1);
    }
  });

  group("a dashed series' legend entry", () {
    /// How many dashes the key beside [name] draws, or `null` for a square,
    /// which is a box rather than anything painted.
    int? dashesOf(WidgetTester tester, String name) {
      final Finder entry = find.ancestor(of: find.text(name), matching: find.byType(Row)).first;
      final Finder painted = find.descendant(of: entry, matching: find.byType(CustomPaint));

      if (painted.evaluate().isEmpty) {
        return null;
      }

      final canvas = RecordingCanvas();

      tester
          .widget<CustomPaint>(painted.first)
          .painter!
          .paint(canvas, tester.getSize(painted.first));

      return canvas.contours.single;
    }

    const List<PlassChartSeries> pair = <PlassChartSeries>[
      PlassChartSeries(name: 'Actual', data: data),
      PlassChartSeries(name: 'Forecast', data: data, dashed: true),
    ];

    testWidgets('is a dashed rule where the plot draws a dashed line, and a square beside it', (
      WidgetTester tester,
    ) async {
      await pump(tester, const PlLineChart(series: pair));

      expect(dashesOf(tester, 'Forecast'), 2);
      expect(dashesOf(tester, 'Actual'), isNull);
    });

    testWidgets('is a dashed rule on an area chart that is not stacked', (
      WidgetTester tester,
    ) async {
      await pump(tester, const PlAreaChart(series: pair));

      expect(dashesOf(tester, 'Forecast'), 2);
    });

    testWidgets('stays a square where the plot draws no line to dash', (WidgetTester tester) async {
      await pump(tester, const PlAreaChart(stacking: PlAreaStacking.total, series: pair));
      expect(dashesOf(tester, 'Forecast'), isNull);

      await pump(tester, const PlBarChart(series: pair));
      expect(dashesOf(tester, 'Forecast'), isNull);
    });
  });
}
