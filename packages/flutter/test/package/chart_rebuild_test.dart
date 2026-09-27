// What a chart being read does when it is built again with less to read.
//
// A line, bar or area chart read by a key or the pointer holds the column it is
// on, and a scatter, a timeline or a chart in `nearest` mode holds the mark.
// Built again with fewer categories or marks, a column past the end used to be
// looked up and throw a `RangeError`, and a mark that was gone was held on to
// and read again once the data brought one back to its place. The pie lets go
// of a slice that is gone, and these let go of a column or a mark the same way,
// while one that is still there goes on being read. A mark was held by its
// series' place, so a series leaving ahead of it moved the reading onto another
// series; it is held by the key of its series or its timeline row instead.
//
// A test of the frame the five charts share rather than of one of them, which
// is why it is here rather than under `test/components/`.
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';

import '../support/host.dart';

List<PlassChartSeries> _line(int count) => <PlassChartSeries>[
  PlassChartSeries(
    name: 'Revenue',
    data: <PlassChartDatum>[for (int i = 0; i < count; i += 1) PlassChartDatum(10.0 + i)],
  ),
];

List<PlassChartCategory> _months(int count) => <PlassChartCategory>[
  for (int i = 0; i < count; i += 1) PlassChartCategory.text('M${i + 1}'),
];

PlassChartDatum _point(double x, double y) =>
    PlassChartDatum.point(PlassChartPoint(x: PlassChartCategory.number(x), y: y));

PlassChartCategory _day(int day) => PlassChartCategory.date(DateTime(2026, 1, day));

/// Each chart over the frame, built with [count] categories or marks.
final Map<String, Widget Function(int count)> _charts = <String, Widget Function(int count)>{
  'a line': (int count) => PlLineChart(series: _line(count), categories: _months(count)),
  'a bar': (int count) => PlBarChart(series: _line(count), categories: _months(count)),
  'a horizontal bar': (int count) => PlBarChart(
    series: _line(count),
    categories: _months(count),
    orientation: PlassOrientation.horizontal,
  ),
  'an area': (int count) => PlAreaChart(series: _line(count), categories: _months(count)),
  'a nearest line': (int count) => PlLineChart(
    series: _line(count),
    categories: _months(count),
    tooltip: const PlChartTooltip(mode: PlassChartTooltipMode.nearest),
  ),
  'a scatter': (int count) => PlScatterChart(
    series: <PlassChartSeries>[
      PlassChartSeries(
        name: 'Spend',
        data: <PlassChartDatum>[
          for (int i = 0; i < count; i += 1) _point(10.0 * (i + 1), 20.0 + i),
        ],
      ),
    ],
  ),
  'a timeline': (int count) => PlTimelineChart(
    series: <PlassTimelineSeries>[
      PlassTimelineSeries(
        name: 'Design',
        data: <PlassTimelinePoint>[
          for (int i = 0; i < count; i += 1)
            PlassTimelinePoint(
              start: _day(1 + i * 3),
              end: _day(3 + i * 3),
              label: 'Step ${i + 1}',
            ),
        ],
      ),
    ],
  ),
};

/// What the live region is saying.
String _said(WidgetTester tester) {
  return find.semantics.byFlag(SemanticsFlag.isLiveRegion).evaluate().single.label;
}

/// Each chart read by mark, built with one series or row per name, and the key
/// that steps back through its marks. The data follows the name, so a series
/// that moves draws what it drew. A timeline runs on its side, so its marks are
/// walked up and down.
final Map<String, (LogicalKeyboardKey, Widget Function(List<String> names))> _byName =
    <String, (LogicalKeyboardKey, Widget Function(List<String> names))>{
      'a scatter': (
        LogicalKeyboardKey.arrowLeft,
        (List<String> names) => PlScatterChart(
          series: <PlassChartSeries>[
            for (final String name in names)
              PlassChartSeries(
                name: name,
                data: <PlassChartDatum>[
                  for (int at = 0; at < 2; at += 1)
                    _point(10.0 * name.length + at, 20.0 * name.length + at),
                ],
              ),
          ],
        ),
      ),
      'a nearest line': (
        LogicalKeyboardKey.arrowLeft,
        (List<String> names) => PlLineChart(
          series: <PlassChartSeries>[
            for (final String name in names)
              PlassChartSeries(
                name: name,
                data: <PlassChartDatum>[
                  PlassChartDatum(name.length.toDouble()),
                  PlassChartDatum(name.length * 2.0),
                ],
              ),
          ],
          categories: _months(2),
          tooltip: const PlChartTooltip(mode: PlassChartTooltipMode.nearest),
        ),
      ),
      'a timeline': (
        LogicalKeyboardKey.arrowUp,
        (List<String> names) => PlTimelineChart(
          series: <PlassTimelineSeries>[
            for (final String name in names)
              PlassTimelineSeries(
                name: name,
                data: <PlassTimelinePoint>[
                  for (int at = 0; at < 2; at += 1)
                    PlassTimelinePoint(
                      start: _day(1 + at * 10 + name.length),
                      end: _day(4 + at * 10 + name.length),
                    ),
                ],
              ),
          ],
        ),
      ),
    };

