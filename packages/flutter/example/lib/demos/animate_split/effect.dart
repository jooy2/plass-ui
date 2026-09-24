import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateSplitEffect extends StatefulWidget {
  const AnimateSplitEffect({super.key});

  @override
  State<AnimateSplitEffect> createState() => _AnimateSplitEffectState();
}

class _AnimateSplitEffectState extends State<AnimateSplitEffect> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final style = TextStyle(color: tokens.fg, fontSize: 20, fontWeight: FontWeight.w600);

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
        PlAnimateSplit(
          key: ValueKey<String>('bottom-$_run'),
          text: 'Every word rises from below',
          stagger: const Duration(milliseconds: 80),
          style: style,
        ),
        PlAnimateSplit(
          key: ValueKey<String>('left-$_run'),
          text: 'Every word comes in from the left',
          from: PlassSide.left,
          distance: 24,
          stagger: const Duration(milliseconds: 80),
          style: style,
        ),
        PlAnimateSplit(
          key: ValueKey<String>('solid-$_run'),
          text: 'Every word moves without fading',
          distance: 20,
          fade: false,
          stagger: const Duration(milliseconds: 80),
          style: style,
        ),
      ],
    );
  }
}
