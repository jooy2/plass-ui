import 'package:flutter/widgets.dart';
import 'package:plass_showcase/app/page.dart';
import 'package:plass_showcase/data/sample.dart';
import 'package:plass_ui/plass_ui.dart';

/// Pictures in every shape the library draws them.
class MediaScreen extends StatefulWidget {
  /// Creates the screen.
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  int _slide = 0;

  @override
  Widget build(BuildContext context) {
    return PushedScreen(
      title: 'Media',
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.paddingOf(context).bottom + 24),
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: contentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: <Widget>[
                  PlCarousel(
                    label: 'Places',
                    value: _slide,
                    aspectRatio: 16 / 9,
                    onChanged: (int next) => setState(() => _slide = next),
                    children: <Widget>[
                      for (final (String asset, String label) in photos.take(4))
                        Image(image: AssetImage(asset), fit: BoxFit.cover, semanticLabel: label),
                    ],
                  ),
                  PlCard(
                    title: const Text('Gallery'),
                    child: PlGallery(
                      items: <PlGalleryItem>[
                        for (final (String asset, String label) in photos)
                          PlGalleryItem(
                            image: AssetImage(asset),
                            semanticLabel: label,
                            title: label,
                          ),
                      ],
                      layout: PlGalleryLayout.masonry,
                      columns: const PlassResponsive<int>(2, md: 3),
                      preview: true,
                    ),
                  ),
                  PlCard(
                    title: const Text('Image'),
                    child: PlImage(
                      image: AssetImage(photos[1].$1),
                      semanticLabel: photos[1].$2,
                      ratio: 16 / 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
