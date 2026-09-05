import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ImageWatermark extends StatelessWidget {
  const ImageWatermark({super.key});

  static const String _photo = '/samples/photos/rowboat-misty-pond-sunrise.webp';

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 420,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PlImage(
                  image: const NetworkImage(_photo),
                  semanticLabel: 'A rowboat moored on a misty pond',
                  ratio: 1,
                  rounded: true,
                  watermark: const PlImageWatermark('© Ada & Co'),
                ),
                const SizedBox(height: 8),
                Text(
                  'One mark, in the corner',
                  style: TextStyle(color: tokens.mutedFg, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PlImage(
                  image: const NetworkImage(_photo),
                  semanticLabel: 'A rowboat moored on a misty pond',
                  ratio: 1,
                  rounded: true,
                  watermark: const PlImageWatermark(
                    'PROOF — NOT FOR PRINT',
                    placement: PlImageWatermarkPlacement.tile,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'tile covers the whole picture',
                  style: TextStyle(color: tokens.mutedFg, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
