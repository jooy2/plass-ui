import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class GaugeChartTicks extends StatelessWidget {
  const GaugeChartTicks({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PlGaugeChart(
        value: 4.2,
        max: 6,
        sweep: 270,
        ticks: 7,
        caption: const Text('bar'),
        semanticLabel: 'Line pressure',
        format: (double value) => value.toStringAsFixed(1),
      ),
    );
  }
}
