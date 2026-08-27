import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlComboboxOption<String>> _frameworks = <PlComboboxOption<String>>[
  PlComboboxOption<String>(value: 'react', label: 'React'),
  PlComboboxOption<String>(value: 'vue', label: 'Vue'),
  PlComboboxOption<String>(value: 'svelte', label: 'Svelte'),
  PlComboboxOption<String>(value: 'solid', label: 'Solid'),
  PlComboboxOption<String>(value: 'angular', label: 'Angular'),
];

class ComboboxHero extends StatefulWidget {
  const ComboboxHero({super.key});

  @override
  State<ComboboxHero> createState() => _ComboboxHeroState();
}

class _ComboboxHeroState extends State<ComboboxHero> {
  String? _value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: PlCombobox<String>(
        fullWidth: true,
        label: const Text('Framework'),
        description: const Text('Type to filter, or add your own.'),
        placeholder: 'Search…',
        options: _frameworks,
        value: _value,
        onChanged: (String? next) => setState(() => _value = next),
        onCreate: (String query) => query,
      ),
    );
  }
}
