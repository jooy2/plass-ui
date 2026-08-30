import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ColorPickerInline extends StatelessWidget {
  const ColorPickerInline({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlColorPicker(
      inline: true,
      label: Text('Label colour'),
      description: Text('Chosen by eye, written as hex.'),
      value: '#8b5cf6',
    );
  }
}
