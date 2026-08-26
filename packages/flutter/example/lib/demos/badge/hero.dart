import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';
import 'package:plass_ui_example/demos/portrait.dart';

class BadgeHero extends StatelessWidget {
  const BadgeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 32,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlBadge(
          count: 4,
          label: '4 unread notifications',
          child: PlButton(
            variant: PlassVariant.glass,
            color: PlassColor.secondary,
            semanticLabel: 'Notifications',
            startIcon: const BellGlyph(),
            onPressed: () {},
          ),
        ),
        const PlBadge(
          dot: true,
          color: PlassColor.success,
          overlap: PlBadgeOverlap.circle,
          label: 'Online',
          child: PlAvatar(name: 'Ada Lovelace', image: PortraitImage(0)),
        ),
        const PlBadge(content: Text('Beta'), variant: PlassVariant.ghost, color: PlassColor.info),
      ],
    );
  }
}
