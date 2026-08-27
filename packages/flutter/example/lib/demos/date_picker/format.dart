import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

final DateTime _value = DateTime(2026, 7, 27);

class DatePickerFormat extends StatelessWidget {
  const DatePickerFormat({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          PlDatePicker(
            fullWidth: true,
            label: const Text('The names, medium (the default)'),
            value: _value,
            onChanged: (DateTime? _) {},
          ),
          PlDatePicker(
            fullWidth: true,
            label: const Text('Spelled out'),
            value: _value,
            onChanged: (DateTime? _) {},
            formatValue: PlDateNames.english.spell,
          ),
          PlDatePicker(
            fullWidth: true,
            label: const Text('Its own parts'),
            value: _value,
            onChanged: (DateTime? _) {},
            formatValue: (DateTime date) =>
                '${date.year}-${date.month.toString().padLeft(2, '0')}-'
                '${date.day.toString().padLeft(2, '0')}',
          ),
        ],
      ),
    );
  }
}
