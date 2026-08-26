import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class IconButtonSizes extends StatelessWidget {
  const IconButtonSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        for (final PlassSize size in PlassSize.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              PlIconButton(
                size: size,
                icon: const PlusGlyph(),
                label: 'Add (${size.name})',
                onPressed: () {},
              ),
              PlButton(
                size: size,
                variant: PlassVariant.glass,
                onPressed: () {},
                child: Text(size.name),
              ),
            ],
          ),
      ],
    );
  }
}
