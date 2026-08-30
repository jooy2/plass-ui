import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlAvatar> people = <PlAvatar>[
  PlAvatar(name: 'Ada Lovelace'),
  PlAvatar(name: 'Grace Hopper'),
  PlAvatar(name: 'Katherine Johnson'),
  PlAvatar(name: 'Alan Turing'),
  PlAvatar(name: 'Jane Doe'),
];

class AvatarGroupMax extends StatelessWidget {
  const AvatarGroupMax({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        PlAvatarGroup(avatars: people),
        PlAvatarGroup(max: 3, avatars: people),
        PlAvatarGroup(max: 3, total: 128, avatars: people),
      ],
    );
  }
}
