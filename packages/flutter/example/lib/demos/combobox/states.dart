import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlComboboxOption<String>> _cities = <PlComboboxOption<String>>[
  PlComboboxOption<String>(value: 'seoul', label: 'Seoul'),
  PlComboboxOption<String>(value: 'lisbon', label: 'Lisbon'),
  PlComboboxOption<String>(value: 'quito', label: 'Quito', disabled: true),
];

class ComboboxStates extends StatelessWidget {
  const ComboboxStates({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          PlCombobox<String>(
            fullWidth: true,
            label: const Text('Error'),
            error: const Text('Pick a city.'),
            options: _cities,
            value: null,
            onChanged: (String? _) {},
          ),
          PlCombobox<String>(
            fullWidth: true,
            label: const Text('Read-only'),
            readOnly: true,
            options: _cities,
            value: 'seoul',
            onChanged: (String? _) {},
          ),
          PlCombobox<String>(
            fullWidth: true,
            label: const Text('Disabled'),
            disabled: true,
            options: _cities,
            value: 'seoul',
            onChanged: (String? _) {},
          ),
        ],
      ),
    );
  }
}
