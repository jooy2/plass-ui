import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ImageHero extends StatelessWidget {
  const ImageHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 420,
      child: Row(
        children: <Widget>[
          Expanded(
            child: PlImage(
              image: NetworkImage('/samples/photos/alpine-lake-dawn.webp'),
              semanticLabel: 'A still mountain lake at first light',
              ratio: 4 / 3,
              rounded: true,
              size: PlassSize.lg,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: PlImage(
              image: NetworkImage('/samples/photos/forest-trail-sunbeams.webp'),
              semanticLabel: 'Sunbeams across a forest trail',
              ratio: 4 / 3,
              rounded: true,
              size: PlassSize.lg,
            ),
          ),
        ],
      ),
    );
  }
}
