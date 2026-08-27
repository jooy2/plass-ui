import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DatePickerBounds extends StatefulWidget {
  const DatePickerBounds({super.key});

  @override
  State<DatePickerBounds> createState() => _DatePickerBoundsState();
}

class _DatePickerBoundsState extends State<DatePickerBounds> {
  DateTime? _within;
  DateTime? _weekday;

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();

    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          PlDatePicker(
            fullWidth: true,
            label: const Text('Within three weeks'),
            placeholder: const Text('Pick a day'),
            minDate: today,
            maxDate: DateTime(today.year, today.month, today.day + 21),
            value: _within,
            onChanged: (DateTime? next) => setState(() => _within = next),
          ),
          PlDatePicker(
            fullWidth: true,
            label: const Text('Weekdays only'),
            placeholder: const Text('Pick a day'),
            shouldDisableDate: (DateTime date) =>
                date.weekday == DateTime.saturday || date.weekday == DateTime.sunday,
            value: _weekday,
            onChanged: (DateTime? next) => setState(() => _weekday = next),
          ),
        ],
      ),
    );
  }
}
