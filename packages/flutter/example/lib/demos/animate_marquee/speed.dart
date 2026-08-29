import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateMarqueeSpeed extends StatelessWidget {
  const AnimateMarqueeSpeed({super.key});

  static const List<String> _words = <String>['one', 'two', 'three', 'four', 'five', 'six'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final double speed in <double>[30, 90])
            PlAnimateMarquee(
              speed: speed,
              gap: 16,
              children: <Widget>[
                for (final String word in _words) PlChip(child: Text('$word — $speed px/s')),
              ],
            ),
        ],
      ),
    );
  }
}
