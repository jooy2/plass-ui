import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

List<PlassChartDatum> _row(List<double> values) => values.map(PlassChartDatum.new).toList();

final List<PlassChartSeries> _week = <PlassChartSeries>[
  PlassChartSeries(name: 'Mon', data: _row(<double>[2, 1, 4, 18, 26, 22, 14, 6])),
  PlassChartSeries(name: 'Tue', data: _row(<double>[1, 1, 5, 21, 29, 24, 15, 5])),
  PlassChartSeries(name: 'Wed', data: _row(<double>[2, 2, 6, 23, 31, 27, 16, 7])),
  PlassChartSeries(name: 'Thu', data: _row(<double>[3, 1, 5, 20, 28, 25, 18, 9])),
  PlassChartSeries(name: 'Fri', data: _row(<double>[4, 2, 6, 17, 24, 20, 21, 14])),
  PlassChartSeries(name: 'Sat', data: _row(<double>[8, 5, 4, 9, 12, 15, 19, 17])),
  PlassChartSeries(name: 'Sun', data: _row(<double>[7, 4, 3, 8, 11, 13, 16, 12])),
];

const List<PlassChartCategory> _hours = <PlassChartCategory>[
  PlassChartCategory.text('00'),
  PlassChartCategory.text('03'),
  PlassChartCategory.text('06'),
  PlassChartCategory.text('09'),
  PlassChartCategory.text('12'),
  PlassChartCategory.text('15'),
  PlassChartCategory.text('18'),
  PlassChartCategory.text('21'),
];

class HeatmapChartHero extends StatelessWidget {
  const HeatmapChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlHeatmapChart(series: _week, categories: _hours, semanticLabel: 'Sessions by hour');
  }
}
