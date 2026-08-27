import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

final DateTime _value = DateTime(2026, 7, 27);

class DatePickerStates extends StatelessWidget {
  const DatePickerStates({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          PlDatePicker(
            fullWidth: true,
            label: const Text('Error'),
            error: const Text('Pick a day.'),
            placeholder: const Text('Pick a day'),
            value: null,
            onChanged: (DateTime? _) {},
          ),
          PlDatePicker(
            fullWidth: true,
            label: const Text('Read-only'),
            readOnly: true,
            value: _value,
            onChanged: (DateTime? _) {},
          ),
          PlDatePicker(
            fullWidth: true,
            label: const Text('Disabled'),
            disabled: true,
            value: _value,
            onChanged: (DateTime? _) {},
          ),
        ],
      ),
    );
  }
}
