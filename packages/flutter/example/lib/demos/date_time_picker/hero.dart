import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DateTimePickerHero extends StatefulWidget {
  const DateTimePickerHero({super.key});

  @override
  State<DateTimePickerHero> createState() => _DateTimePickerHeroState();
}

class _DateTimePickerHeroState extends State<DateTimePickerHero> {
  DateTime? _value;

  @override
  Widget build(BuildContext context) {
    return PlDateTimePicker(
      label: const Text('Starts'),
      description: const Text('Not before now.'),
      placeholder: const Text('Pick a moment'),
      minDate: DateTime.now(),
      minuteStep: 15,
      clearable: true,
      value: _value,
      onChanged: (DateTime? next) => setState(() => _value = next),
    );
  }
}
