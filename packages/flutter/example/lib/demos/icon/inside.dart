import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class IconInside extends StatelessWidget {
  const IconInside({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          // No PlIcon here: the button sizes the glyph itself, at 1.2× its
          // label, through the IconTheme it sets.
          PlButton(startIcon: const BoltGlyph(), onPressed: () {}, child: const Text('Deploy now')),
          // And here it is at a fixed size instead, which is what PlIcon is for.
          const PlAlert(
            color: PlassColor.warning,
            icon: PlIcon(icon: BoltGlyph(), size: PlassSize.sm),
            child: Text('The build is running on the fast queue.'),
          ),
          DefaultTextStyle.merge(
            style: TextStyle(color: PlassTheme.of(context).mutedFg),
            child: const Row(
              spacing: 6,
              children: <Widget>[
                PlIcon(icon: BoltGlyph(), size: PlassSize.xs),
                PlTypography('Sits in a sentence at the sentence’s own colour.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
