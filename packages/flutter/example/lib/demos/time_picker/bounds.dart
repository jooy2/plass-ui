import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

final DateTime _day = DateTime(2026, 7, 27);

/// A time of day on the reference day.
DateTime _at(int hours, [int minutes = 0]) =>
    DateTime(_day.year, _day.month, _day.day, hours, minutes);

class TimePickerBounds extends StatefulWidget {
  const TimePickerBounds({super.key});

  @override
  State<TimePickerBounds> createState() => _TimePickerBoundsState();
}

class _TimePickerBoundsState extends State<TimePickerBounds> {
  DateTime? _office;
  DateTime? _half;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: <Widget>[
        PlTimePicker(
          label: const Text('Between 09:30 and 17:00'),
          placeholder: const Text('Pick a time'),
          referenceDate: _day,
          minTime: _at(9, 30),
          maxTime: _at(17),
          value: _office,
          onChanged: (DateTime? next) => setState(() => _office = next),
        ),
        PlTimePicker(
          label: const Text('On the half hour only'),
          placeholder: const Text('Pick a time'),
          referenceDate: _day,
          shouldDisableTime: (DateTime value, PlassTimeUnit unit) =>
              unit == PlassTimeUnit.minute && value.minute != 0 && value.minute != 30,
          value: _half,
          onChanged: (DateTime? next) => setState(() => _half = next),
        ),
      ],
    );
  }
}
