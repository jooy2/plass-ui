import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class IconButtonHero extends StatelessWidget {
  const IconButtonHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlIconButton(icon: const HeartGlyph(), label: 'Like', onPressed: () {}),
        PlIconButton(
          icon: const ShareGlyph(),
          label: 'Share',
          variant: PlassVariant.glass,
          onPressed: () {},
        ),
        PlIconButton(
          icon: const MoreGlyph(),
          label: 'More',
          variant: PlassVariant.ghost,
          color: PlassColor.secondary,
          onPressed: () {},
        ),
        PlIconButton(
          icon: const TrashGlyph(),
          label: 'Delete',
          variant: PlassVariant.glass,
          color: PlassColor.danger,
          onPressed: () {},
        ),
      ],
    );
  }
}
