import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class StatHero extends StatelessWidget {
  const StatHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        SizedBox(
          width: 196,
          child: PlCard(
            child: PlStat(
              label: Text('Revenue'),
              value: Text('£48,120'),
              change: 12.4,
              description: Text('vs last month'),
            ),
          ),
        ),
        SizedBox(
          width: 196,
          child: PlCard(
            child: PlStat(
              label: Text('Sign-ups'),
              value: Text('1,204'),
              change: 8.1,
              description: Text('vs last month'),
            ),
          ),
        ),
        SizedBox(
          width: 196,
          child: PlCard(
            child: PlStat(
              label: Text('Churn'),
              value: Text('4.2%'),
              change: 2.6,
              improvesWhen: PlStatDirection.down,
              description: Text('vs last month'),
            ),
          ),
        ),
      ],
    );
  }
}
