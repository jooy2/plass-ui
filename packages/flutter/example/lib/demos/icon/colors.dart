import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class IconColors extends StatelessWidget {
  const IconColors({super.key});

  @override
  Widget build(BuildContext context) {
    return IconTheme.merge(
      // The colour an inheriting icon inherits — here the muted foreground, the
      // way it would inside a caption.
      data: IconThemeData(color: PlassTheme.of(context).mutedFg),
      child: const Wrap(
        spacing: 24,
        runSpacing: 24,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          PlIcon(icon: BoltGlyph()),
          PlIcon(icon: BoltGlyph(), color: PlassColor.primary),
          PlIcon(icon: BoltGlyph(), color: PlassColor.secondary),
          PlIcon(icon: BoltGlyph(), color: PlassColor.success),
          PlIcon(icon: BoltGlyph(), color: PlassColor.warning),
          PlIcon(icon: BoltGlyph(), color: PlassColor.danger),
          PlIcon(icon: BoltGlyph(), color: PlassColor.info),
        ],
      ),
    );
  }
}
