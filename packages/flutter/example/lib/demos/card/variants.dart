import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CardVariants extends StatelessWidget {
  const CardVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        for (final variant in PlassVariant.values)
          SizedBox(
            width: 200,
            child: PlCard(
              variant: variant,
              size: PlassSize.sm,
              title: Text(variant.name),
              child: Text('The sheet is ${variant.name}.'),
            ),
          ),
      ],
    );
  }
}
