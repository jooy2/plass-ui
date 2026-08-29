import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateTypingSpeed extends StatefulWidget {
  const AnimateTypingSpeed({super.key});

  @override
  State<AnimateTypingSpeed> createState() => _AnimateTypingSpeedState();
}

class _AnimateTypingSpeedState extends State<AnimateTypingSpeed> {
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
        DefaultTextStyle(
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: <Widget>[
              for (final double speed in <double>[8, 24, 60])
                PlAnimateTyping(
                  '$speed characters a second',
                  key: ValueKey<String>('$_run-$speed'),
                  speed: speed,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
