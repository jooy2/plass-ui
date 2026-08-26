import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ChipColors extends StatelessWidget {
  const ChipColors({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final color in PlassColor.values) PlChip(color: color, child: Text(color.name)),
      ],
    );
  }
}
