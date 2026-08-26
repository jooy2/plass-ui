import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class RatingPrecision extends StatefulWidget {
  const RatingPrecision({super.key});

  @override
  State<RatingPrecision> createState() => _RatingPrecisionState();
}

class _RatingPrecisionState extends State<RatingPrecision> {
  final Map<double, double> _scores = <double, double>{1: 3, 0.5: 3, 0.25: 3};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        for (final double precision in _scores.keys)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              PlRating(
                value: _scores[precision]!,
                precision: precision,
                onChanged: (double next) => setState(() => _scores[precision] = next),
              ),
              PlTypography('precision: $precision', level: PlTypographyLevel.caption),
            ],
          ),
      ],
    );
  }
}
