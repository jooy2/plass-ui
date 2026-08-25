import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonSizes extends StatelessWidget {
  const ButtonSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlButton(size: PlassSize.xs, onPressed: () {}, child: const Text('Extra small')),
        PlButton(size: PlassSize.sm, onPressed: () {}, child: const Text('Small')),
        PlButton(size: PlassSize.md, onPressed: () {}, child: const Text('Medium')),
        PlButton(size: PlassSize.lg, onPressed: () {}, child: const Text('Large')),
        PlButton(size: PlassSize.xl, onPressed: () {}, child: const Text('Extra large')),
      ],
    );
  }
}
