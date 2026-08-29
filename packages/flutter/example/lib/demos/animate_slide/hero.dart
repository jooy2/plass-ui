import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateSlideHero extends StatefulWidget {
  const AnimateSlideHero({super.key});

  @override
  State<AnimateSlideHero> createState() => _AnimateSlideHeroState();
}

class _AnimateSlideHeroState extends State<AnimateSlideHero> {
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
          child: ClipRect(
            child: PlAnimateSlide(
              key: ValueKey<int>(_run),
              from: PlassSide.right,
              duration: const Duration(milliseconds: 520),
              child: const PlCard(
                size: PlassSize.sm,
                title: Text('New message'),
                child: Text('Ada replied to your review.'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
