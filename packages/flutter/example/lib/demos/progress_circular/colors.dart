import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressCircularColors extends StatelessWidget {
  const ProgressCircularColors({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final PlassColor color in PlassColor.values)
          PlProgressCircular(color: color, value: 70, label: Text(color.name)),
      ],
    );
  }
}
