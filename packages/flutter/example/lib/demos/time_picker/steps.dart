import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

final DateTime _value = DateTime(2026, 7, 27, 9, 30);

class TimePickerSteps extends StatefulWidget {
  const TimePickerSteps({super.key});

  @override
  State<TimePickerSteps> createState() => _TimePickerStepsState();
}

class _TimePickerStepsState extends State<TimePickerSteps> {
  DateTime _every = _value;
  DateTime _quarter = _value;
  DateTime _seconds = _value;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: <Widget>[
        PlTimePicker(
          label: const Text('Every minute'),
          value: _every,
          onChanged: (DateTime? next) => setState(() => _every = next ?? _every),
        ),
        PlTimePicker(
          label: const Text('Every 15'),
          minuteStep: 15,
          value: _quarter,
          onChanged: (DateTime? next) => setState(() => _quarter = next ?? _quarter),
        ),
        PlTimePicker(
          label: const Text('With seconds'),
          showSeconds: true,
          secondStep: 5,
          value: _seconds,
          onChanged: (DateTime? next) => setState(() => _seconds = next ?? _seconds),
        ),
      ],
    );
  }
}
