import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ContainerPadding extends StatelessWidget {
  const ContainerPadding({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final PlassDensity density in PlassDensity.values)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                PlTypography(density.name, level: PlTypographyLevel.caption),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.glassPress,
                    borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.md]!),
                  ),
                  child: PlContainer(
                    density: density,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: tokens.glass,
                        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.sm]!),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'the gutter is outside this',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
