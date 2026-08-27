import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TimePickerHero extends StatefulWidget {
  const TimePickerHero({super.key});

  @override
  State<TimePickerHero> createState() => _TimePickerHeroState();
}

class _TimePickerHeroState extends State<TimePickerHero> {
  DateTime? _value;

  @override
  Widget build(BuildContext context) {
    return PlTimePicker(
      label: const Text('Doors'),
      description: const Text('Fifteen minutes at a time.'),
      placeholder: const Text('Pick a time'),
      minuteStep: 15,
      clearable: true,
      value: _value,
      onChanged: (DateTime? next) => setState(() => _value = next),
    );
  }
}
