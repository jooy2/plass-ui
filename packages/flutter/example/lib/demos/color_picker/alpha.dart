import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ColorPickerAlpha extends StatefulWidget {
  const ColorPickerAlpha({super.key});

  @override
  State<ColorPickerAlpha> createState() => _ColorPickerAlphaState();
}

class _ColorPickerAlphaState extends State<ColorPickerAlpha> {
  String _colour = 'rgba(59, 130, 246, 0.5)';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        PlColorPicker(
          inline: true,
          alpha: true,
          format: PlColorFormat.rgb,
          value: _colour,
          onValueChanged: (String next) => setState(() => _colour = next),
        ),
        Text(_colour),
      ],
    );
  }
}
