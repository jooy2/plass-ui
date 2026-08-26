import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class IconButtonStates extends StatelessWidget {
  const IconButtonStates({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlIconButton(icon: const SaveGlyph(), label: 'Save', onPressed: () {}),
        PlIconButton(icon: const SaveGlyph(), label: 'Saving', loading: true, onPressed: () {}),
        PlIconButton(icon: const SaveGlyph(), label: 'Saved', readOnly: true, onPressed: () {}),
        PlIconButton(
          icon: const SaveGlyph(),
          label: 'Unavailable',
          disabled: true,
          onPressed: () {},
        ),
      ],
    );
  }
}
