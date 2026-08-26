import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ChipVariants extends StatelessWidget {
  const ChipVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final variant in PlassVariant.values)
          PlChip(variant: variant, child: Text(variant.name)),
      ],
    );
  }
}
