import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TypographyColors extends StatelessWidget {
  const TypographyColors({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: <Widget>[
          const PlTypography('No colour asked for — the page’s own ink.'),
          for (final color in PlassColor.values) PlTypography(color.name, color: color),
        ],
      ),
    );
  }
}
