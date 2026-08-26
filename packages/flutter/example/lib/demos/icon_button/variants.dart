import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class IconButtonVariants extends StatelessWidget {
  const IconButtonVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final PlassVariant variant in PlassVariant.values)
          PlIconButton(
            variant: variant,
            icon: const PlusGlyph(),
            label: 'Add (${variant.name})',
            onPressed: () {},
          ),
      ],
    );
  }
}
