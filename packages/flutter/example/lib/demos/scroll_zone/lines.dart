import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<String> _teams = <String>[
  'Design',
  'Engineering',
  'Research',
  'Marketing',
  'Support',
  'Finance',
  'Legal',
  'People',
  'Security',
  'Data',
  'Sales',
  'Operations',
];

class ScrollZoneLines extends StatelessWidget {
  const ScrollZoneLines({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          PlScrollZone(
            label: 'Teams, one line',
            children: <Widget>[for (final String team in _teams) PlChip(child: Text(team))],
          ),
          PlScrollZone(
            label: 'Teams, two lines',
            lines: 2,
            children: <Widget>[
              for (final String team in _teams)
                PlChip(color: PlassColor.secondary, child: Text(team)),
            ],
          ),
        ],
      ),
    );
  }
}
