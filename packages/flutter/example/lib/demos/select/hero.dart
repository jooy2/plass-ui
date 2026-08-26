import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlSelectOption<String>> _cities = <PlSelectOption<String>>[
  PlSelectOption<String>(value: 'seoul', label: Text('Seoul')),
  PlSelectOption<String>(value: 'lisbon', label: Text('Lisbon')),
  PlSelectOption<String>(value: 'quito', label: Text('Quito')),
  PlSelectOption<String>(value: 'reykjavik', label: Text('Reykjavík')),
];

class SelectHero extends StatefulWidget {
  const SelectHero({super.key});

  @override
  State<SelectHero> createState() => _SelectHeroState();
}

class _SelectHeroState extends State<SelectHero> {
  String? _city = 'lisbon';

  @override
  Widget build(BuildContext context) {
    // Room under the trigger for the list to drop into.
    return SizedBox(
      width: 320,
      height: 260,
      child: PlSelect<String>(
        fullWidth: true,
        label: const Text('City'),
        description: const Text('Where the team sits.'),
        placeholder: const Text('Pick a city'),
        options: _cities,
        value: _city,
        onChanged: (String? next) => setState(() => _city = next),
      ),
    );
  }
}
