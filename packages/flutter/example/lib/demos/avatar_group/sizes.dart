import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AvatarGroupSizes extends StatelessWidget {
  const AvatarGroupSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final PlassSize size in PlassSize.values)
          PlAvatarGroup(
            size: size,
            avatars: const <PlAvatar>[
              PlAvatar(name: 'Ada Lovelace'),
              PlAvatar(name: 'Grace Hopper'),
              PlAvatar(name: 'Katherine Johnson'),
            ],
          ),
      ],
    );
  }
}
