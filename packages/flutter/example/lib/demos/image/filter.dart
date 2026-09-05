import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ImageTreatments extends StatelessWidget {
  const ImageTreatments({super.key});

  static const List<PlImageFilter> _named = <PlImageFilter>[
    PlImageFilter.none,
    PlImageFilter.grayscale,
    PlImageFilter.sepia,
    PlImageFilter.desaturate,
  ];

  static const String _photo = '/samples/photos/rowboat-misty-pond-sunrise.webp';

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 520,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final PlImageFilter filter in _named) ...<Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  PlImage(
                    image: const NetworkImage(_photo),
                    semanticLabel: 'A rowboat moored on a misty pond',
                    ratio: 1,
                    filter: filter,
                    rounded: true,
                  ),
                  const SizedBox(height: 8),
                  Text(filter.name, style: TextStyle(color: tokens.mutedFg, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Any ColorFilter of your own, in place of a named one.
                PlImage(
                  image: const NetworkImage(_photo),
                  semanticLabel: 'A rowboat moored on a misty pond',
                  ratio: 1,
                  colorFilter: const ColorFilter.mode(Color(0x332F6FED), BlendMode.srcOver),
                  rounded: true,
                ),
                const SizedBox(height: 8),
                Text('A filter of your own', style: TextStyle(color: tokens.mutedFg, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
