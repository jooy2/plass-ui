import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateHeadlineHero extends StatelessWidget {
  const AnimateHeadlineHero({super.key});

  static const List<String> _lines = <String>[
    'ships on Friday',
    'reads like prose',
    'weighs almost nothing',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: <Widget>[
        const PlTypography('Software that', level: PlTypographyLevel.h3),
        PlAnimateHeadline(
          interval: const Duration(milliseconds: 2200),
          children: <Widget>[
            for (final String line in _lines)
              PlTypography(line, level: PlTypographyLevel.h3, color: PlassColor.primary),
          ],
        ),
      ],
    );
  }
}
