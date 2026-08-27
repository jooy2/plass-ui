import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

final PlDateRange _range = PlDateRange(start: DateTime(2026, 7, 27), end: DateTime(2026, 8, 4));

class DateRangePickerMonths extends StatefulWidget {
  const DateRangePickerMonths({super.key});

  @override
  State<DateRangePickerMonths> createState() => _DateRangePickerMonthsState();
}

class _DateRangePickerMonthsState extends State<DateRangePickerMonths> {
  PlDateRange _two = _range;
  PlDateRange _one = _range;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        PlDateRangePicker(
          label: const Text('Two months (the default)'),
          value: _two,
          onChanged: (PlDateRange next) => setState(() => _two = next),
        ),
        PlDateRangePicker(
          label: const Text('One'),
          monthCount: 1,
          value: _one,
          onChanged: (PlDateRange next) => setState(() => _one = next),
        ),
      ],
    );
  }
}
