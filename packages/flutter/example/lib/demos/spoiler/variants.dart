import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SpoilerVariants extends StatelessWidget {
  const SpoilerVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final PlassVariant variant in PlassVariant.values)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                PlTypography(variant.name, level: PlTypographyLevel.caption),
                PlSpoiler(
                  variant: variant,
                  child: const Text('The sheet is never dyed, whatever it is made of.'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
