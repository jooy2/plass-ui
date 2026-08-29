import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateHeadlineControlled extends StatefulWidget {
  const AnimateHeadlineControlled({super.key});

  @override
  State<AnimateHeadlineControlled> createState() => _AnimateHeadlineControlledState();
}

class _AnimateHeadlineControlledState extends State<AnimateHeadlineControlled> {
  static const List<String> _steps = <String>[
    'Create an account',
    'Confirm your email',
    'Invite your team',
  ];

  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        PlSegmentedButton<int>(
          size: PlassSize.sm,
          value: _step,
          onChanged: (int next) => setState(() => _step = next),
          segments: const <PlSegment<int>>[
            PlSegment<int>(value: 0, label: Text('1')),
            PlSegment<int>(value: 1, label: Text('2')),
            PlSegment<int>(value: 2, label: Text('3')),
          ],
        ),
        PlAnimateHeadline(
          index: _step,
          children: <Widget>[
            for (final String step in _steps) PlTypography(step, level: PlTypographyLevel.h5),
          ],
        ),
      ],
    );
  }
}
