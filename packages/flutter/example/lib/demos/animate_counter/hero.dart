import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateCounterHero extends StatelessWidget {
  const AnimateCounterHero({super.key});

  static String _thousands(double value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();

    for (int index = 0; index < digits.length; index += 1) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[index]);
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final figure = TextStyle(color: tokens.fg, fontSize: 34, fontWeight: FontWeight.w600);

    return SizedBox(
      width: 380,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          for (final (String label, double value) entry in <(String, double)>[
            ('Projects', 128),
            ('Deploys', 4812),
            ('Uptime', 99),
          ])
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                PlAnimateCounter(
                  value: entry.$2,
                  trigger: PlassAnimateTrigger.mount,
                  formatValue: _thousands,
                  style: figure,
                ),
                Text(entry.$1, style: TextStyle(color: tokens.mutedFg, fontSize: 13)),
              ],
            ),
        ],
      ),
    );
  }
}
