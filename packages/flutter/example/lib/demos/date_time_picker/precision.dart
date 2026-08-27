import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DateTimePickerPrecision extends StatefulWidget {
  const DateTimePickerPrecision({super.key});

  @override
  State<DateTimePickerPrecision> createState() => _DateTimePickerPrecisionState();
}

class _DateTimePickerPrecisionState extends State<DateTimePickerPrecision> {
  DateTime? _day;
  DateTime? _moment;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        PlDatePicker(
          label: const Text('PlDatePicker — the bound is a day'),
          placeholder: const Text('Pick a day'),
          minDate: now,
          value: _day,
          onChanged: (DateTime? next) => setState(() => _day = next),
        ),
        PlDateTimePicker(
          label: const Text('PlDateTimePicker — the bound is a moment'),
          placeholder: const Text('Pick a moment'),
          minDate: now,
          value: _moment,
          onChanged: (DateTime? next) => setState(() => _moment = next),
        ),
      ],
    );
  }
}
