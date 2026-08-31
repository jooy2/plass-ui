import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CalendarPrecision extends StatelessWidget {
  const CalendarPrecision({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: <Widget>[
        PlCalendar(
          value: null,
          precision: PlCalendarPrecision.month,
          defaultMonth: DateTime(2026, 7),
          onChanged: (DateTime? _) {},
        ),
        PlCalendar(
          value: null,
          precision: PlCalendarPrecision.year,
          defaultMonth: DateTime(2026, 7),
          onChanged: (DateTime? _) {},
        ),
      ],
    );
  }
}
