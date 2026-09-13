import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ImageRotate extends StatelessWidget {
  const ImageRotate({super.key});

  static const List<int> _turns = <int>[0, 90, 180, 270];

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 520,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final int rotate in _turns) ...<Widget>[
            if (rotate > 0) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  PlImage(
                    image: const NetworkImage('/samples/photos/bicycle-coastal-path.webp'),
                    semanticLabel: 'A bicycle parked on a path above the sea',
                    rotate: rotate,
                    rounded: true,
                  ),
                  const SizedBox(height: 8),
                  Text('$rotate', style: TextStyle(color: tokens.mutedFg, fontSize: 12)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
