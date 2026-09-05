import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/line_chart/data.dart';

class LineChartLabels extends StatelessWidget {
  const LineChartLabels({super.key});

  @override
  Widget build(BuildContext context) {
    return PlLineChart(
      size: PlassSize.sm,
      series: revenue.sublist(0, 2),
      categories: months,
      valueLabels: PlassChartValueLabels.last,
      markers: PlChartMarkers.none,
      yAxis: const PlChartAxis(hidden: true),
      format: (double value) => '£${value.toInt()}k',
    );
  }
}
