import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CardInteractive extends StatelessWidget {
  const CardInteractive({super.key});

  static const List<(String, String)> _plans = <(String, String)>[
    ('Starter', 'One project, one seat.'),
    ('Team', 'Shared projects and audit logs.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        for (final (String name, String blurb) in _plans)
          SizedBox(
            width: 248,
            // `onPressed` rather than `interactive`: this one is a real focus
            // stop, announced as a button and reachable from a keyboard.
            child: PlCard(
              onPressed: () {},
              semanticLabel: '$name plan',
              size: PlassSize.sm,
              title: Text(name),
              child: Text(blurb),
            ),
          ),
      ],
    );
  }
}
