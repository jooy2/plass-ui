import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

List<PlassChartDatum> _row(List<double> values) => values.map(PlassChartDatum.new).toList();

final List<PlassChartSeries> _regions = <PlassChartSeries>[
  PlassChartSeries(name: 'Europe', data: _row(<double>[-8, -2, 5, 12])),
  PlassChartSeries(name: 'Asia', data: _row(<double>[3, 9, 14, 18])),
  PlassChartSeries(name: 'Americas', data: _row(<double>[-14, -9, -3, 2])),
];

const List<PlassChartCategory> _quarters = <PlassChartCategory>[
  PlassChartCategory.text('Q1'),
  PlassChartCategory.text('Q2'),
  PlassChartCategory.text('Q3'),
  PlassChartCategory.text('Q4'),
];

class HeatmapChartDiverging extends StatelessWidget {
  const HeatmapChartDiverging({super.key});

  @override
  Widget build(BuildContext context) {
    return PlHeatmapChart(
      series: _regions,
      categories: _quarters,
      scale: PlChartScaleKind.diverging,
      valueLabels: PlHeatmapLabels.all,
      height: 200,
      semanticLabel: 'Growth against last year',
      format: (double value) => value > 0 ? '+${value.toInt()}' : value.toInt().toString(),
    );
  }
}
