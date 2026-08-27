import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

final DateTime _value = DateTime(2026, 7, 27, 9, 30);

class DateTimePickerStates extends StatelessWidget {
  const DateTimePickerStates({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        PlDateTimePicker(
          label: const Text('Error'),
          error: const Text('Pick a moment.'),
          placeholder: const Text('Pick a moment'),
          value: null,
          onChanged: (DateTime? _) {},
        ),
        PlDateTimePicker(
          label: const Text('Read-only'),
          readOnly: true,
          value: _value,
          onChanged: (DateTime? _) {},
        ),
        PlDateTimePicker(
          label: const Text('Disabled'),
          disabled: true,
          value: _value,
          onChanged: (DateTime? _) {},
        ),
      ],
    );
  }
}
