import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/portrait.dart';

class AvatarShapes extends StatelessWidget {
  const AvatarShapes({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlAvatar(size: PlassSize.lg, name: 'Ada Lovelace', image: PortraitImage(1)),
        PlAvatar(
          size: PlassSize.lg,
          shape: PlAvatarShape.square,
          name: 'Ada Lovelace',
          image: PortraitImage(1),
        ),
      ],
    );
  }
}
