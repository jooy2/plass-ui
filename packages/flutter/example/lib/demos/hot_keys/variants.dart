import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HotKeysVariants extends StatelessWidget {
  const HotKeysVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final variant in PlassVariant.values) PlHotKeys(variant: variant, keys: 'Mod+K'),
      ],
    );
  }
}
