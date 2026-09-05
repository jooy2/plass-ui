import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlassThreshold> _bands = <PlassThreshold>[
  PlassThreshold(from: 70, color: PlassColor.warning),
  PlassThreshold(from: 90, color: PlassColor.danger),
];

class GaugeChartThresholds extends StatelessWidget {
  const GaugeChartThresholds({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final double value in <double>[42, 78, 96])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: PlGaugeChart(
                value: value,
                thresholds: _bands,
                height: 160,
                caption: const Text('disk'),
                semanticLabel: 'Disk at ${value.toInt()} percent',
              ),
            ),
          ),
      ],
    );
  }
}
