import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/portrait.dart';

class AvatarGroupHero extends StatelessWidget {
  const AvatarGroupHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlAvatarGroup(
      size: PlassSize.lg,
      max: 4,
      total: 11,
      avatars: <PlAvatar>[
        PlAvatar(name: 'Ada Lovelace', image: PortraitImage(0)),
        PlAvatar(name: 'Grace Hopper', image: PortraitImage(1)),
        PlAvatar(name: 'Katherine Johnson'),
        PlAvatar(name: '홍길동'),
        PlAvatar(name: 'Alan Turing'),
      ],
    );
  }
}
