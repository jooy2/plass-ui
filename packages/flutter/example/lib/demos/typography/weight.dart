import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TypographyWeight extends StatelessWidget {
  const TypographyWeight({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: <Widget>[
          for (final weight in PlTypographyWeight.values) PlTypography(weight.name, weight: weight),
        ],
      ),
    );
  }
}
