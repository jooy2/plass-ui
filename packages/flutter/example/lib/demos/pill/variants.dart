import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PillVariants extends StatelessWidget {
  const PillVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final PlassVariant variant in PlassVariant.values)
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: <Widget>[
              PlTypography(variant.name, level: PlTypographyLevel.caption),
              PlPill(
                variant: variant,
                title: const Text('Uploading'),
                description: const Text('3 of 12'),
              ),
            ],
          ),
      ],
    );
  }
}
