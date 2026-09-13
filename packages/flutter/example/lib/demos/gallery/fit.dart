import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/gallery/items.dart';

class GalleryFit extends StatelessWidget {
  const GalleryFit({super.key});

  @override
  Widget build(BuildContext context) {
    final PlGalleryItem stored = photos[1];

    return PlGallery(
      items: <PlGalleryItem>[
        photos[0],
        // The second picture was stored on its side, so it is turned back up.
        PlGalleryItem(
          id: stored.id,
          image: stored.image,
          semanticLabel: stored.semanticLabel,
          ratio: stored.ratio,
          rotate: 90,
        ),
        ...photos.skip(2),
      ],
      columns: const PlassResponsive<int>(2, sm: 3),
      fit: PlAspectFit.contain,
      letterbox: PlImageLetterbox.blur,
    );
  }
}
