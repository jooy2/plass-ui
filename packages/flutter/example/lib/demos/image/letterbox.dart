import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ImageLetterbox extends StatelessWidget {
  const ImageLetterbox({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final Map<String, PlImageLetterbox?> letterboxes = <String, PlImageLetterbox?>{
      'null': null,
      'A decoration': PlImageLetterbox(
        BoxDecoration(color: tokens.family(PlassColor.primary).soft),
      ),
      'blur': PlImageLetterbox.blur,
    };

    return SizedBox(
      width: 560,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          for (final MapEntry<String, PlImageLetterbox?> entry in letterboxes.entries)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  // A tall photograph in a wide box, fitted whole.
                  PlImage(
                    image: const NetworkImage('/samples/photos/greenhouse-fern-shadows.webp'),
                    semanticLabel: 'Ferns throwing shadows across a greenhouse wall',
                    ratio: 3 / 2,
                    fit: PlAspectFit.contain,
                    letterbox: entry.value,
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
