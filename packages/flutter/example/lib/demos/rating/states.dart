import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class RatingStates extends StatefulWidget {
  const RatingStates({super.key});

  @override
  State<RatingStates> createState() => _RatingStatesState();
}

class _RatingStatesState extends State<RatingStates> {
  double _score = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            PlRating(value: _score, onChanged: (double next) => setState(() => _score = next)),
            const PlTypography('interactive', level: PlTypographyLevel.caption),
          ],
        ),
        const Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            PlRating(value: 3.5, readOnly: true),
            PlTypography('readOnly', level: PlTypographyLevel.caption),
          ],
        ),
        const Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            PlRating(value: 3, disabled: true),
            PlTypography('disabled', level: PlTypographyLevel.caption),
          ],
        ),
      ],
    );
  }
}
