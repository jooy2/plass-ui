// Which series a chart keeps switched off when it is built again with
// different series.
//
// A series switched off in the legend used to be held by its place, so a series
// leaving the data ahead of it switched off whichever series moved into that
// place instead, and a place past the new end switched a series off again once
// the data grew back to it. It is held by the key of its legend entry, its name
// or else its place, as the React build holds it, and a key no series has any
// more is let go.
//
// A test of the legend every chart shares rather than of one chart, which is
// why it is here rather than under `test/components/`. A line stands for the
// charts on the shared frame, and a pie for itself: those are the two places
// that hold the switched-off series.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

const List<PlassChartCategory> _months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
];

/// Each chart with a legend, built with one series or slice per name, the
/// names in [hidden] starting switched off.
final Map<String, Widget Function(List<String> names, Set<String> hidden)> _charts =
    <String, Widget Function(List<String> names, Set<String> hidden)>{
      'a line': (List<String> names, Set<String> hidden) => PlLineChart(
        series: <PlassChartSeries>[
          for (int i = 0; i < names.length; i += 1)
            PlassChartSeries(
              name: names[i],
              hidden: hidden.contains(names[i]),
              data: <PlassChartDatum>[PlassChartDatum(10.0 + i), PlassChartDatum(20.0 + i)],
            ),
        ],
        categories: _months,
      ),
      'a pie': (List<String> names, Set<String> _) => PlPieChart(
        data: <PlassChartDatum>[
          for (int i = 0; i < names.length; i += 1) PlassChartDatum(40.0 - i * 10),
        ],
        categories: <PlassChartCategory>[
          for (final String name in names) PlassChartCategory.text(name),
        ],
      ),
    };

void main() {
  for (final MapEntry<String, Widget Function(List<String>, Set<String>)> chart
      in _charts.entries) {
    group('${chart.key} chart', () {
      late StateSetter setNames;
      List<String> names = <String>[];

      /// Builds the chart over [initial].
      Future<void> build(
        WidgetTester tester,
        List<String> initial, {
        Set<String> hidden = const <String>{},
      }) async {
        tester.view.physicalSize = const Size(600, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        names = initial;
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                setNames = setState;

                return chart.value(names, hidden);
              },
            ),
            width: 600,
          ),
        );
        await tester.pumpAndSettle();
      }

      /// Checks which entries the legend says are switched on, and that the
      /// chart reads out those and no others.
      void expectOn(WidgetTester tester, Map<String, bool> on) {
        final String said = tester.getSemantics(find.bySemanticsLabel('Chart')).value;

        for (final MapEntry<String, bool> entry in on.entries) {
          expect(
            tester.getSemantics(find.bySemanticsLabel(entry.key)),
            isSemantics(isChecked: entry.value),
            reason: entry.key,
          );
          expect(said.contains(entry.key), entry.value, reason: entry.key);
        }
      }

      testWidgets('keeps the series it switched off, and not the one that took its place', (
        WidgetTester tester,
      ) async {
        await build(tester, <String>['Aaa', 'Bbb', 'Ccc']);

        await tester.tap(find.bySemanticsLabel('Bbb'));
        await tester.pumpAndSettle();
        expectOn(tester, <String, bool>{'Aaa': true, 'Bbb': false, 'Ccc': true});

        // Ccc moves into the place Bbb was in.
        setNames(() => names = <String>['Bbb', 'Ccc']);
        await tester.pumpAndSettle();

        expectOn(tester, <String, bool>{'Bbb': false, 'Ccc': true});
      });

      testWidgets('lets go of a series that left the data, so it is drawn when it comes back', (
        WidgetTester tester,
      ) async {
        await build(tester, <String>['Aaa', 'Bbb', 'Ccc']);

        await tester.tap(find.bySemanticsLabel('Ccc'));
        await tester.pumpAndSettle();
        expectOn(tester, <String, bool>{'Ccc': false});

        setNames(() => names = <String>['Aaa', 'Bbb']);
        await tester.pumpAndSettle();

        expectOn(tester, <String, bool>{'Aaa': true, 'Bbb': true});

        setNames(() => names = <String>['Aaa', 'Bbb', 'Ccc']);
        await tester.pumpAndSettle();

        expectOn(tester, <String, bool>{'Aaa': true, 'Bbb': true, 'Ccc': true});
      });
    });
  }

  testWidgets('holds a series that starts hidden by its name, and reads `hidden` once', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(600, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    List<String> names = <String>['Aaa', 'Bbb', 'Ccc'];
    Set<String> hidden = <String>{'Bbb'};
    late StateSetter setNames;

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            setNames = setState;

            return _charts['a line']!(names, hidden);
          },
        ),
        width: 600,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSemantics(find.bySemanticsLabel('Bbb')), isSemantics(isChecked: false));

    // Aaa leaves, and the caller lets go of Bbb's `hidden`: it stays off,
    // because the flag is where the chart starts, and the legend is what
    // switches it back on.
    setNames(() {
      names = <String>['Bbb', 'Ccc'];
      hidden = <String>{};
    });
    await tester.pumpAndSettle();

    expect(tester.getSemantics(find.bySemanticsLabel('Bbb')), isSemantics(isChecked: false));
    expect(tester.getSemantics(find.bySemanticsLabel('Ccc')), isSemantics(isChecked: true));
  });
}
