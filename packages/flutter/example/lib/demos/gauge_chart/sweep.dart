import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class GaugeChartSweep extends StatelessWidget {
  const GaugeChartSweep({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final double sweep in <double>[180, 270, 360])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: PlGaugeChart(
                value: 62,
                sweep: sweep,
                height: 160,
                caption: Text('${sweep.toInt()}°'),
                semanticLabel: 'Load at ${sweep.toInt()} degrees',
              ),
            ),
          ),
      ],
    );
  }
}
