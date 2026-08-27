import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DateRangePickerControlled extends StatefulWidget {
  const DateRangePickerControlled({super.key});

  @override
  State<DateRangePickerControlled> createState() => _DateRangePickerControlledState();
}

class _DateRangePickerControlledState extends State<DateRangePickerControlled> {
  PlDateRange _range = PlDateRange.empty;

  @override
  Widget build(BuildContext context) {
    final DateTime? start = _range.start;
    final DateTime? end = _range.end;
    final int? nights = start != null && end != null ? end.difference(start).inDays : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        PlDateRangePicker(
          label: const Text('Stay'),
          startPlaceholder: const Text('Check in'),
          endPlaceholder: const Text('Check out'),
          clearable: true,
          value: _range,
          onChanged: (PlDateRange next) => setState(() => _range = next),
        ),
        PlTypography(
          nights == null ? 'Pick both ends.' : '$nights night${nights == 1 ? '' : 's'}.',
          level: PlTypographyLevel.caption,
        ),
      ],
    );
  }
}
