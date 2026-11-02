import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AspectRatioFit extends StatelessWidget {
  const AspectRatioFit({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: <Widget>[
          for (final PlAspectFit fit in PlAspectFit.values)
            SizedBox(
              width: 88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: <Widget>[
                  PlAspectRatio(
                    ratio: 4 / 3,
                    fit: fit,
                    rounded: true,
                    child: const Image(
                      image: NetworkImage(
                        'https://plass.cdget.com/samples/photos/lighthouse-cliff-wildflowers.webp',
                      ),
                    ),
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
