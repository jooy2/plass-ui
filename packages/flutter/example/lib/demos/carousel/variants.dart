import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CarouselVariants extends StatelessWidget {
  const CarouselVariants({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

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
                PlCarousel(
                  variant: variant,
                  label: variant.name,
                  value: 0,
                  indicators: false,
                  aspectRatio: 5,
                  children: <Widget>[
                    for (final String word in const <String>['One', 'Two', 'Three'])
                      ColoredBox(
                        color: tokens.family(PlassColor.primary).soft,
                        child: Center(child: Text(word)),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
