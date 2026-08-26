import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/portrait.dart';

class AspectRatioFit extends StatelessWidget {
  const AspectRatioFit({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          for (final PlAspectFit fit in PlAspectFit.values)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: <Widget>[
                  PlAspectRatio(
                    ratio: 4 / 3,
                    fit: fit,
                    rounded: true,
                    child: const Image(image: PortraitImage(0)),
                  ),
                  PlTypography(fit.name, level: PlTypographyLevel.caption),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
