import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class IconAnything extends StatelessWidget {
  const IconAnything({super.key});

  @override
  Widget build(BuildContext context) {
    return IconTheme.merge(
      data: IconThemeData(color: PlassTheme.of(context).fg),
      child: const Wrap(
        spacing: 24,
        runSpacing: 24,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          // A drawing that reads its size off the IconTheme, the way most sets do.
          PlIcon(icon: HeartGlyph(), size: PlassSize.lg),
          // A glyph from a font — an `Icon`, which does the same.
          PlIcon(
            icon: Icon(IconData(0x2665, fontFamily: 'Inter')),
            size: PlassSize.lg,
          ),
          // A bare character, sized by the box's own font size.
          PlIcon(icon: Text('★'), size: PlassSize.lg),
        ],
      ),
    );
  }
}
