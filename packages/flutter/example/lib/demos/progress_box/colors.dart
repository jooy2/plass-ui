import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressBoxColors extends StatelessWidget {
  const ProgressBoxColors({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      children: <Widget>[
        for (final PlassColor color in PlassColor.values)
          PlProgressBox(color: color, label: Text(color.name), value: 65),
      ],
    );
  }
}
