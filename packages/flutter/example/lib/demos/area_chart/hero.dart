import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

List<PlassChartDatum> _readings(List<double> values) => values.map(PlassChartDatum.new).toList();

final List<PlassChartSeries> _traffic = <PlassChartSeries>[
  PlassChartSeries(name: 'Direct', data: _readings(<double>[1200, 1350, 1280, 1520, 1610, 1740])),
  PlassChartSeries(name: 'Search', data: _readings(<double>[980, 1120, 1240, 1180, 1390, 1520])),
  PlassChartSeries(name: 'Referral', data: _readings(<double>[420, 460, 510, 480, 560, 610])),
];

const List<PlassChartCategory> _months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
  PlassChartCategory.text('Apr'),
  PlassChartCategory.text('May'),
  PlassChartCategory.text('Jun'),
];

class AreaChartHero extends StatelessWidget {
  const AreaChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlAreaChart(
      series: _traffic,
      categories: _months,
      stacking: PlAreaStacking.total,
      curve: PlChartCurve.smooth,
      yAxis: const PlChartAxis(label: 'Sessions'),
    );
  }
}
