import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlComboboxOption<String>> _cities = <PlComboboxOption<String>>[
  PlComboboxOption<String>(value: 'seoul', label: 'Seoul'),
  PlComboboxOption<String>(value: 'lisbon', label: 'Lisbon'),
];

class ComboboxSizes extends StatelessWidget {
  const ComboboxSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final PlassSize size in PlassSize.values)
            PlCombobox<String>(
              fullWidth: true,
              size: size,
              placeholder: size.name,
              options: _cities,
              value: null,
              onChanged: (String? _) {},
            ),
        ],
      ),
    );
  }
}
