import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CalendarHero extends StatefulWidget {
  const CalendarHero({super.key});

  @override
  State<CalendarHero> createState() => _CalendarHeroState();
}

class _CalendarHeroState extends State<CalendarHero> {
  DateTime? _value = DateTime(2026, 7, 27);

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PlCalendar(value: _value, onChanged: (DateTime? next) => setState(() => _value = next)),
        const SizedBox(height: 12),
        Text(
          _value == null ? 'Nothing chosen' : PlDateNames.english.medium(_value!),
          style: TextStyle(color: tokens.mutedFg, fontSize: 13),
        ),
      ],
    );
  }
}
