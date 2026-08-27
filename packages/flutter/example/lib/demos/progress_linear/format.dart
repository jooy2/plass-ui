import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressLinearFormat extends StatelessWidget {
  const ProgressLinearFormat({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          const PlProgressLinear(
            label: Text('Percentage of the range'),
            value: 3,
            max: 4,
            showValue: true,
          ),
          PlProgressLinear(
            label: const Text('Downloaded'),
            value: 148,
            max: 512,
            showValue: true,
            formatValue: (double value) => '${value.round()} MB',
          ),
        ],
      ),
    );
  }
}
