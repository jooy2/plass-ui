import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonGroupOrientation extends StatelessWidget {
  const ButtonGroupOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return PlButtonGroup(
      orientation: PlassOrientation.vertical,
      variant: PlassVariant.glass,
      color: PlassColor.secondary,
      children: <Widget>[
        PlButton(onPressed: () {}, child: const Text('Rename')),
        PlButton(onPressed: () {}, child: const Text('Duplicate')),
        PlButton(color: PlassColor.danger, onPressed: () {}, child: const Text('Delete')),
      ],
    );
  }
}
