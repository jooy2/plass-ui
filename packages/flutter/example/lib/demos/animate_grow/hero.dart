import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateGrowHero extends StatefulWidget {
  const AnimateGrowHero({super.key});

  @override
  State<AnimateGrowHero> createState() => _AnimateGrowHeroState();
}

class _AnimateGrowHeroState extends State<AnimateGrowHero> {
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
        PlAnimateGrow(
          key: ValueKey<int>(_run),
          duration: const Duration(milliseconds: 520),
          child: const SizedBox(
            width: 300,
            child: PlCard(
              size: PlassSize.sm,
              title: Text('Filters'),
              child: Text('Three of nine rows match.'),
            ),
          ),
        ),
      ],
    );
  }
}
