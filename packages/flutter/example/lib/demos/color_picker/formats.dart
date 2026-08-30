import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ColorPickerFormats extends StatelessWidget {
  const ColorPickerFormats({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        for (final PlColorFormat format in PlColorFormat.values)
          PlColorPicker(label: Text(format.name), format: format, value: '#22c55e'),
      ],
    );
  }
}
