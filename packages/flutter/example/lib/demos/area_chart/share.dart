import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

List<PlassChartDatum> _readings(List<double> values) => values.map(PlassChartDatum.new).toList();

final List<PlassChartSeries> _plans = <PlassChartSeries>[
  PlassChartSeries(name: 'Free', data: _readings(<double>[62, 58, 54, 49, 44, 40])),
  PlassChartSeries(name: 'Pro', data: _readings(<double>[30, 33, 35, 38, 41, 43])),
  PlassChartSeries(name: 'Team', data: _readings(<double>[8, 9, 11, 13, 15, 17])),
];

const List<PlassChartCategory> _quarters = <PlassChartCategory>[
  PlassChartCategory.text('Q1 24'),
  PlassChartCategory.text('Q2 24'),
  PlassChartCategory.text('Q3 24'),
  PlassChartCategory.text('Q4 24'),
  PlassChartCategory.text('Q1 25'),
  PlassChartCategory.text('Q2 25'),
];

class AreaChartShare extends StatelessWidget {
  const AreaChartShare({super.key});

  @override
  Widget build(BuildContext context) {
    return PlAreaChart(series: _plans, categories: _quarters, stacking: PlAreaStacking.full);
  }
}
