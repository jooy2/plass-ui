import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/gallery/items.dart';

class GalleryHero extends StatelessWidget {
  const GalleryHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlGallery(
      items: photos,
      layout: PlGalleryLayout.masonry,
      columns: const PlassResponsive<int>(2, md: 3),
      caption: PlGalleryCaption.hover,
      preview: true,
    );
  }
}
