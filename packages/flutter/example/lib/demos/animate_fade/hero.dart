import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateFadeHero extends StatefulWidget {
  const AnimateFadeHero({super.key});

  @override
  State<AnimateFadeHero> createState() => _AnimateFadeHeroState();
}

class _AnimateFadeHeroState extends State<AnimateFadeHero> {
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
        PlAnimateFade(
          key: ValueKey<int>(_run),
          duration: const Duration(milliseconds: 700),
          child: const SizedBox(
            width: 320,
            child: PlCard(
              size: PlassSize.sm,
              title: Text('Deployment finished'),
              child: Text('Two services restarted, no errors.'),
            ),
          ),
        ),
      ],
    );
  }
}
