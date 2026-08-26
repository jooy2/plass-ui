import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlRadioOption<String>> _pair = <PlRadioOption<String>>[
  PlRadioOption<String>(value: 'on', label: Text('Chosen')),
  PlRadioOption<String>(value: 'off', label: Text('Not chosen')),
];

class RadioGroupColors extends StatelessWidget {
  const RadioGroupColors({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 32,
      children: <Widget>[
        for (final color in <PlassColor>[
          PlassColor.primary,
          PlassColor.success,
          PlassColor.warning,
          PlassColor.danger,
        ])
          PlRadioGroup<String>(
            color: color,
            label: Text(color.name),
            options: _pair,
            value: 'on',
            onChanged: (String next) {},
          ),
      ],
    );
  }
}
