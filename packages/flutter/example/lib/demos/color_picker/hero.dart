import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ColorPickerHero extends StatefulWidget {
  const ColorPickerHero({super.key});

  @override
  State<ColorPickerHero> createState() => _ColorPickerHeroState();
}

class _ColorPickerHeroState extends State<ColorPickerHero> {
  String _colour = '#1a58d1';

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        PlColorPicker(
          label: const Text('Project colour'),
          value: _colour,
          clearable: true,
          onValueChanged: (String next) => setState(() => _colour = next),
        ),
        Text(
          _colour.isEmpty ? 'Nothing chosen' : _colour,
          style: TextStyle(fontSize: 12, color: tokens.mutedFg),
        ),
      ],
    );
  }
}
