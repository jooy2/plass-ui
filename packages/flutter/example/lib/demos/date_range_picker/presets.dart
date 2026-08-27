import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// Days back from today, at midnight.
DateTime _daysAgo(int count) {
  final DateTime now = DateTime.now();

  return DateTime(now.year, now.month, now.day - count);
}

class DateRangePickerPresets extends StatefulWidget {
  const DateRangePickerPresets({super.key});

  @override
  State<DateRangePickerPresets> createState() => _DateRangePickerPresetsState();
}

class _DateRangePickerPresetsState extends State<DateRangePickerPresets> {
  PlDateRange _value = PlDateRange.empty;

  @override
  Widget build(BuildContext context) {
    return PlDateRangePicker(
      label: const Text('Reporting period'),
      startPlaceholder: const Text('From'),
      endPlaceholder: const Text('To'),
      maxDate: DateTime.now(),
      value: _value,
      onChanged: (PlDateRange next) => setState(() => _value = next),
      presets: <PlDateRangePreset>[
        PlDateRangePreset(
          label: const Text('Last 7 days'),
          build: () => PlDateRange(start: _daysAgo(6), end: DateTime.now()),
        ),
        PlDateRangePreset(
          label: const Text('Last 30 days'),
          build: () => PlDateRange(start: _daysAgo(29), end: DateTime.now()),
        ),
        PlDateRangePreset(
          label: const Text('This month'),
          build: () {
            final DateTime now = DateTime.now();

            return PlDateRange(start: DateTime(now.year, now.month), end: now);
          },
        ),
      ],
    );
  }
}
