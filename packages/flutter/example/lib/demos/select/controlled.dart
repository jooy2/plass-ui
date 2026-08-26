import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlSelectOption<String>> _themes = <PlSelectOption<String>>[
  PlSelectOption<String>(value: 'light', label: Text('Light')),
  PlSelectOption<String>(value: 'dark', label: Text('Dark')),
  PlSelectOption<String>(value: 'system', label: Text('Follow the system')),
];

class SelectControlled extends StatefulWidget {
  const SelectControlled({super.key});

  @override
  State<SelectControlled> createState() => _SelectControlledState();
}

class _SelectControlledState extends State<SelectControlled> {
  String? _theme = 'system';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: <Widget>[
          PlSelect<String>(
            label: const Text('Theme'),
            options: _themes,
            value: _theme,
            onChanged: (String? next) => setState(() => _theme = next),
          ),
          PlButton(
            variant: PlassVariant.glass,
            color: PlassColor.secondary,
            onPressed: () => setState(() => _theme = 'system'),
            child: const Text('Reset'),
          ),
          PlTypography('value: $_theme', level: PlTypographyLevel.caption),
        ],
      ),
    );
  }
}
