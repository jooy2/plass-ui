import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class IconButtonColors extends StatelessWidget {
  const IconButtonColors({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final PlassColor color in PlassColor.values)
          PlIconButton(color: color, icon: const StarGlyph(), label: color.name, onPressed: () {}),
      ],
    );
  }
}
