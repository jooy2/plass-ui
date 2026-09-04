import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MeterThresholds extends StatefulWidget {
  const MeterThresholds({super.key});

  @override
  State<MeterThresholds> createState() => _MeterThresholdsState();
}

class _MeterThresholdsState extends State<MeterThresholds> {
  double _used = 40;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PlMeter(
            value: _used,
            label: const Text('Disk used'),
            showValue: true,
            thresholds: const <PlMeterThreshold>[
              PlMeterThreshold(from: 75, color: PlassColor.warning),
              PlMeterThreshold(from: 90, color: PlassColor.danger),
            ],
          ),
          const SizedBox(height: 20),
          PlSlider(
            label: const Text('Drag to fill it'),
            values: <double>[_used],
            onChanged: (List<double> next) => setState(() => _used = next.first),
          ),
        ],
      ),
    );
  }
}
