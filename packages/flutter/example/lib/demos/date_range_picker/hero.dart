import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DateRangePickerHero extends StatefulWidget {
  const DateRangePickerHero({super.key});

  @override
  State<DateRangePickerHero> createState() => _DateRangePickerHeroState();
}

class _DateRangePickerHeroState extends State<DateRangePickerHero> {
  PlDateRange _value = PlDateRange.empty;

  @override
  Widget build(BuildContext context) {
    return PlDateRangePicker(
      label: const Text('Stay'),
      description: const Text('Two months at a time, because a range usually crosses one.'),
      startPlaceholder: const Text('Check in'),
      endPlaceholder: const Text('Check out'),
      minDate: DateTime.now(),
      clearable: true,
      value: _value,
      onChanged: (PlDateRange next) => setState(() => _value = next),
    );
  }
}
