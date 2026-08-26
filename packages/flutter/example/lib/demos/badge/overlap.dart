import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BadgeOverlap extends StatelessWidget {
  const BadgeOverlap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 32,
      runSpacing: 32,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlBadge(
          dot: true,
          color: PlassColor.success,
          label: 'Online',
          child: PlAvatar(size: PlassSize.lg, name: 'Ada Lovelace'),
        ),
        PlBadge(
          dot: true,
          color: PlassColor.success,
          overlap: PlBadgeOverlap.circle,
          label: 'Online',
          child: PlAvatar(size: PlassSize.lg, name: 'Ada Lovelace'),
        ),
      ],
    );
  }
}
