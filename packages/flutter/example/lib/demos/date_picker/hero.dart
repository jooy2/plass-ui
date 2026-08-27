import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DatePickerHero extends StatefulWidget {
  const DatePickerHero({super.key});

  @override
  State<DatePickerHero> createState() => _DatePickerHeroState();
}

class _DatePickerHeroState extends State<DatePickerHero> {
  DateTime? _value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: PlDatePicker(
        fullWidth: true,
        label: const Text('Departure'),
        description: const Text('Any day from today.'),
        placeholder: const Text('Pick a day'),
        minDate: DateTime.now(),
        clearable: true,
        value: _value,
        onChanged: (DateTime? next) => setState(() => _value = next),
      ),
    );
  }
}
