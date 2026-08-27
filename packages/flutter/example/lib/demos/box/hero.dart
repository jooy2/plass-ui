import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BoxHero extends StatelessWidget {
  const BoxHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 384,
      child: PlBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: <Widget>[
            PlTypography('Storage', level: PlTypographyLevel.h6),
            PlTypography(
              'A sheet of glass with content on it. It groups things, and that is all it does.',
            ),
          ],
        ),
      ),
    );
  }
}
