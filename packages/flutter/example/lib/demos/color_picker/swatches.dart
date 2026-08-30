import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<String> _brand = <String>[
  '#0f172a',
  '#1a58d1',
  '#0ea5e9',
  '#10b981',
  '#f59e0b',
  '#ef4444',
];

class ColorPickerSwatches extends StatelessWidget {
  const ColorPickerSwatches({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 24,
      runSpacing: 24,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        PlColorPicker(
          inline: true,
          size: PlassSize.sm,
          label: Text('Brand only'),
          swatches: _brand,
          value: '#1a58d1',
        ),
        PlColorPicker(
          inline: true,
          size: PlassSize.sm,
          label: Text('No swatches'),
          swatches: <String>[],
          value: '#1a58d1',
        ),
      ],
    );
  }
}
