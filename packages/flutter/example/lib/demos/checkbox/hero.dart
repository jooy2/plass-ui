import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/toggles.dart';

class CheckboxHero extends StatelessWidget {
  const CheckboxHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Toggles(
      initial: const <String, bool>{'releases': true},
      builder: (BuildContext context, ToggleState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            PlCheckbox(
              value: state['releases'],
              onChanged: (bool next) => state.set('releases', next),
              label: const Text('Email me about releases'),
            ),
            PlCheckbox(
              value: state['outages'],
              onChanged: (bool next) => state.set('outages', next),
              label: const Text('Email me about outages'),
              description: const Text('At most once a week.'),
            ),
            const PlCheckbox(
              value: false,
              disabled: true,
              label: Text('Email me about everything else'),
            ),
          ],
        );
      },
    );
  }
}
