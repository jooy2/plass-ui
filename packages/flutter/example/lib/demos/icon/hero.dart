import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class IconHero extends StatelessWidget {
  const IconHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 24,
      runSpacing: 24,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlIcon(icon: BoltGlyph(), size: PlassSize.xl, color: PlassColor.warning, label: 'Fast'),
        PlIcon(icon: BoltGlyph(), size: PlassSize.lg, color: PlassColor.danger),
        PlIcon(icon: BoltGlyph(), color: PlassColor.primary),
        PlIcon(icon: BoltGlyph(), size: PlassSize.sm),
      ],
    );
  }
}
