import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlAvatar> people = <PlAvatar>[
  PlAvatar(name: 'Ada Lovelace'),
  PlAvatar(name: 'Grace Hopper'),
  PlAvatar(name: 'Katherine Johnson'),
];

class AvatarGroupOverlap extends StatelessWidget {
  const AvatarGroupOverlap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        PlAvatarGroup(avatars: people),
        PlAvatarGroup(overlap: 0, avatars: people),
        PlAvatarGroup(overlap: 24, avatars: people),
      ],
    );
  }
}
