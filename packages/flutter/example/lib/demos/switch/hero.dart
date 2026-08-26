import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/toggles.dart';

class SwitchHero extends StatelessWidget {
  const SwitchHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Toggles(
      initial: const <String, bool>{'dark': true},
      builder: (BuildContext context, ToggleState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            PlSwitch(
              value: state['dark'],
              onChanged: (bool next) => state.set('dark', next),
              label: const Text('Dark mode'),
            ),
            PlSwitch(
              value: state['crash'],
              onChanged: (bool next) => state.set('crash', next),
              label: const Text('Send crash reports'),
              description: const Text('Nothing personal leaves the device.'),
            ),
            const PlSwitch(value: false, disabled: true, label: Text('Beta features')),
          ],
        );
      },
    );
  }
}
