import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/portrait.dart';

class AvatarHero extends StatelessWidget {
  const AvatarHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlAvatar(size: PlassSize.lg, name: 'Ada Lovelace', image: PortraitImage(0)),
        PlAvatar(size: PlassSize.lg, name: 'Jane Doe'),
        PlAvatar(
          size: PlassSize.lg,
          name: '홍길동',
          variant: PlassVariant.solid,
          color: PlassColor.info,
        ),
        PlAvatar(
          size: PlassSize.lg,
          shape: PlAvatarShape.square,
          variant: PlassVariant.glass,
          name: 'Plass UI',
          child: Text('P'),
        ),
        PlAvatar(size: PlassSize.lg),
      ],
    );
  }
}
