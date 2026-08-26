import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlSelectOption<String>> _cadences = <PlSelectOption<String>>[
  PlSelectOption<String>(value: 'daily', label: Text('Daily')),
  PlSelectOption<String>(value: 'weekly', label: Text('Weekly')),
  PlSelectOption<String>(value: 'never', label: Text('Never'), disabled: true),
];

class SelectStates extends StatefulWidget {
  const SelectStates({super.key});

  @override
  State<SelectStates> createState() => _SelectStatesState();
}

class _SelectStatesState extends State<SelectStates> {
  String? _plain = 'weekly';
  String? _invalid;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: <Widget>[
          PlSelect<String>(
            label: const Text('Default'),
            options: _cadences,
            value: _plain,
            onChanged: (String? next) => setState(() => _plain = next),
          ),
          const PlSelect<String>(
            label: Text('Read-only'),
            readOnly: true,
            options: _cadences,
            value: 'weekly',
          ),
          const PlSelect<String>(
            label: Text('Disabled'),
            disabled: true,
            options: _cadences,
            value: 'weekly',
          ),
          PlSelect<String>(
            label: const Text('Invalid'),
            placeholder: const Text('Choose'),
            error: const Text('Pick a cadence.'),
            options: _cadences,
            value: _invalid,
            onChanged: (String? next) => setState(() => _invalid = next),
          ),
        ],
      ),
    );
  }
}
