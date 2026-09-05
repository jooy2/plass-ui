import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/line_chart/data.dart';

class LineChartHero extends StatelessWidget {
  const LineChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlLineChart(
      series: revenue,
      categories: months,
      yAxis: const PlChartAxis(label: 'Revenue (£k)'),
      format: (double value) => '£${value.toInt()}k',
    );
  }
}
