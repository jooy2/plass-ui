import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateRevealSides extends StatefulWidget {
  const AnimateRevealSides({super.key});

  @override
  State<AnimateRevealSides> createState() => _AnimateRevealSidesState();
}

class _AnimateRevealSidesState extends State<AnimateRevealSides> {
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            for (final PlassSide side in PlassSide.values)
              PlAnimateReveal(
                key: ValueKey<String>('${side.name}-$_run'),
                from: side,
                child: PlChip(child: Text(side.name)),
              ),
          ],
        ),
      ],
    );
  }
}
