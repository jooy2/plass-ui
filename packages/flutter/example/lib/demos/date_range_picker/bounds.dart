import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DateRangePickerBounds extends StatefulWidget {
  const DateRangePickerBounds({super.key});

  @override
  State<DateRangePickerBounds> createState() => _DateRangePickerBoundsState();
}

class _DateRangePickerBoundsState extends State<DateRangePickerBounds> {
  PlDateRange _ahead = PlDateRange.empty;
  PlDateRange _weekdays = PlDateRange.empty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        PlDateRangePicker(
          label: const Text('From today on'),
          startPlaceholder: const Text('Check in'),
          endPlaceholder: const Text('Check out'),
          minDate: DateTime.now(),
          value: _ahead,
          onChanged: (PlDateRange next) => setState(() => _ahead = next),
        ),
        PlDateRangePicker(
          label: const Text('Weekdays only'),
          startPlaceholder: const Text('From'),
          endPlaceholder: const Text('To'),
          shouldDisableDate: (DateTime date) =>
              date.weekday == DateTime.saturday || date.weekday == DateTime.sunday,
          value: _weekdays,
          onChanged: (PlDateRange next) => setState(() => _weekdays = next),
        ),
      ],
    );
  }
}
