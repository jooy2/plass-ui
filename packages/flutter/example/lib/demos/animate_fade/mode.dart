import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateFadeMode extends StatelessWidget {
  const AnimateFadeMode({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        PlAnimateFade(
          duration: Duration(milliseconds: 1200),
          repeat: null,
          alternate: true,
          child: PlChip(color: PlassColor.success, child: Text('enter')),
        ),
        PlAnimateFade(
          mode: PlassAnimateMode.exit,
          duration: Duration(milliseconds: 1200),
          repeat: null,
          alternate: true,
          child: PlChip(color: PlassColor.danger, child: Text('exit')),
        ),
      ],
    );
  }
}
