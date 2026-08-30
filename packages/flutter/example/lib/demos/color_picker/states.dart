import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ColorPickerStates extends StatelessWidget {
  const ColorPickerStates({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        PlColorPicker(label: Text('Read-only'), readOnly: true, value: '#22c55e'),
        PlColorPicker(label: Text('Disabled'), disabled: true, value: '#22c55e'),
        PlColorPicker(
          label: Text('Invalid'),
          error: Text('Pick something darker'),
          value: '#fde68a',
        ),
      ],
    );
  }
}
