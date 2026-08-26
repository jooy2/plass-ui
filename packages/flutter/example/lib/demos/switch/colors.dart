import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/toggles.dart';

class SwitchColors extends StatelessWidget {
  const SwitchColors({super.key});

  @override
  Widget build(BuildContext context) {
    return Toggles(
      initial: <String, bool>{for (final color in PlassColor.values) color.name: true},
      builder: (BuildContext context, ToggleState state) {
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: <Widget>[
            for (final color in PlassColor.values)
              PlSwitch(
                color: color,
                value: state[color.name],
                onChanged: (bool next) => state.set(color.name, next),
                label: Text(color.name),
              ),
          ],
        );
      },
    );
  }
}
