import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AvatarGroupVariants extends StatelessWidget {
  const AvatarGroupVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlAvatarGroup(
      variant: PlassVariant.glass,
      color: PlassColor.info,
      avatars: <PlAvatar>[
        PlAvatar(name: 'Ada Lovelace'),
        PlAvatar(name: 'Grace Hopper'),
        PlAvatar(name: 'On call', variant: PlassVariant.solid, color: PlassColor.danger),
        PlAvatar(name: 'Katherine Johnson'),
      ],
    );
  }
}
