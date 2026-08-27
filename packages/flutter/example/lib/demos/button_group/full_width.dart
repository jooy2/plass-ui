import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonGroupFullWidth extends StatelessWidget {
  const ButtonGroupFullWidth({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: PlButtonGroup(
        fullWidth: true,
        variant: PlassVariant.glass,
        color: PlassColor.secondary,
        children: <Widget>[
          PlButton(onPressed: () {}, child: const Text('Deny')),
          PlButton(onPressed: () {}, child: const Text('Ask')),
          PlButton(onPressed: () {}, child: const Text('Allow')),
        ],
      ),
    );
  }
}
