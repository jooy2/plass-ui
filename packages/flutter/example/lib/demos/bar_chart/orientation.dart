import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlassChartSeries> _sources = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Sessions',
    data: <PlassChartDatum>[
      PlassChartDatum(4820),
      PlassChartDatum(3910),
      PlassChartDatum(2740),
      PlassChartDatum(1980),
      PlassChartDatum(1120),
    ],
  ),
];

const List<PlassChartCategory> _channels = <PlassChartCategory>[
  PlassChartCategory.text('Organic search'),
  PlassChartCategory.text('Direct traffic'),
  PlassChartCategory.text('Email campaigns'),
  PlassChartCategory.text('Paid social'),
  PlassChartCategory.text('Referral links'),
];

class BarChartOrientation extends StatelessWidget {
  const BarChartOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlBarChart(
      series: _sources,
      categories: _channels,
      orientation: PlassOrientation.horizontal,
      valueLabels: PlassChartValueLabels.all,
      legend: PlChartLegend(hidden: true),
    );
  }
}
