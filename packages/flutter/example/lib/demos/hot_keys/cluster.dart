import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HotKeysCluster extends StatelessWidget {
  const HotKeysCluster({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 32,
      runSpacing: 32,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        PlHotKeys(
          cluster: PlHotKeysCluster(up: 'W', left: 'A', down: 'S', right: 'D'),
        ),
        PlHotKeys(
          cluster: PlHotKeysCluster(up: '↑', left: '←', down: '↓', right: '→'),
        ),
      ],
    );
  }
}
