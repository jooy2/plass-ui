import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AvatarShapes extends StatelessWidget {
  const AvatarShapes({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlAvatar(
          size: PlassSize.lg,
          name: 'Theo Quinn',
          image: NetworkImage('/samples/avatars/theo-quinn.webp'),
        ),
        PlAvatar(
          size: PlassSize.lg,
          shape: PlAvatarShape.square,
          name: 'Theo Quinn',
          image: NetworkImage('/samples/avatars/theo-quinn.webp'),
        ),
      ],
    );
  }
}
