import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: PlImage(
        image: const NetworkImage('/samples/photos/hand-dyed-wool-yarn.webp'),
        semanticLabel: 'Skeins of hand-dyed wool in a basket',
        ratio: 1,
        rounded: true,
        size: PlassSize.lg,
        preview: true,
      ),
    );
  }
}
