import 'dart:ui' show Paragraph;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

List<PlassChartDatum> _row(List<double?> values) => <PlassChartDatum>[
  for (final double? value in values)
    if (value == null) const PlassChartDatum.gap() else PlassChartDatum(value),
];

final List<PlassChartSeries> week = <PlassChartSeries>[
  PlassChartSeries(name: 'Mon', data: _row(<double?>[2, 9, 6, 1])),
  PlassChartSeries(name: 'Tue', data: _row(<double?>[3, 11, 8, 2])),
  PlassChartSeries(name: 'Wed', data: _row(<double?>[1, 7, 12, 4])),
];

const List<PlassChartCategory> hours = <PlassChartCategory>[
  PlassChartCategory.text('09'),
  PlassChartCategory.text('12'),
  PlassChartCategory.text('15'),
  PlassChartCategory.text('18'),
];

Future<void> _pump(WidgetTester tester, Widget child, {bool disableAnimations = false}) async {
  tester.view.physicalSize = const Size(500, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 500, disableAnimations: disableAnimations));
  await tester.pumpAndSettle();
}

/// The alpha every cell is filled at now, in the order they are drawn.
List<double> _cellAlphas(WidgetTester tester) {
  final _CellCanvas canvas = _CellCanvas();
  final Finder plot = find
      .byWidgetPredicate(
        (Widget widget) =>
            widget is CustomPaint && widget.painter != null && widget.size.height > 40,
      )
      .first;

  tester.widget<CustomPaint>(plot).painter!.paint(canvas, tester.getSize(plot));

  return canvas.alphas;
}

/// How many of [alphas] are [alpha].
int _count(List<double> alphas, double alpha) =>
    alphas.where((double one) => (one - alpha).abs() < 1e-6).length;

