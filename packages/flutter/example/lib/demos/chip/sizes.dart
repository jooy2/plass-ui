import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ChipSizes extends StatelessWidget {
  const ChipSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final size in PlassSize.values) PlChip(size: size, child: Text(size.name)),
      ],
    );
  }
}
