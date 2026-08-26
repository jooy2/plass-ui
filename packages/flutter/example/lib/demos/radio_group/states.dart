import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class RadioGroupStates extends StatelessWidget {
  const RadioGroupStates({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 32,
      children: <Widget>[
        PlRadioGroup<String>(
          label: const Text('One option out'),
          value: 'card',
          onChanged: (String next) {},
          options: const <PlRadioOption<String>>[
            PlRadioOption<String>(value: 'card', label: Text('Card')),
            PlRadioOption<String>(value: 'transfer', label: Text('Bank transfer')),
            PlRadioOption<String>(
              value: 'invoice',
              label: Text('Invoice'),
              description: Text('Team plan only.'),
              disabled: true,
            ),
          ],
        ),
        PlRadioGroup<String>(
          label: const Text('Read-only'),
          readOnly: true,
          value: 'card',
          onChanged: (String next) {},
          options: const <PlRadioOption<String>>[
            PlRadioOption<String>(value: 'card', label: Text('Card')),
            PlRadioOption<String>(value: 'transfer', label: Text('Bank transfer')),
          ],
        ),
        PlRadioGroup<String>(
          label: const Text('Delivery'),
          error: const Text('Choose how it should arrive.'),
          value: null,
          onChanged: (String next) {},
          options: const <PlRadioOption<String>>[
            PlRadioOption<String>(value: 'standard', label: Text('Standard')),
            PlRadioOption<String>(value: 'express', label: Text('Express')),
          ],
        ),
      ],
    );
  }
}