void main() {
  group('PlHeatmapChart', () {
    testWidgets('draws a plot and names itself', (WidgetTester tester) async {
      await _pump(tester, PlHeatmapChart(series: week, categories: hours));

      expect(find.bySemanticsLabel('Chart'), findsOneWidget);
    });

    testWidgets('reads out every cell with both of its coordinates', (WidgetTester tester) async {
      await _pump(tester, PlHeatmapChart(series: week, categories: hours));

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('Mon: 09 2, 12 9, 15 6, 18 1'));
      expect(node.value, contains('Wed: 09 1'));
    });

    testWidgets('writes a cell compactly and grouped without a format', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PlHeatmapChart(
          series: <PlassChartSeries>[
            PlassChartSeries(name: 'Mon', data: _row(<double?>[1234.5, 48300])),
          ],
          categories: hours.sublist(0, 2),
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('Mon: 09 1,234.5, 12 48.3K'));
    });

    testWidgets('writes a date column as a day rather than a timestamp', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PlHeatmapChart(
          series: week,
          categories: <PlassChartCategory>[
            for (int day = 1; day <= 4; day += 1) PlassChartCategory.date(DateTime(2026, 3, day)),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('Mon: Mar 1 2, Mar 2 9'));
      expect(node.value, isNot(contains('2026-03')));
    });

    testWidgets('names a treemap tile after its own point rather than the first group', (
      WidgetTester tester,
    ) async {
      PlassChartDatum at(String name, double value) =>
          PlassChartDatum.point(PlassChartPoint(x: PlassChartCategory.text(name), y: value));

      await _pump(
        tester,
        PlHeatmapChart(
          shape: PlHeatmapShape.treemap,
          series: <PlassChartSeries>[
            PlassChartSeries(
              name: 'Infrastructure',
              data: <PlassChartDatum>[at('Compute', 4), at('Storage', 2)],
            ),
            PlassChartSeries(name: 'Tooling', data: <PlassChartDatum>[at('CI', 3)]),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('Tooling: CI 3'));
      expect(node.value, isNot(contains('Tooling: Compute')));
    });

    testWidgets('leaves a gap out of the reading', (WidgetTester tester) async {
      await _pump(
        tester,
        PlHeatmapChart(
          series: <PlassChartSeries>[
            PlassChartSeries(name: 'Mon', data: _row(<double?>[2, null, 6])),
          ],
          categories: hours,
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, 'Mon: 09 2, 15 6');
    });

    testWidgets('says nothing is there when every cell is a gap', (WidgetTester tester) async {
      await _pump(
        tester,
        PlHeatmapChart(
          series: <PlassChartSeries>[
            PlassChartSeries(name: 'Mon', data: _row(<double?>[null, null])),
          ],
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('names the two ends of the scale in the legend', (WidgetTester tester) async {
      await _pump(
        tester,
        PlHeatmapChart(
          series: <PlassChartSeries>[
            PlassChartSeries(name: 'Mon', data: _row(<double?>[4, 40])),
          ],
        ),
      );

      expect(find.text('4'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
    });

    testWidgets('names the middle too when the scale diverges', (WidgetTester tester) async {
      await _pump(
        tester,
        PlHeatmapChart(
          scale: PlChartScaleKind.diverging,
          midpoint: 50,
          series: <PlassChartSeries>[
            PlassChartSeries(name: 'Delta', data: _row(<double?>[20, 80])),
          ],
        ),
      );

      // Both arms reach as far as the further one, so the ends are symmetric
      // about the middle rather than the data's own two values.
      expect(find.text('50'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
    });

    testWidgets('takes both shapes it names', (WidgetTester tester) async {
      for (final PlHeatmapShape shape in PlHeatmapShape.values) {
        await _pump(tester, PlHeatmapChart(series: week, categories: hours, shape: shape));

        expect(find.byType(PlHeatmapChart), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('takes every value-label setting it names', (WidgetTester tester) async {
      for (final PlHeatmapLabels which in PlHeatmapLabels.values) {
        await _pump(tester, PlHeatmapChart(series: week, categories: hours, valueLabels: which));

        expect(find.byType(PlHeatmapChart), findsOneWidget);
      }
    });

    testWidgets('shows a readout for the cell under the press', (WidgetTester tester) async {
      await _pump(tester, PlHeatmapChart(series: week, categories: hours, height: 240));

      final Rect plot = tester.getRect(find.byType(CustomPaint).first);

      // The first row's second cell: a quarter along the columns, a sixth down.
      await tester.tapAt(Offset(plot.left + plot.width * 0.45, plot.top + plot.height * 0.17));
      await tester.pumpAndSettle();

      expect(find.textContaining(' · '), findsOneWidget);
    });

    testWidgets('takes a second press on the same cell as a dismissal', (
      WidgetTester tester,
    ) async {
      await _pump(tester, PlHeatmapChart(series: week, categories: hours, height: 240));

      final Rect plot = tester.getRect(find.byType(CustomPaint).first);
      final Offset inside = Offset(plot.left + plot.width * 0.45, plot.top + plot.height * 0.17);

      await tester.tapAt(inside);
      await tester.pumpAndSettle();
      expect(find.textContaining(' · '), findsOneWidget);

      await tester.tapAt(inside);
      await tester.pumpAndSettle();
      expect(find.textContaining(' · '), findsNothing);
    });

    testWidgets('brings the cell under the press up to whole over the house duration', (
      WidgetTester tester,
    ) async {
      await _pump(tester, PlHeatmapChart(series: week, categories: hours, height: 240));

      final Rect plot = tester.getRect(find.byType(CustomPaint).first);
      final Offset inside = Offset(plot.left + plot.width * 0.45, plot.top + plot.height * 0.17);
      final int cells = _cellAlphas(tester).length;

      expect(_count(_cellAlphas(tester), 0.94), cells);

      await tester.tapAt(inside);
      await tester.pump();
      // The clock starts on the frame after the change, as an animation's does.
      await tester.pump();
      await tester.pump(PlassTokens.duration ~/ 2);

      // The cell being read halfway along the house curve, and the rest where
      // they were.
      final double up = 0.94 + 0.06 * PlassTokens.ease.transform(0.5);

      expect(_count(_cellAlphas(tester), up), 1);
      expect(_count(_cellAlphas(tester), 0.94), cells - 1);

      await tester.pumpAndSettle();

      expect(_count(_cellAlphas(tester), 1), 1);
      expect(_count(_cellAlphas(tester), 0.94), cells - 1);

      // And back from where it stands once the reading is taken down.
      await tester.tapAt(inside);
      await tester.pump();
      await tester.pump();
      await tester.pump(PlassTokens.duration ~/ 2);

      expect(_count(_cellAlphas(tester), 1 - 0.06 * PlassTokens.ease.transform(0.5)), 1);

      await tester.pumpAndSettle();

      expect(_count(_cellAlphas(tester), 0.94), cells);
    });

    testWidgets('brings the cell under the press up to whole at once under reduced motion', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PlHeatmapChart(series: week, categories: hours, height: 240),
        disableAnimations: true,
      );

      final Rect plot = tester.getRect(find.byType(CustomPaint).first);
      final int cells = _cellAlphas(tester).length;

      await tester.tapAt(Offset(plot.left + plot.width * 0.45, plot.top + plot.height * 0.17));
      await tester.pump();

      expect(_count(_cellAlphas(tester), 1), 1);
      expect(_count(_cellAlphas(tester), 0.94), cells - 1);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('thins the column names by one stride, taken from the widest of them', (
      WidgetTester tester,
    ) async {
      /// Where the centre of each column name is painted.
      Future<List<double>> columnCentres(List<String> names) async {
        await _pump(
          tester,
          PlHeatmapChart(
            series: <PlassChartSeries>[
              PlassChartSeries(
                name: 'Mon',
                data: _row(<double?>[for (int at = 0; at < names.length; at += 1) at + 1.0]),
              ),
            ],
            categories: <PlassChartCategory>[
              for (final String name in names) PlassChartCategory.text(name),
            ],
          ),
        );

        final Finder plot = find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint && widget.painter != null && widget.size.height > 40,
        );
        final canvas = _TextCanvas();

        tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

        // The column names are the lowest line of text on the plot.
        final double bottom = canvas.texts.fold<double>(
          0,
          (double most, Rect one) => one.top > most ? one.top : most,
        );

        return <double>[
          for (final Rect one in canvas.texts)
            if (one.top == bottom) one.center.dx,
        ];
      }

      // The same twelve columns twice: one long name among short ones, then
      // every name that long. Worked out per name, a short name had a stride of
      // one, so the names beside the long one were painted over it.
      final List<double> mixed = await columnCentres(<String>[
        'All night long',
        for (int at = 1; at < 12; at += 1) '$at'.padLeft(2, '0'),
      ]);
      final List<double> long = await columnCentres(List<String>.filled(12, 'All night long'));

      expect(mixed.length, lessThan(12));
      expect(mixed.length, long.length);

      for (int i = 0; i < mixed.length; i += 1) {
        expect(mixed[i], moreOrLessEquals(long[i], epsilon: 1));
      }
    });
  });
}

/// A canvas that keeps the alpha of every rounded box a cell is drawn as, and
/// drops everything else.
class _CellCanvas implements Canvas {
  final List<double> alphas = <double>[];

  @override
  void drawRRect(RRect rrect, Paint paint) => alphas.add(paint.color.a);

  @override
  void noSuchMethod(Invocation invocation) {}
}

/// A canvas that keeps the box of every piece of text painted on it, and drops
/// everything else.
class _TextCanvas implements Canvas {
  final List<Rect> texts = <Rect>[];

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) =>
      texts.add(offset & Size(paragraph.longestLine, paragraph.height));

  @override
  void noSuchMethod(Invocation invocation) {}
}