void main() {
  for (final MapEntry<String, Widget Function(int count)> chart in _charts.entries) {
    group('${chart.key} chart', () {
      late StateSetter setCount;
      int count = 5;

      /// Arrives on the chart by Tab, built with five categories or marks.
      Future<void> tabTo(WidgetTester tester) async {
        final FocusNode before = FocusNode();

        addTearDown(before.dispose);
        tester.view.physicalSize = const Size(600, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        count = 5;
        await tester.pumpWidget(
          host(
            afterFocusStop(
              before,
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  setCount = setState;

                  return chart.value(count);
                },
              ),
            ),
            width: 600,
          ),
        );
        await tester.pumpAndSettle();

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }

      for (final int fewer in <int>[2, 0]) {
        testWidgets('lets go of the last when it is built again with $fewer', (
          WidgetTester tester,
        ) async {
          await tabTo(tester);

          // The last, which the next build does not have.
          await tester.sendKeyEvent(LogicalKeyboardKey.end);
          await tester.pump();
          expect(_said(tester), isNotEmpty);

          setCount(() => count = fewer);
          await tester.pump();

          expect(tester.takeException(), isNull);
          expect(find.byType(PlassChartTooltipCard), findsNothing);

          // Let go rather than held, so the data bringing it back does not
          // bring the reading back with it.
          setCount(() => count = 5);
          await tester.pump();

          expect(tester.takeException(), isNull);
          expect(_said(tester), isEmpty);
          expect(find.byType(PlassChartTooltipCard), findsNothing);

          await tester.pumpAndSettle();
        });
      }

      testWidgets('keeps reading the first when it is built again with fewer', (
        WidgetTester tester,
      ) async {
        await tabTo(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pump();

        final String first = _said(tester);

        expect(first, isNotEmpty);

        setCount(() => count = 2);
        await tester.pump();

        expect(_said(tester), first);
        expect(find.byType(PlassChartTooltipCard), findsOneWidget);

        // And the walk goes on from it, over what is there now.
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        expect(_said(tester), isNot(first));

        await tester.pumpAndSettle();
      });
    });
  }

  for (final MapEntry<String, (LogicalKeyboardKey, Widget Function(List<String>))> chart
      in _byName.entries) {
    group('${chart.key} chart read by mark', () {
      // Names of different lengths, so every series draws marks of its own.
      const List<String> all = <String>['Web', 'Mobile', 'Desktop', 'Tablets..'];
      final (LogicalKeyboardKey back, Widget Function(List<String>) build) = chart.value;
      late StateSetter setNames;
      List<String> names = all;

      /// Arrives on the chart by Tab and reads the last mark of its third
      /// series by key.
      Future<String> readThird(WidgetTester tester) async {
        final FocusNode before = FocusNode();

        addTearDown(before.dispose);
        tester.view.physicalSize = const Size(600, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        names = all;
        await tester.pumpWidget(
          host(
            afterFocusStop(
              before,
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  setNames = setState;

                  return build(names);
                },
              ),
            ),
            width: 600,
          ),
        );
        await tester.pumpAndSettle();

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // The last mark of the fourth, then two back to the last of the third.
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        expect(_said(tester), contains('Tablets..'));

        await tester.sendKeyEvent(back);
        await tester.pump();
        await tester.sendKeyEvent(back);
        await tester.pump();

        final String read = _said(tester);

        expect(read, contains('Desktop'));

        return read;
      }

      testWidgets('keeps reading a mark of the third series when the first leaves', (
        WidgetTester tester,
      ) async {
        final String read = await readThird(tester);

        setNames(() => names = all.sublist(1));
        await tester.pump();

        expect(_said(tester), read);
        expect(find.byType(PlassChartTooltipCard), findsOneWidget);

        await tester.pumpAndSettle();
      });

      testWidgets('lets go of the mark when its series leaves', (WidgetTester tester) async {
        await readThird(tester);

        setNames(
          () => names = <String>[
            for (final String name in all)
              if (name != 'Desktop') name,
          ],
        );
        await tester.pump();

        expect(_said(tester), isEmpty);
        expect(find.byType(PlassChartTooltipCard), findsNothing);

        await tester.pumpAndSettle();
      });
    });
  }
}
