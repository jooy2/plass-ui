import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class IconSizes extends StatelessWidget {
  const IconSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        for (final size in PlassSize.values)
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: <Widget>[
              PlIcon(icon: const BellGlyph(), size: size),
              PlTypography(size.name, level: PlTypographyLevel.caption),
            ],
          ),
      ],
    );
  }
}
