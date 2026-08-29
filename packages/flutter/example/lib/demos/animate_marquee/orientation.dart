import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateMarqueeOrientation extends StatelessWidget {
  const AnimateMarqueeOrientation({super.key});

  static const List<String> _lines = <String>[
    'Deployed api-gateway',
    'Rotated a key',
    'Invited Ada',
    'Archived a project',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final bool reverse in <bool>[false, true])
          SizedBox(
            width: 220,
            height: 160,
            child: PlAnimateMarquee(
              orientation: PlassOrientation.vertical,
              reverse: reverse,
              gap: 12,
              speed: 30,
              children: <Widget>[
                for (final String line in _lines) PlBox(size: PlassSize.sm, child: Text(line)),
              ],
            ),
          ),
      ],
    );
  }
}
