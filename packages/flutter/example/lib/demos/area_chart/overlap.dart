import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

List<PlassChartDatum> _readings(List<double> values) => values.map(PlassChartDatum.new).toList();

final List<PlassChartSeries> _load = <PlassChartSeries>[
  PlassChartSeries(name: 'Capacity', data: _readings(<double>[100, 100, 100, 100, 100, 100, 100])),
  PlassChartSeries(name: 'Peak load', data: _readings(<double>[42, 61, 88, 71, 94, 56, 38])),
];

const List<PlassChartCategory> _days = <PlassChartCategory>[
  PlassChartCategory.text('Mon'),
  PlassChartCategory.text('Tue'),
  PlassChartCategory.text('Wed'),
  PlassChartCategory.text('Thu'),
  PlassChartCategory.text('Fri'),
  PlassChartCategory.text('Sat'),
  PlassChartCategory.text('Sun'),
];

class AreaChartOverlap extends StatelessWidget {
  const AreaChartOverlap({super.key});

  @override
  Widget build(BuildContext context) {
    return PlAreaChart(
      series: _load,
      categories: _days,
      curve: PlChartCurve.smooth,
      format: (double value) => '${value.toInt()}%',
    );
  }
}
