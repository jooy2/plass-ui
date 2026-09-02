import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class StackDeck extends StatelessWidget {
  const StackDeck({super.key});

  @override
  Widget build(BuildContext context) {
    return PlStack(
      direction: PlStackDirection.diagonal,
      front: PlStackFront.first,
      overlap: 200,
      drop: 14,
      scaleStep: 0.96,
      opacityStep: 0.85,
      children: <Widget>[
        for (final String title in <String>['Invoice 1041', 'Invoice 1040', 'Invoice 1039'])
          SizedBox(
            width: 224,
            child: PlCard(
              size: PlassSize.sm,
              title: Text(title),
              child: const Text('Due at the end of the month.'),
            ),
          ),
      ],
    );
  }
}
