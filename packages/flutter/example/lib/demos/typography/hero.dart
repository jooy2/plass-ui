import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TypographyHero extends StatelessWidget {
  const TypographyHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PlTypography('Release notes', level: PlTypographyLevel.overline, gutter: true),
          PlTypography('A material rather than a theme', level: PlTypographyLevel.h2, gutter: true),
          PlTypography(
            'Every surface answers one question — is this pressed, or does it hold something?',
            level: PlTypographyLevel.lead,
            gutter: true,
          ),
          PlTypography(
            'The answer decides the fill, the shadow, the radius and the way it moves under a '
            'pointer.',
            gutter: true,
          ),
          PlTypography(
            'Written down so nobody has to guess twice.',
            level: PlTypographyLevel.caption,
          ),
        ],
      ),
    );
  }
}
