import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlassChartSeries> _change = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Net change',
    data: <PlassChartDatum>[
      PlassChartDatum(12),
      PlassChartDatum(-8),
      PlassChartDatum(24),
      PlassChartDatum(-3),
      PlassChartDatum(18),
      PlassChartDatum(-14),
      PlassChartDatum(9),
    ],
  ),
];

const List<PlassChartCategory> _months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
  PlassChartCategory.text('Apr'),
  PlassChartCategory.text('May'),
  PlassChartCategory.text('Jun'),
  PlassChartCategory.text('Jul'),
];

class BarChartNegative extends StatelessWidget {
  const BarChartNegative({super.key});

  @override
  Widget build(BuildContext context) {
    return PlBarChart(
      series: _change,
      categories: _months,
      valueLabels: PlassChartValueLabels.all,
      legend: const PlChartLegend(hidden: true),
      format: (double value) => value > 0 ? '+${value.toInt()}' : '${value.toInt()}',
    );
  }
}
