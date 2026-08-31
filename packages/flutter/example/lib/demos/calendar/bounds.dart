import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CalendarBounds extends StatelessWidget {
  const CalendarBounds({super.key});

  @override
  Widget build(BuildContext context) {
    return PlCalendar(
      value: null,
      defaultMonth: DateTime(2026, 7),
      minDate: DateTime(2026, 7, 6),
      maxDate: DateTime(2026, 7, 24),
      // A weekend is not a booking day.
      shouldDisableDate: (DateTime date) =>
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday,
      onChanged: (DateTime? _) {},
    );
  }
}
