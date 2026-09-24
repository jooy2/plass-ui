import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateSplitBy extends StatefulWidget {
  const AnimateSplitBy({super.key});

  @override
  State<AnimateSplitBy> createState() => _AnimateSplitByState();
}

class _AnimateSplitByState extends State<AnimateSplitBy> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final style = TextStyle(color: tokens.fg, fontSize: 24, fontWeight: FontWeight.w600);

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
          key: ValueKey<String>('word-$_run'),
          text: 'Cut into words',
          stagger: const Duration(milliseconds: 90),
          style: style,
        ),
        PlAnimateSplit(
          key: ValueKey<String>('character-$_run'),
          text: 'Cut into characters',
          by: PlAnimateSplitBy.character,
          stagger: const Duration(milliseconds: 30),
          style: style,
        ),
      ],
    );
  }
}
