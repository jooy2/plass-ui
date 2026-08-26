import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/toggles.dart';

class SwitchStates extends StatelessWidget {
  const SwitchStates({super.key});

  @override
  Widget build(BuildContext context) {
    return Toggles(
      builder: (BuildContext context, ToggleState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            PlSwitch(
              value: state['off'],
              onChanged: (bool next) => state.set('off', next),
              label: const Text('Off'),
            ),
            PlSwitch(value: true, onChanged: (bool next) {}, label: const Text('On')),
            PlSwitch(
              value: true,
              readOnly: true,
              onChanged: (bool next) {},
              label: const Text('Read-only'),
            ),
            const PlSwitch(value: false, disabled: true, label: Text('Disabled')),
            const PlSwitch(value: true, disabled: true, label: Text('Disabled and on')),
          ],
        );
      },
    );
  }
}
