import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateAppearStagger extends StatefulWidget {
  const AnimateAppearStagger({super.key});

  @override
  State<AnimateAppearStagger> createState() => _AnimateAppearStaggerState();
}

class _AnimateAppearStaggerState extends State<AnimateAppearStagger> {
  static const List<String> _words = <String>['one', 'two', 'three', 'four', 'five'];

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
        for (final int stagger in <int>[40, 140])
          PlAnimateAppear(
            key: ValueKey<String>('$_run-$stagger'),
            orientation: PlassOrientation.horizontal,
            spacing: 8,
            stagger: Duration(milliseconds: stagger),
            children: <Widget>[for (final String word in _words) PlChip(child: Text(word))],
          ),
      ],
    );
  }
}
