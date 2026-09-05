import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

PlassChartDatum _at(double x, double y, double z) =>
    PlassChartDatum.point(PlassChartPoint(x: PlassChartCategory.number(x), y: y, z: z));

final List<PlassChartSeries> _markets = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Europe',
    data: <PlassChartDatum>[_at(8.2, 62, 84), _at(11.4, 71, 47), _at(6.9, 55, 120)],
  ),
  PlassChartSeries(
    name: 'Asia',
    data: <PlassChartDatum>[_at(14.1, 48, 260), _at(9.6, 66, 31), _at(12.8, 59, 175)],
  ),
];

class ScatterChartBubbles extends StatelessWidget {
  const ScatterChartBubbles({super.key});

  @override
  Widget build(BuildContext context) {
    return PlScatterChart(
      series: _markets,
      semanticLabel: 'Growth against margin',
      xAxis: const PlChartAxis(label: 'Growth (%)'),
      yAxis: const PlChartAxis(label: 'Margin (%)'),
    );
  }
}
