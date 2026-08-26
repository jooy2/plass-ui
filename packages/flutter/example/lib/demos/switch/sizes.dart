import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/toggles.dart';

class SwitchSizes extends StatelessWidget {
  const SwitchSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Toggles(
      initial: <String, bool>{for (final size in PlassSize.values) size.name: true},
      builder: (BuildContext context, ToggleState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            for (final size in PlassSize.values)
              PlSwitch(
                size: size,
                value: state[size.name],
                onChanged: (bool next) => state.set(size.name, next),
                label: Text('size: ${size.name}'),
              ),
          ],
        );
      },
    );
  }
}
