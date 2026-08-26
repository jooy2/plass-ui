import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HotKeysSizes extends StatelessWidget {
  const HotKeysSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[for (final size in PlassSize.values) PlHotKeys(size: size, keys: 'Mod+K')],
    );
  }
}
