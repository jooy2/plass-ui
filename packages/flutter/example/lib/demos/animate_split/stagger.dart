import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateSplitStagger extends StatefulWidget {
  const AnimateSplitStagger({super.key});

  @override
  State<AnimateSplitStagger> createState() => _AnimateSplitStaggerState();
}

class _AnimateSplitStaggerState extends State<AnimateSplitStagger> {
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
          key: ValueKey<String>('quick-$_run'),
          text: 'Forty milliseconds between words',
          stagger: const Duration(milliseconds: 40),
          style: style,
        ),
        PlAnimateSplit(
          key: ValueKey<String>('slow-$_run'),
          text: 'A hundred and sixty between words',
          stagger: const Duration(milliseconds: 160),
          style: style,
        ),
        PlAnimateSplit(
          key: ValueKey<String>('reverse-$_run'),
          text: 'From the last word back to the first',
          stagger: const Duration(milliseconds: 80),
          reverse: true,
          style: style,
        ),
      ],
    );
  }
}
