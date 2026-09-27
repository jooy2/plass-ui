// The crosshair a chart of columns drops through the column being read.
//
// It says "these numbers all belong to this column", so it is drawn in the
// column mode only, where the card holds the whole column, and a tooltip can
// turn it off there. It is painted in the chart baseline's token, so a theme
// that changes the baseline changes it too, as `--plass-chart-baseline` does in
// the React build.
//
// A test of the frame the line, area and bar charts share rather than of one of
// them, which is why it is here rather than under `test/components/`.
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';

import '../support/host.dart';

const List<PlassChartSeries> _series = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Revenue',
    data: <PlassChartDatum>[
      PlassChartDatum(12),
      PlassChartDatum(19),
      PlassChartDatum(15),
      PlassChartDatum(22),
    ],
  ),
  PlassChartSeries(
    name: 'Cost',
    data: <PlassChartDatum>[
      PlassChartDatum(8),
      PlassChartDatum(11),
      PlassChartDatum(9),
      PlassChartDatum(13),
    ],
  ),
];

const List<PlassChartCategory> _months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
  PlassChartCategory.text('Apr'),
];

/// The plot's painter, which is the tallest `CustomPaint` with one.
Finder _plot() {
  return find
      .byWidgetPredicate(
        (Widget widget) =>
            widget is CustomPaint && widget.painter != null && widget.size.height > 40,
      )
      .first;
}

/// Builds [chart] and rests the pointer on the middle of its plot, so a column
/// is being read.
Future<void> _hover(WidgetTester tester, Widget chart) async {
  tester.view.physicalSize = const Size(500, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(chart, width: 500));
  await tester.pumpAndSettle();

  final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(tester.getCenter(_plot()));
  await tester.pumpAndSettle();

  // The card is up, so a column is being read and a crosshair would be drawn
  // by now if this chart drew one.
  expect(find.byType(PlassChartTooltipCard), findsOneWidget);
}

/// The colour of every rule the plot paints straight down, as it is painted
/// now, in 32-bit ARGB: a paint keeps its colour at a lower precision than a
/// `Color` does, so two of the same colour are not always equal.
List<int> _downRules(WidgetTester tester) {
  final _RuleCanvas canvas = _RuleCanvas();

  tester.widget<CustomPaint>(_plot()).painter!.paint(canvas, tester.getSize(_plot()));

  return canvas.downRules;
}

void main() {
  testWidgets('is drawn through the column in the column mode, in the baseline token', (
    WidgetTester tester,
  ) async {
    const Color baseline = Color(0xFF12AB34);

    await _hover(
      tester,
      PlassTheme.tokens(
        tokens: PlassTokens.light().copyWith(chartBaseline: baseline),
        child: const PlLineChart(series: _series, categories: _months),
      ),
    );

    expect(_downRules(tester), <int>[baseline.toARGB32()]);
  });

  testWidgets('is not drawn in the item mode', (WidgetTester tester) async {
    await _hover(
      tester,
      const PlLineChart(
        series: _series,
        categories: _months,
        tooltip: PlChartTooltip(mode: PlassChartTooltipMode.item),
      ),
    );

    expect(_downRules(tester), isEmpty);
  });

  testWidgets('is not drawn when the tooltip turns it off', (WidgetTester tester) async {
    await _hover(
      tester,
      const PlLineChart(
        series: _series,
        categories: _months,
        tooltip: PlChartTooltip(crosshair: false),
      ),
    );

    expect(_downRules(tester), isEmpty);
  });
}

/// A canvas that keeps the colour of every rule drawn straight down, which on a
/// chart whose columns stand upright is only ever the crosshair, and drops
/// everything else.
class _RuleCanvas implements Canvas {
  final List<int> downRules = <int>[];

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    if (p1.dx == p2.dx) {
      downRules.add(paint.color.toARGB32());
    }
  }

  @override
  void noSuchMethod(Invocation invocation) {}
}
