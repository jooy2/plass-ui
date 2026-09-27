// What a chart's legend does with a series that has an `id`.
//
// A legend entry is known by its series' name and how many series before it
// have that name, so a series renamed between two builds was a new entry and
// came back switched on, and two series of one name were told apart by their
// order alone, so when the first left the data, the second took over its
// state. A series with an `id` is known by it instead, and keeps its state, as
// the React build keeps it.
//
// A test of the legend the charts on the shared frame have rather than of one
// chart, which is why it is here rather than under `test/components/`.
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/canvas.dart';
import '../support/host.dart';

const List<PlassChartCategory> _months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
];

/// A line chart with one series per `(id, name)`. The data follows the id, so a
/// series renamed or moved draws what it drew.
Widget _line(List<(String, String)> series) {
  return PlLineChart(
    series: <PlassChartSeries>[
      for (final (String id, String name) in series)
        PlassChartSeries(
          id: id,
          name: name,
          data: <PlassChartDatum>[
            PlassChartDatum(10.0 * id.length),
            PlassChartDatum(20.0 * id.length),
          ],
        ),
    ],
    categories: _months,
    // Names of one length, laid out from the start, so an entry renamed stands
    // where it stood.
    legend: const PlChartLegend(align: PlassAlign.start),
  );
}

/// Checks whether each legend entry called [name] is switched on, in order.
void _expectOn(String name, List<bool> on) {
  final List<SemanticsNode> entries = find.semantics.byLabel(name).evaluate().toList();

  expect(entries, hasLength(on.length), reason: name);

  for (int i = 0; i < on.length; i += 1) {
    expect(entries[i], isSemantics(isChecked: on[i]), reason: '$name at $i');
  }
}

/// Whether any series on the plot is drawn faded.
bool _faded(WidgetTester tester) {
  final canvas = RecordingCanvas();
  final Finder plot = find.byWidgetPredicate(
    (Widget widget) => widget is CustomPaint && widget.painter != null && widget.size.height > 40,
  );

  tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

  return canvas.opacities.any((double opacity) => opacity < 1);
}

void main() {
  late StateSetter setSeries;
  List<(String, String)> series = <(String, String)>[];

  /// Builds the chart over [initial].
  Future<void> build(WidgetTester tester, List<(String, String)> initial) async {
    tester.view.physicalSize = const Size(600, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    series = initial;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            setSeries = setState;

            return _line(series);
          },
        ),
        width: 600,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'switches off one of two series of the same name, and keeps it off when the first leaves',
    (WidgetTester tester) async {
      await build(tester, <(String, String)>[('a', 'Aaa'), ('bb', 'Aaa'), ('ccc', 'Ccc')]);

      await tester.tap(find.bySemanticsLabel('Aaa').at(1));
      await tester.pumpAndSettle();

      _expectOn('Aaa', <bool>[true, false]);
      _expectOn('Ccc', <bool>[true]);

      // The second Aaa is now the first, and still the one switched off.
      setSeries(() => series = <(String, String)>[('bb', 'Aaa'), ('ccc', 'Ccc')]);
      await tester.pumpAndSettle();

      _expectOn('Aaa', <bool>[false]);
      _expectOn('Ccc', <bool>[true]);
    },
  );

  testWidgets('keeps a renamed series switched off', (WidgetTester tester) async {
    await build(tester, <(String, String)>[('a', 'Aaa'), ('bb', 'Bbb'), ('ccc', 'Ccc')]);

    await tester.tap(find.bySemanticsLabel('Bbb'));
    await tester.pumpAndSettle();

    _expectOn('Bbb', <bool>[false]);

    setSeries(() => series = <(String, String)>[('a', 'Aaa'), ('bb', 'Bbx'), ('ccc', 'Ccc')]);
    await tester.pumpAndSettle();

    _expectOn('Aaa', <bool>[true]);
    _expectOn('Bbx', <bool>[false]);
    _expectOn('Ccc', <bool>[true]);
    expect(tester.getSemantics(find.bySemanticsLabel('Chart')).value, isNot(contains('Bbx')));
  });

  testWidgets('keeps the pointer on the entry of a renamed series', (WidgetTester tester) async {
    await build(tester, <(String, String)>[('a', 'Aaa'), ('bb', 'Bbb'), ('ccc', 'Ccc')]);

    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.bySemanticsLabel('Aaa')));
    await tester.pumpAndSettle();

    expect(_faded(tester), isTrue);

    setSeries(() => series = <(String, String)>[('a', 'Aax'), ('bb', 'Bbb'), ('ccc', 'Ccc')]);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Aax'), findsOneWidget);
    expect(_faded(tester), isTrue);
  });
}
