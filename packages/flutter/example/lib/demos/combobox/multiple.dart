import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlComboboxOption<String>> _tags = <PlComboboxOption<String>>[
  PlComboboxOption<String>(value: 'bug', label: 'bug'),
  PlComboboxOption<String>(value: 'docs', label: 'documentation'),
  PlComboboxOption<String>(value: 'a11y', label: 'accessibility'),
  PlComboboxOption<String>(value: 'perf', label: 'performance'),
  PlComboboxOption<String>(value: 'design', label: 'design'),
];

class ComboboxMultiple extends StatefulWidget {
  const ComboboxMultiple({super.key});

  @override
  State<ComboboxMultiple> createState() => _ComboboxMultipleState();
}

class _ComboboxMultipleState extends State<ComboboxMultiple> {
  List<String> _values = <String>['a11y'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: PlCombobox<String>.multiple(
        fullWidth: true,
        label: const Text('Labels'),
        placeholder: 'Add a label…',
        options: _tags,
        values: _values,
        onChanged: (List<String> next) => setState(() => _values = next),
      ),
    );
  }
}
