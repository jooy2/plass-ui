import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CalendarVariants extends StatelessWidget {
  const CalendarVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: <Widget>[
        PlCalendar(
          value: null,
          size: PlassSize.sm,
          defaultMonth: DateTime(2026, 7),
          onChanged: (DateTime? _) {},
        ),
        PlCard(
          child: PlCalendar(
            value: null,
            size: PlassSize.sm,
            // Already inside something that draws a sheet, so it draws none.
            variant: PlassVariant.ghost,
            elevation: 0,
            defaultMonth: DateTime(2026, 7),
            onChanged: (DateTime? _) {},
          ),
        ),
      ],
    );
  }
}
