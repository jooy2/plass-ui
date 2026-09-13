import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ImageFlip extends StatelessWidget {
  const ImageFlip({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 520,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final PlImageFlip flip in PlImageFlip.values) ...<Widget>[
            if (flip != PlImageFlip.none) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  PlImage(
                    image: const NetworkImage('/samples/photos/rowboat-misty-pond-sunrise.webp'),
                    semanticLabel: 'A rowboat moored on a misty pond',
                    ratio: 3 / 2,
                    flip: flip,
                    rounded: true,
                  ),
                  const SizedBox(height: 8),
                  Text(flip.name, style: TextStyle(color: tokens.mutedFg, fontSize: 12)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
