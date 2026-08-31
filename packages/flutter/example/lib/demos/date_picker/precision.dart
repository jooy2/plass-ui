import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DatePickerPrecision extends StatefulWidget {
  const DatePickerPrecision({super.key});

  @override
  State<DatePickerPrecision> createState() => _DatePickerPrecisionState();
}

class _DatePickerPrecisionState extends State<DatePickerPrecision> {
  DateTime? _day;
  DateTime? _month;
  DateTime? _year;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          PlDatePicker(
            fullWidth: true,
            label: const Text('A birthday'),
            placeholder: const Text('Pick a day'),
            value: _day,
            onChanged: (DateTime? next) => setState(() => _day = next),
          ),
          PlDatePicker(
            fullWidth: true,
            precision: PlDatePickerPrecision.month,
            label: const Text("A card's expiry"),
            placeholder: const Text('Pick a month'),
            value: _month,
            onChanged: (DateTime? next) => setState(() => _month = next),
          ),
          PlDatePicker(
            fullWidth: true,
            precision: PlDatePickerPrecision.year,
            label: const Text('A model year'),
            placeholder: const Text('Pick a year'),
            value: _year,
            onChanged: (DateTime? next) => setState(() => _year = next),
          ),
        ],
      ),
    );
  }
}
