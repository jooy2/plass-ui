import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateBlinkCount extends StatefulWidget {
  const AnimateBlinkCount({super.key});

  @override
  State<AnimateBlinkCount> createState() => _AnimateBlinkCountState();
}

class _AnimateBlinkCountState extends State<AnimateBlinkCount> {
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
          child: const Text('Draw attention to it'),
        ),
        PlAnimateBlink(
          key: ValueKey<int>(_run),
          repeat: 3,
          min: 0.25,
          duration: const Duration(milliseconds: 600),
          child: const PlBox(
            size: PlassSize.sm,
            color: PlassColor.warning,
            child: Text('Two fields still need an answer.'),
          ),
        ),
      ],
    );
  }
}
