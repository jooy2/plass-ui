import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

final DateTime _value = DateTime(2026, 7, 27, 9, 30);

class TimePickerStates extends StatelessWidget {
  const TimePickerStates({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: <Widget>[
        PlTimePicker(
          label: const Text('Error'),
          error: const Text('Pick a time.'),
          placeholder: const Text('Pick a time'),
          value: null,
          onChanged: (DateTime? _) {},
        ),
        PlTimePicker(
          label: const Text('Read-only'),
          readOnly: true,
          value: _value,
          onChanged: (DateTime? _) {},
        ),
        PlTimePicker(
          label: const Text('Disabled'),
          disabled: true,
          value: _value,
          onChanged: (DateTime? _) {},
        ),
      ],
    );
  }
}
