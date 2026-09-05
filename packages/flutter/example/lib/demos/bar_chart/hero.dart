import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

List<PlassChartDatum> _readings(List<double> values) => values.map(PlassChartDatum.new).toList();

final List<PlassChartSeries> _revenue = <PlassChartSeries>[
  PlassChartSeries(name: 'This year', data: _readings(<double>[42, 58, 31, 47, 39])),
  PlassChartSeries(name: 'Last year', data: _readings(<double>[35, 44, 38, 41, 30])),
];

const List<PlassChartCategory> _regions = <PlassChartCategory>[
  PlassChartCategory.text('Europe'),
  PlassChartCategory.text('Asia'),
  PlassChartCategory.text('Americas'),
  PlassChartCategory.text('Africa'),
  PlassChartCategory.text('Oceania'),
];

class BarChartHero extends StatelessWidget {
  const BarChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlBarChart(
      series: _revenue,
      categories: _regions,
      yAxis: const PlChartAxis(label: 'Revenue (£m)'),
    );
  }
}
