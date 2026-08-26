import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/toggles.dart';

const List<(String, String)> _rows = <(String, String)>[
  ('Two-factor authentication', 'Required for owners.'),
  ('Session alerts', 'Email me about new sign-ins.'),
  ('Public profile', 'Anyone with the link can see it.'),
];

class SwitchPlacement extends StatelessWidget {
  const SwitchPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return Toggles(
      initial: const <String, bool>{'Two-factor authentication': true, 'Session alerts': true},
      builder: (BuildContext context, ToggleState state) {
        return SizedBox(
          width: 384,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              for (final (String label, String description) in _rows)
                PlSwitch(
                  labelPlacement: PlassAlign.start,
                  value: state[label],
                  onChanged: (bool next) => state.set(label, next),
                  label: Text(label),
                  description: Text(description),
                ),
            ],
          ),
        );
      },
    );
  }
}
