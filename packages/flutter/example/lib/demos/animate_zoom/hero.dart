import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateZoomHero extends StatefulWidget {
  const AnimateZoomHero({super.key});

  @override
  State<AnimateZoomHero> createState() => _AnimateZoomHeroState();
}

class _AnimateZoomHeroState extends State<AnimateZoomHero> {
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
        PlAnimateZoom(
          key: ValueKey<int>(_run),
          duration: const Duration(milliseconds: 420),
          child: const SizedBox(
            width: 280,
            child: PlCard(
              size: PlassSize.sm,
              title: Text('Payment received'),
              child: PlTypography('£1,240.00', level: PlTypographyLevel.h3),
            ),
          ),
        ),
      ],
    );
  }
}
