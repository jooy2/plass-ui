// What a screen reader is handed in place of a chart with axes.
//
// There is no table beside a Flutter chart the way there is on the web, so this
// text is the only path to the numbers — and it used to carry one number per
// series, the last, while the scatter and the heatmap in the same package
// already read every value. A reader could hear where a line ended and never
// what it did on the way.
//
// A test of a *contract* rather than of a widget, which is why it is here
// rather than under `test/components/`: line, bar and area are three widgets
// over one frame, and what they say has to be the same shape in all three.
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

const List<PlassChartCategory> months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
];

/// What the chart hands a screen reader.
String said(WidgetTester tester) {
  return tester.getSemantics(find.bySemanticsLabel('Chart')).value;
}

Future<void> pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(500, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 500));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a line chart reads every value, not just the last', (WidgetTester tester) async {
    await pump(
      tester,
      PlLineChart(
        categories: months,
        series: const <PlassChartSeries>[
          PlassChartSeries(
            name: 'Revenue',
            data: <PlassChartDatum>[PlassChartDatum(12), PlassChartDatum(19), PlassChartDatum(15)],
          ),
          PlassChartSeries(
            name: 'Cost',
            data: <PlassChartDatum>[PlassChartDatum(8), PlassChartDatum(11), PlassChartDatum(9)],
          ),
        ],
      ),
    );

    expect(said(tester), 'Revenue: Jan 12; Feb 19; Mar 15. Cost: Jan 8; Feb 11; Mar 9');
  });

  testWidgets('a bar chart and an area chart say it the same way', (WidgetTester tester) async {
    const List<PlassChartSeries> one = <PlassChartSeries>[
      PlassChartSeries(
        name: 'Revenue',
        data: <PlassChartDatum>[PlassChartDatum(12), PlassChartDatum(19), PlassChartDatum(15)],
      ),
    ];

    await pump(tester, const PlBarChart(categories: months, series: one));
    expect(said(tester), 'Revenue: Jan 12; Feb 19; Mar 15');

    await pump(tester, const PlAreaChart(categories: months, series: one));
    expect(said(tester), 'Revenue: Jan 12; Feb 19; Mar 15');
  });

  testWidgets('leaves a gap out rather than reading the category with nothing after it', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      PlLineChart(
        categories: months,
        series: const <PlassChartSeries>[
          PlassChartSeries(
            name: 'Revenue',
            data: <PlassChartDatum>[
              PlassChartDatum(12),
              PlassChartDatum.gap(),
              PlassChartDatum(15),
            ],
          ),
        ],
      ),
    );

    expect(said(tester), 'Revenue: Jan 12; Mar 15');
  });

  testWidgets('names a series of nothing but gaps, and says no number for it', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      PlLineChart(
        categories: months,
        series: const <PlassChartSeries>[
          PlassChartSeries(
            name: 'Revenue',
            data: <PlassChartDatum>[PlassChartDatum(12), PlassChartDatum(19), PlassChartDatum(15)],
          ),
          PlassChartSeries(
            name: 'Cost',
            data: <PlassChartDatum>[
              PlassChartDatum.gap(),
              PlassChartDatum.gap(),
              PlassChartDatum.gap(),
            ],
          ),
        ],
      ),
    );

    expect(said(tester), 'Revenue: Jan 12; Feb 19; Mar 15. Cost');
  });

  testWidgets('leaves the position out where there are no categories to name', (
    WidgetTester tester,
  ) async {
    // Given no `categories` the category is the index, which the order of the
    // reading already carries — and "Revenue, zero, twelve" is a number the
    // reader has to work out is not data.
    await pump(
      tester,
      const PlLineChart(
        series: <PlassChartSeries>[
          PlassChartSeries(
            name: 'Revenue',
            data: <PlassChartDatum>[PlassChartDatum(12), PlassChartDatum(19)],
          ),
        ],
      ),
    );

    expect(said(tester), 'Revenue: 12; 19');
  });

  testWidgets('leaves a series the reader switched off out of it', (WidgetTester tester) async {
    await pump(
      tester,
      PlLineChart(
        categories: months,
        series: const <PlassChartSeries>[
          PlassChartSeries(
            name: 'Revenue',
            data: <PlassChartDatum>[PlassChartDatum(12), PlassChartDatum(19), PlassChartDatum(15)],
          ),
          PlassChartSeries(
            name: 'Cost',
            hidden: true,
            data: <PlassChartDatum>[PlassChartDatum(8), PlassChartDatum(11), PlassChartDatum(9)],
          ),
        ],
      ),
    );

    expect(said(tester), 'Revenue: Jan 12; Feb 19; Mar 15');
  });

  /// A series with nothing in it but a gap.
  const List<PlassChartSeries> gaps = <PlassChartSeries>[
    PlassChartSeries(data: <PlassChartDatum>[PlassChartDatum.gap()]),
  ];

  for (final (String name, Widget chart) in <(String, Widget)>[
    ('line', const PlLineChart(series: gaps)),
    ('bar', const PlBarChart(series: gaps)),
    ('area', const PlAreaChart(series: gaps)),
    ('scatter', const PlScatterChart(series: gaps)),
    ('timeline', const PlTimelineChart(series: <PlassTimelineSeries>[])),
  ]) {
    testWidgets('an empty $name chart says nothing about the focus', (WidgetTester tester) async {
      await pump(tester, chart);

      expect(find.text('Nothing here'), findsOneWidget);
      // Not a tab stop, and not announced as one either: a `focused` of false
      // would still say the node could hold the focus.
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Chart'))),
        isSemantics(isFocusable: false),
      );
    });
  }

  PlassChartDatum point(double x, double y) =>
      PlassChartDatum.point(PlassChartPoint(x: PlassChartCategory.number(x), y: y));

  const List<PlassChartSeries> one = <PlassChartSeries>[
    PlassChartSeries(
      name: 'Revenue',
      data: <PlassChartDatum>[PlassChartDatum(12), PlassChartDatum(19), PlassChartDatum(15)],
    ),
  ];

  // One series each, so there is no legend and nothing on the chart a reader
  // presses at all.
  for (final (String name, Widget chart) in <(String, Widget)>[
    ('line', const PlLineChart(categories: months, series: one)),
    ('bar', const PlBarChart(categories: months, series: one)),
    ('area', const PlAreaChart(categories: months, series: one)),
    (
      'scatter',
      PlScatterChart(
        series: <PlassChartSeries>[
          PlassChartSeries(name: 'Q1', data: <PlassChartDatum>[point(10, 22), point(20, 31)]),
        ],
      ),
    ),
    (
      'timeline',
      PlTimelineChart(
        series: <PlassTimelineSeries>[
          PlassTimelineSeries(
            name: 'Design',
            data: <PlassTimelinePoint>[
              PlassTimelinePoint(
                start: PlassChartCategory.date(DateTime(2026, 1, 1)),
                end: PlassChartCategory.date(DateTime(2026, 1, 9)),
                label: 'Wireframes',
              ),
            ],
          ),
        ],
      ),
    ),
  ]) {
    testWidgets('gives a screen reader nothing to scroll or tap on the $name chart', (
      WidgetTester tester,
    ) async {
      await pump(tester, chart);

      // The chart's own node is how it is read: every value, and the columns
      // walked by key. A tap on the picture read only what was under its
      // middle, and a scroll handed it a place on the screen for a place on
      // the plot, so both scrolls did the same thing.
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Chart'))),
        isSemantics(isFocusable: true),
      );
      expect(
        find.semantics.byAnyAction(<SemanticsAction>[
          SemanticsAction.tap,
          SemanticsAction.scrollLeft,
          SemanticsAction.scrollRight,
          SemanticsAction.scrollUp,
          SemanticsAction.scrollDown,
        ]),
        findsNothing,
      );
    });
  }
}
