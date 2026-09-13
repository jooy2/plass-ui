import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ImageFit extends StatelessWidget {
  const ImageFit({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 600,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          for (final PlAspectFit fit in PlAspectFit.values)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  // A lone height fixes the box, and the column decides its width.
                  PlImage(
                    image: const NetworkImage('/samples/photos/alpine-lake-dawn.webp'),
                    semanticLabel: 'A still mountain lake at first light',
                    height: 160,
                    fit: fit,
                    rounded: true,
                  ),
                  Text(fit.name, style: TextStyle(color: tokens.mutedFg, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
