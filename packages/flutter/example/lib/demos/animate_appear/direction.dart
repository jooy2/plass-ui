import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateAppearDirection extends StatefulWidget {
  const AnimateAppearDirection({super.key});

  @override
  State<AnimateAppearDirection> createState() => _AnimateAppearDirectionState();
}

class _AnimateAppearDirectionState extends State<AnimateAppearDirection> {
  static const List<String> _steps = <String>['Account', 'Verify', 'Profile'];

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
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 32,
          children: <Widget>[
            for (final bool reverse in <bool>[false, true])
              PlAnimateAppear(
                key: ValueKey<String>('$_run-$reverse'),
                reverse: reverse,
                from: PlassSide.left,
                distance: 20,
                spacing: 8,
                children: <Widget>[
                  for (final String step in _steps) PlBox(size: PlassSize.sm, child: Text(step)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
