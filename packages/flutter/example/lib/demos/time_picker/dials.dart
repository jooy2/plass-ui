import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

final DateTime _value = DateTime(2026, 7, 27, 21, 5);

class TimePickerDials extends StatefulWidget {
  const TimePickerDials({super.key});

  @override
  State<TimePickerDials> createState() => _TimePickerDialsState();
}

class _TimePickerDialsState extends State<TimePickerDials> {
  DateTime _twentyFour = _value;
  DateTime _twelve = _value;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: <Widget>[
        PlTimePicker(
          label: const Text('24 hours'),
          value: _twentyFour,
          onChanged: (DateTime? next) => setState(() => _twentyFour = next ?? _twentyFour),
        ),
        PlTimePicker(
          label: const Text('12 hours'),
          hour12: true,
          value: _twelve,
          onChanged: (DateTime? next) => setState(() => _twelve = next ?? _twelve),
        ),
      ],
    );
  }
}
