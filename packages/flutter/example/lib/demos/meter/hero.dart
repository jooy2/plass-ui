import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MeterHero extends StatelessWidget {
  const MeterHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PlMeter(
            value: 18,
            label: const Text('Documents'),
            showValue: true,
            formatValue: (double value) => '${value.toStringAsFixed(0)} of 100 GB',
          ),
          const SizedBox(height: 20),
          const PlMeter(value: 62, label: Text('Seats taken'), showValue: true),
          const SizedBox(height: 20),
          const PlMeter(
            value: 94,
            label: Text('Disk used'),
            showValue: true,
            thresholds: <PlMeterThreshold>[
              PlMeterThreshold(from: 75, color: PlassColor.warning),
              PlMeterThreshold(from: 90, color: PlassColor.danger),
            ],
          ),
        ],
      ),
    );
  }
}
