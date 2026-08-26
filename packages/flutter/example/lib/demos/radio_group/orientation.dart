import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlRadioOption<String>> _cadence = <PlRadioOption<String>>[
  PlRadioOption<String>(value: 'daily', label: Text('Daily')),
  PlRadioOption<String>(value: 'weekly', label: Text('Weekly')),
  PlRadioOption<String>(value: 'never', label: Text('Never')),
];

class RadioGroupOrientation extends StatefulWidget {
  const RadioGroupOrientation({super.key});

  @override
  State<RadioGroupOrientation> createState() => _RadioGroupOrientationState();
}

class _RadioGroupOrientationState extends State<RadioGroupOrientation> {
  String _down = 'daily';
  String _across = 'daily';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        PlRadioGroup<String>(
          label: const Text('Vertical'),
          options: _cadence,
          value: _down,
          onChanged: (String next) => setState(() => _down = next),
        ),
        PlRadioGroup<String>(
          label: const Text('Horizontal'),
          orientation: PlassOrientation.horizontal,
          options: _cadence,
          value: _across,
          onChanged: (String next) => setState(() => _across = next),
        ),
      ],
    );
  }
}
