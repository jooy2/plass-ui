import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ContainerCentered extends StatelessWidget {
  const ContainerCentered({super.key});

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
          for (final bool centered in <bool>[true, false])
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                PlTypography('centered: $centered', level: PlTypographyLevel.caption),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.glassPress,
                    borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.md]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: PlContainer(
                      maxWidth: PlassSize.xs,
                      centered: centered,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: tokens.glass,
                          borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.sm]!),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '480 logical pixels of content',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
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
