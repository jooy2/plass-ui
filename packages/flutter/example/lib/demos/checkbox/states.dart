import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/toggles.dart';

class CheckboxStates extends StatelessWidget {
  const CheckboxStates({super.key});

  @override
  Widget build(BuildContext context) {
    return Toggles(
      builder: (BuildContext context, ToggleState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            PlCheckbox(
              value: state['default'],
              onChanged: (bool next) => state.set('default', next),
              label: const Text('Default'),
            ),
            PlCheckbox(value: true, onChanged: (bool next) {}, label: const Text('Checked')),
            PlCheckbox(
              value: true,
              readOnly: true,
              onChanged: (bool next) {},
              label: const Text('Read-only'),
            ),
            const PlCheckbox(value: false, disabled: true, label: Text('Disabled')),
            const PlCheckbox(value: true, disabled: true, label: Text('Disabled and checked')),
            PlCheckbox(
              value: state['terms'],
              onChanged: (bool next) => state.set('terms', next),
              label: const Text('Accept the terms'),
              error: const Text('You have to accept them to continue.'),
            ),
          ],
        );
      },
    );
  }
}
