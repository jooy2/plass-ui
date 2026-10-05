import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TypographyHeadingLevel extends StatelessWidget {
  const TypographyHeadingLevel({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          PlTypography('A real h3, in the outline', level: PlTypographyLevel.h3),
          PlTypography(
            'The same scale, one level up the outline',
            level: PlTypographyLevel.h3,
            headingLevel: 2,
          ),
          PlTypography('A level-2 heading set at body size', headingLevel: 2),
        ],
      ),
    );
  }
}
