import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlassChartCategory> _months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
  PlassChartCategory.text('Apr'),
  PlassChartCategory.text('May'),
  PlassChartCategory.text('Jun'),
  PlassChartCategory.text('Jul'),
  PlassChartCategory.text('Aug'),
];

const List<PlassChartSeries> _revenue = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Actual',
    data: <PlassChartDatum>[
      PlassChartDatum(128),
      PlassChartDatum(142),
      PlassChartDatum(139),
      PlassChartDatum(156),
      PlassChartDatum(171),
      PlassChartDatum.gap(),
      PlassChartDatum.gap(),
      PlassChartDatum.gap(),
    ],
  ),
  // The same line, picked up where the readings stop. `dashed` is what says the
  // rest of it is a projection rather than a measurement.
  PlassChartSeries(
    name: 'Forecast',
    dashed: true,
    data: <PlassChartDatum>[
      PlassChartDatum.gap(),
      PlassChartDatum.gap(),
      PlassChartDatum.gap(),
      PlassChartDatum.gap(),
      PlassChartDatum(171),
      PlassChartDatum(184),
      PlassChartDatum(192),
      PlassChartDatum(205),
    ],
  ),
];

class LineChartDashed extends StatelessWidget {
  const LineChartDashed({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlLineChart(
      series: _revenue,
      categories: _months,
      connectNulls: true,
      xAxis: PlChartAxis(label: 'Month'),
    );
  }
}
