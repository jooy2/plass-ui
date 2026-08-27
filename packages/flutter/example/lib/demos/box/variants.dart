import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BoxVariants extends StatelessWidget {
  const BoxVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final PlassVariant variant in PlassVariant.values)
            PlBox(
              variant: variant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: <Widget>[
                  PlTypography(variant.name, level: PlTypographyLevel.caption),
                  const PlTypography('The sheet is never dyed, whatever it is made of.'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
