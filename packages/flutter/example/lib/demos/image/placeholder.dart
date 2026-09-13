import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ImagePlaceholder extends StatefulWidget {
  const ImagePlaceholder({super.key});

  @override
  State<ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<ImagePlaceholder> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          PlImage(
            // Nothing is asked for until the button is pressed, so the stand-in
            // stays up for as long as you want to look at it.
            image: _loaded
                ? const NetworkImage('/samples/photos/misty-tea-terraces-sunrise.webp')
                : const _NotAskedFor(),
            semanticLabel: 'Terraced tea fields under morning mist',
            ratio: 3 / 2,
            placeholder: const PlImagePlaceholder(
              image: NetworkImage('/samples/photos/misty-tea-terraces-sunrise-tiny.webp'),
              blur: 20,
            ),
            rounded: true,
          ),
          PlButton(
            variant: PlassVariant.glass,
            onPressed: () => setState(() => _loaded = !_loaded),
            child: Text(_loaded ? 'Show the stand-in again' : 'Load the picture'),
          ),
        ],
      ),
    );
  }
}

/// A picture that is never fetched, standing in for one that has not been
/// asked for yet.
class _NotAskedFor extends ImageProvider<_NotAskedFor> {
  const _NotAskedFor();

  @override
  Future<_NotAskedFor> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_NotAskedFor>(this);
  }

  @override
  ImageStreamCompleter loadImage(_NotAskedFor key, ImageDecoderCallback decode) {
    return _Waiting();
  }
}

class _Waiting extends ImageStreamCompleter {}
