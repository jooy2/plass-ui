// What a chart's legend does with two series of the same name, and with a name
// that is also some other series' place.
//
// A series switched off in the legend was held by its name, or else its place,
// so two series of one name were switched off and on together, and a series
// called '1' shared its key with an unnamed series at index 1 in the same way.
// A repeated name is now keyed by how many series before it have that name,
// and a place never meets a name, as the React build keys them.
//
// A test of the legend every chart shares rather than of one chart, which is
// why it is here rather than under `test/components/`. A line stands for the
// charts on the shared frame, and a pie for itself: those are the two places
// that hold the switched-off series.
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

const List<PlassChartCategory> _months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
];

/// A line chart with one series per name, a `null` name leaving it unnamed.
Widget _line(List<String?> names) {
  return PlLineChart(
    series: <PlassChartSeries>[
      for (int i = 0; i < names.length; i += 1)
        PlassChartSeries(
          name: names[i],
          data: <PlassChartDatum>[PlassChartDatum(10.0 + i), PlassChartDatum(20.0 + i)],
        ),
    ],
    categories: _months,
  );
}

/// A pie with one slice per name.
Widget _pie(List<String> names) {
  return PlPieChart(
    data: <PlassChartDatum>[
      for (int i = 0; i < names.length; i += 1) PlassChartDatum(40.0 - i * 10),
    ],
    categories: <PlassChartCategory>[
      for (final String name in names) PlassChartCategory.text(name),
    ],
  );
}

Future<void> _build(WidgetTester tester, Widget chart) async {
  tester.view.physicalSize = const Size(600, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(chart, width: 600));
  await tester.pumpAndSettle();
}

/// Checks whether each legend entry called [name] is switched on, in order.
void _expectOn(String name, List<bool> on) {
  final List<SemanticsNode> entries = find.semantics.byLabel(name).evaluate().toList();

  expect(entries, hasLength(on.length), reason: name);

  for (int i = 0; i < on.length; i += 1) {
    expect(entries[i], isSemantics(isChecked: on[i]), reason: '$name at $i');
  }
}

/// How many times the chart's summary says [name].
int _said(WidgetTester tester, String name) {
  return name.allMatches(tester.getSemantics(find.bySemanticsLabel('Chart')).value).length;
}

void main() {
  for (final (String kind, Widget chart) in <(String, Widget)>[
    ('a line chart', _line(<String>['Aaa', 'Aaa', 'Ccc'])),
    ('a pie chart', _pie(<String>['Aaa', 'Aaa', 'Ccc'])),
  ]) {
    testWidgets('$kind switches off one of two entries of the same name and leaves the other on', (
      WidgetTester tester,
    ) async {
      await _build(tester, chart);

      _expectOn('Aaa', <bool>[true, true]);
      expect(_said(tester, 'Aaa'), 2);

      await tester.tap(find.bySemanticsLabel('Aaa').at(1));
      await tester.pumpAndSettle();

      _expectOn('Aaa', <bool>[true, false]);
      _expectOn('Ccc', <bool>[true]);
      expect(_said(tester, 'Aaa'), 1);

      await tester.tap(find.bySemanticsLabel('Aaa').at(0));
      await tester.pumpAndSettle();

      _expectOn('Aaa', <bool>[false, false]);
    });
  }

  testWidgets(
    'a line chart switches a series called "1" and an unnamed one at index 1 on their own',
    (WidgetTester tester) async {
      // The unnamed series is listed by its place counted from one, as '2'.
      await _build(tester, _line(<String?>['1', null, 'Ccc']));

      await tester.tap(find.bySemanticsLabel('2'));
      await tester.pumpAndSettle();

      _expectOn('1', <bool>[true]);
      _expectOn('2', <bool>[false]);

      await tester.tap(find.bySemanticsLabel('1'));
      await tester.pumpAndSettle();

      _expectOn('1', <bool>[false]);
      _expectOn('2', <bool>[false]);
      _expectOn('Ccc', <bool>[true]);
    },
  );
}
