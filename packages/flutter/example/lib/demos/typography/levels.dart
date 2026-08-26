import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TypographyLevels extends StatelessWidget {
  const TypographyLevels({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final level in PlTypographyLevel.values)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              spacing: 16,
              children: <Widget>[
                SizedBox(
                  width: 64,
                  child: PlTypography(level.name, level: PlTypographyLevel.caption),
                ),
                Flexible(child: PlTypography('The quick brown fox', level: level)),
              ],
            ),
        ],
      ),
    );
  }
}
