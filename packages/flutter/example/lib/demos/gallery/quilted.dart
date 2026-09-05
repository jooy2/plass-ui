import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/gallery/items.dart';

class GalleryQuilted extends StatelessWidget {
  const GalleryQuilted({super.key});

  @override
  Widget build(BuildContext context) {
    return PlGallery(
      items: <PlGalleryItem>[
        PlGalleryItem(
          id: photos[4].id,
          image: photos[4].image,
          semanticLabel: photos[4].semanticLabel,
          cols: 2,
          rows: 2,
        ),
        photos[1],
        photos[2],
        PlGalleryItem(
          id: photos[3].id,
          image: photos[3].image,
          semanticLabel: photos[3].semanticLabel,
          cols: 2,
        ),
        photos[5],
      ],
      layout: PlGalleryLayout.quilted,
      columns: const PlassResponsive<int>(2, md: 4),
      rowHeight: 110,
    );
  }
}
