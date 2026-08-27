import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlComboboxOption<String>> _cities = <PlComboboxOption<String>>[
  PlComboboxOption<String>(value: 'seoul', label: 'Seoul'),
  PlComboboxOption<String>(value: 'lisbon', label: 'Lisbon'),
  PlComboboxOption<String>(value: 'quito', label: 'Quito'),
];

class ComboboxCustom extends StatefulWidget {
  const ComboboxCustom({super.key});

  @override
  State<ComboboxCustom> createState() => _ComboboxCustomState();
}

class _ComboboxCustomState extends State<ComboboxCustom> {
  String? _open;
  String? _closed;

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
            label: const Text('Anything goes'),
            description: const Text('Type a city that is not listed.'),
            placeholder: 'Search…',
            options: _cities,
            value: _open,
            onChanged: (String? next) => setState(() => _open = next),
            onCreate: (String query) => query,
          ),
          PlCombobox<String>(
            fullWidth: true,
            label: const Text('A closed set'),
            description: const Text('Only these three.'),
            placeholder: 'Search…',
            options: _cities,
            value: _closed,
            onChanged: (String? next) => setState(() => _closed = next),
          ),
        ],
      ),
    );
  }
}
