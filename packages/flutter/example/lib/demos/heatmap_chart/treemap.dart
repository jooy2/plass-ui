import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

PlassChartDatum _at(String name, double value) =>
    PlassChartDatum.point(PlassChartPoint(x: PlassChartCategory.text(name), y: value));

final List<PlassChartSeries> _spend = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Infrastructure',
    data: <PlassChartDatum>[_at('Compute', 4200), _at('Storage', 1800), _at('Network', 900)],
  ),
  PlassChartSeries(
    name: 'Tooling',
    data: <PlassChartDatum>[_at('CI', 1200), _at('Monitoring', 700), _at('Analytics', 480)],
  ),
  PlassChartSeries(
    name: 'People',
    data: <PlassChartDatum>[_at('Licences', 2600), _at('Training', 640)],
  ),
];

class HeatmapChartTreemap extends StatelessWidget {
  const HeatmapChartTreemap({super.key});

  @override
  Widget build(BuildContext context) {
    return PlHeatmapChart(
      series: _spend,
      shape: PlHeatmapShape.treemap,
      valueLabels: PlHeatmapLabels.all,
      height: 280,
      semanticLabel: 'Monthly spend',
    );
  }
}
