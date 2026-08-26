import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class RatingAverage extends StatelessWidget {
  const RatingAverage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        for (final double score in <double>[4.3, 2.5, 0])
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              PlRating(value: score, readOnly: true),
              PlTypography('value: $score', level: PlTypographyLevel.caption),
            ],
          ),
      ],
    );
  }
}
