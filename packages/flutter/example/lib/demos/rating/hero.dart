import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class RatingHero extends StatefulWidget {
  const RatingHero({super.key});

  @override
  State<RatingHero> createState() => _RatingHeroState();
}

class _RatingHeroState extends State<RatingHero> {
  double _score = 4;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        PlRating(
          value: _score,
          size: PlassSize.lg,
          onChanged: (double next) => setState(() => _score = next),
        ),
        Text(
          PlRating.defaultValueLabel(_score, 5),
          style: TextStyle(fontSize: 14, color: tokens.mutedFg),
        ),
      ],
    );
  }
}
