import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

final DateTime _value = DateTime(2026, 7, 27, 9, 30);

class DateTimePickerSteps extends StatefulWidget {
  const DateTimePickerSteps({super.key});

  @override
  State<DateTimePickerSteps> createState() => _DateTimePickerStepsState();
}

class _DateTimePickerStepsState extends State<DateTimePickerSteps> {
  DateTime _quarter = _value;
  DateTime _seconds = _value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        PlDateTimePicker(
          label: const Text('Every 15 minutes'),
          minuteStep: 15,
          value: _quarter,
          onChanged: (DateTime? next) => setState(() => _quarter = next ?? _quarter),
        ),
        PlDateTimePicker(
          label: const Text('With seconds'),
          showSeconds: true,
          secondStep: 15,
          value: _seconds,
          onChanged: (DateTime? next) => setState(() => _seconds = next ?? _seconds),
        ),
      ],
    );
  }
}
