import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class RatingColors extends StatelessWidget {
  const RatingColors({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        for (final PlassColor color in <PlassColor>[
          PlassColor.warning,
          PlassColor.primary,
          PlassColor.danger,
          PlassColor.success,
        ])
          PlRating(value: 4, color: color, readOnly: true),
      ],
    );
  }
}
