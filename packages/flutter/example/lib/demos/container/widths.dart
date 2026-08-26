import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ContainerWidths extends StatelessWidget {
  const ContainerWidths({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 640,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final PlassSize width in PlassSize.values)
            PlContainer(
              maxWidth: width,
              padded: false,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.glassPress,
                  borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.sm]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: PlTypography(width.name, level: PlTypographyLevel.caption),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
