import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlassChartDatum> _devices = <PlassChartDatum>[
  PlassChartDatum(58),
  PlassChartDatum(34),
  PlassChartDatum(8),
];

const List<PlassChartCategory> _kinds = <PlassChartCategory>[
  PlassChartCategory.text('Mobile'),
  PlassChartCategory.text('Desktop'),
  PlassChartCategory.text('Tablet'),
];

class PieChartValueLabels extends StatelessWidget {
  const PieChartValueLabels({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlPieChart(
      data: _devices,
      categories: _kinds,
      shape: PlPieShape.donut,
      valueLabels: PlPieLabels.all,
      semanticLabel: 'Sessions by device',
    );
  }
}
