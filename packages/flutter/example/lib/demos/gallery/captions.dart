import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/gallery/items.dart';

class GalleryCaptions extends StatelessWidget {
  const GalleryCaptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final PlGalleryCaption caption in <PlGalleryCaption>[
          PlGalleryCaption.below,
          PlGalleryCaption.overlay,
          PlGalleryCaption.hover,
        ]) ...<Widget>[
          PlTypography(caption.name, level: PlTypographyLevel.overline),
          const SizedBox(height: 8),
          PlGallery(
            items: photos.sublist(0, 3),
            columns: const PlassResponsive<int>(3),
            caption: caption,
            hover: PlGalleryHover.zoom,
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
