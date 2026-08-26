import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BadgeVariants extends StatelessWidget {
  const BadgeVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final variant in PlassVariant.values)
          PlBadge(variant: variant, content: Text(variant.name)),
      ],
    );
  }
}
