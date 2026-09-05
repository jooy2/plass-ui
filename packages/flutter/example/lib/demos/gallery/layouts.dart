import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/gallery/items.dart';

class GalleryLayouts extends StatefulWidget {
  const GalleryLayouts({super.key});

  @override
  State<GalleryLayouts> createState() => _GalleryLayoutsState();
}

class _GalleryLayoutsState extends State<GalleryLayouts> {
  PlGalleryLayout _layout = PlGalleryLayout.justified;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PlSegmentedButton<PlGalleryLayout>(
          value: _layout,
          onChanged: (PlGalleryLayout next) => setState(() => _layout = next),
          segments: const <PlSegment<PlGalleryLayout>>[
            PlSegment<PlGalleryLayout>(value: PlGalleryLayout.grid, label: Text('grid')),
            PlSegment<PlGalleryLayout>(value: PlGalleryLayout.masonry, label: Text('masonry')),
            PlSegment<PlGalleryLayout>(value: PlGalleryLayout.justified, label: Text('justified')),
            PlSegment<PlGalleryLayout>(value: PlGalleryLayout.quilted, label: Text('quilted')),
          ],
        ),
        const SizedBox(height: 16),
        PlGallery(
          items: photos,
          layout: _layout,
          columns: const PlassResponsive<int>(2, md: 3),
          rowHeight: 140,
        ),
      ],
    );
  }
}
