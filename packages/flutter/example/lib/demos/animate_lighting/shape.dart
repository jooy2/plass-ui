import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateLightingShape extends StatelessWidget {
  const AnimateLightingShape({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: <Widget>[
        PlAnimateLighting(arc: 18, blur: 6, child: PlBox(child: Text('a spark'))),
        PlAnimateLighting(child: PlBox(child: Text('the default'))),
        PlAnimateLighting(arc: 140, blur: 10, spread: 5, child: PlBox(child: Text('a sweep'))),
      ],
    );
  }
}
