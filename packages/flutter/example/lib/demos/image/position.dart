import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ImagePosition extends StatelessWidget {
  const ImagePosition({super.key});

  static const Map<String, Alignment> _positions = <String, Alignment>{
    'topCenter': Alignment.topCenter,
    'center': Alignment.center,
    'bottomCenter': Alignment.bottomCenter,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 520,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          for (final MapEntry<String, Alignment> entry in _positions.entries)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  // A tall photograph in a wide box, so the crop has to choose.
                  PlImage(
                    image: const NetworkImage('/samples/photos/lighthouse-cliff-wildflowers.webp'),
                    semanticLabel: 'A lighthouse on a clifftop above wildflowers',
                    ratio: 4 / 3,
                    position: entry.value,
                    rounded: true,
                  ),
                  Text(entry.key, style: TextStyle(color: tokens.mutedFg, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
