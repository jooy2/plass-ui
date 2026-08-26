import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class RadioGroupControlled extends StatefulWidget {
  const RadioGroupControlled({super.key});

  @override
  State<RadioGroupControlled> createState() => _RadioGroupControlledState();
}

class _RadioGroupControlledState extends State<RadioGroupControlled> {
  String _theme = 'system';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        PlRadioGroup<String>(
          label: const Text('Theme'),
          orientation: PlassOrientation.horizontal,
          value: _theme,
          onChanged: (String next) => setState(() => _theme = next),
          options: const <PlRadioOption<String>>[
            PlRadioOption<String>(value: 'light', label: Text('Light')),
            PlRadioOption<String>(value: 'dark', label: Text('Dark')),
            PlRadioOption<String>(value: 'system', label: Text('System')),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            PlButton(
              size: PlassSize.sm,
              variant: PlassVariant.glass,
              color: PlassColor.secondary,
              onPressed: () => setState(() => _theme = 'system'),
              child: const Text('Reset'),
            ),
            PlTypography('value: $_theme', level: PlTypographyLevel.caption),
          ],
        ),
      ],
    );
  }
}
