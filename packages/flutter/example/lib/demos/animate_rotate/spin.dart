import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateRotateSpin extends StatelessWidget {
  const AnimateRotateSpin({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 40,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: <Widget>[
        PlAnimateRotate(
          from: -90,
          duration: Duration(milliseconds: 1600),
          repeat: null,
          alternate: true,
          child: PlChip(color: PlassColor.primary, child: Text('an arrival')),
        ),
        PlAnimateRotate(
          from: 0,
          to: 360,
          duration: Duration(milliseconds: 3000),
          curve: Curves.linear,
          repeat: null,
          fade: false,
          child: PlChip(color: PlassColor.secondary, child: Text('a spin')),
        ),
      ],
    );
  }
}
