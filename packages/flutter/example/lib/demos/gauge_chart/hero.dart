import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class GaugeChartHero extends StatelessWidget {
  const GaugeChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 220,
      child: PlGaugeChart(
        value: 1.36,
        max: 2,
        caption: Text('TB of 2 TB used'),
        semanticLabel: 'Storage used',
      ),
    );
  }
}
