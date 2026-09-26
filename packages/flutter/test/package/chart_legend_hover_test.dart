// What a chart does with the legend entry under the pointer when it is built
// again without that entry.
//
// Pointing at an entry fades every other series, and the entry says so through
// its `MouseRegion`. A region that is unmounted while the pointer is on it never
// calls `onExit`, so an entry taken out of the legend from under the pointer —
// its series gone, or the whole legend gone with all but one series — used to
// leave its series hovered: nothing faded while its place was past the end, and
// the others faded again once the data brought a series back to that place,
// wherever the pointer was by then.
//
// A test of the legend every chart shares rather than of one chart, which is
// why it is here rather than under `test/components/`. A line stands for the
// charts on the shared frame, and a pie for itself: those are the two places
// that hold the hovered entry. Both draw every series at full strength at rest,
// so a paint with any alpha at all is a faded one.
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/canvas.dart';
import '../support/host.dart';

const List<PlassChartCategory> _months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
];

List<PlassChartSeries> _series(List<String> names) => <PlassChartSeries>[
  for (int i = 0; i < names.length; i += 1)
    PlassChartSeries(
      name: names[i],
      data: <PlassChartDatum>[
        PlassChartDatum(10.0 + i),
        PlassChartDatum(20.0 + i),
        PlassChartDatum(15.0 + i),
      ],
    ),
];

// Names of one length, laid out from the start, so an entry stands where the
// one before it at that place stood.
const PlChartLegend _legend = PlChartLegend(align: PlassAlign.start);

/// Each chart with a legend, built with one series or slice per name.
final Map<String, Widget Function(List<String> names)> _charts =
    <String, Widget Function(List<String> names)>{
      'a line': (List<String> names) =>
          PlLineChart(series: _series(names), categories: _months, legend: _legend),
      'a pie': (List<String> names) => PlPieChart(
        data: <PlassChartDatum>[
          for (int i = 0; i < names.length; i += 1) PlassChartDatum(40.0 - i * 10),
        ],
        categories: <PlassChartCategory>[
          for (final String name in names) PlassChartCategory.text(name),
        ],
        legend: _legend,
        height: 240,
      ),
    };

/// Whether any series or slice on the plot is drawn faded.
bool _faded(WidgetTester tester) {
  final canvas = RecordingCanvas();
  final Finder plot = find.byWidgetPredicate(
    (Widget widget) => widget is CustomPaint && widget.painter != null && widget.size.height > 40,
  );

  tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

  return canvas.paints.any((Paint paint) => paint.color.a < 1);
}

void main() {
  for (final MapEntry<String, Widget Function(List<String> names)> chart in _charts.entries) {
    group('${chart.key} chart', () {
      late StateSetter setNames;
      List<String> names = <String>[];

      /// Builds the chart over [initial], and puts a mouse on the entry named
      /// [entry].
      Future<TestGesture> pointAt(WidgetTester tester, List<String> initial, String entry) async {
        tester.view.physicalSize = const Size(600, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        names = initial;
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                setNames = setState;

                return chart.value(names);
              },
            ),
            width: 600,
          ),
        );
        await tester.pumpAndSettle();

        expect(_faded(tester), isFalse);

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(find.bySemanticsLabel(entry)));
        await tester.pumpAndSettle();

        expect(_faded(tester), isTrue);

        return mouse;
      }

      testWidgets('lets go of the last entry when it is built again without it', (
        WidgetTester tester,
      ) async {
        final TestGesture mouse = await pointAt(tester, <String>['Aaa', 'Bbb', 'Ccc'], 'Ccc');

        setNames(() => names = <String>['Aaa', 'Bbb']);
        await tester.pumpAndSettle();

        expect(_faded(tester), isFalse);

        // Let go rather than held, so the data bringing a series back to that
        // place does not bring the fading back with it once the pointer has
        // gone somewhere else.
        await mouse.moveTo(Offset.zero);
        setNames(() => names = <String>['Aaa', 'Bbb', 'Ccc']);
        await tester.pumpAndSettle();

        expect(_faded(tester), isFalse);
      });

      testWidgets('lets go of an entry when the legend goes with all but one series', (
        WidgetTester tester,
      ) async {
        final TestGesture mouse = await pointAt(tester, <String>['Aaa', 'Bbb'], 'Aaa');

        setNames(() => names = <String>['Aaa']);
        await tester.pumpAndSettle();

        await mouse.moveTo(Offset.zero);
        setNames(() => names = <String>['Aaa', 'Bbb']);
        await tester.pumpAndSettle();

        expect(_faded(tester), isFalse);
      });

      testWidgets('keeps an entry whose place a series took while the pointer is still on it', (
        WidgetTester tester,
      ) async {
        await pointAt(tester, <String>['Aaa', 'Bbb', 'Ccc'], 'Bbb');

        // The entries are not keyed, so the one under the pointer is the same
        // entry, now naming Ccc, and the pointer has not left it.
        setNames(() => names = <String>['Aaa', 'Ccc']);
        await tester.pumpAndSettle();

        expect(_faded(tester), isTrue);
      });
    });
  }
}
