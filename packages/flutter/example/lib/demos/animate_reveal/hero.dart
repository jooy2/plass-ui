import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateRevealHero extends StatefulWidget {
  const AnimateRevealHero({super.key});

  @override
  State<AnimateRevealHero> createState() => _AnimateRevealHeroState();
}

class _AnimateRevealHeroState extends State<AnimateRevealHero> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        PlButton(
          size: PlassSize.sm,
          variant: PlassVariant.glass,
          color: PlassColor.secondary,
          onPressed: () => setState(() => _run += 1),
          child: const Text('Play again'),
        ),
        SizedBox(
          width: 320,
          child: PlAnimateReveal(
            key: ValueKey<int>(_run),
            child: const PlTypography('Everything is where it was.', level: PlTypographyLevel.h3),
          ),
        ),
      ],
    );
  }
}
