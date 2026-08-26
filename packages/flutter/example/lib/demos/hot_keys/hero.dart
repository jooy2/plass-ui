import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HotKeysHero extends StatelessWidget {
  const HotKeysHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: <Widget>[
            PlTypography('Open the palette with'),
            PlHotKeys(keys: 'Mod+K'),
          ],
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: <Widget>[
            PlTypography('Save with'),
            PlHotKeys(keys: 'Mod+S'),
            PlTypography('and undo with'),
            PlHotKeys(keys: 'Mod+Z'),
          ],
        ),
      ],
    );
  }
}
