import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlRadioOption<String>> _pair = <PlRadioOption<String>>[
  PlRadioOption<String>(value: 'a', label: Text('First')),
  PlRadioOption<String>(value: 'b', label: Text('Second')),
];

class RadioGroupSizes extends StatelessWidget {
  const RadioGroupSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 32,
      children: <Widget>[
        for (final size in <PlassSize>[PlassSize.sm, PlassSize.md, PlassSize.lg])
          PlRadioGroup<String>(
            size: size,
            label: Text('size: ${size.name}'),
            options: _pair,
            value: 'a',
            onChanged: (String next) {},
          ),
      ],
    );
  }
}
