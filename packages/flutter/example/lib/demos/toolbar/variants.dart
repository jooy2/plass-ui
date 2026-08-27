import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ToolbarVariants extends StatelessWidget {
  const ToolbarVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        for (final PlassVariant variant in PlassVariant.values)
          PlToolbar(
            variant: variant,
            start: <Widget>[PlTypography(variant.name, level: PlTypographyLevel.caption)],
            end: <Widget>[
              PlButton(
                size: PlassSize.sm,
                variant: PlassVariant.ghost,
                onPressed: () {},
                child: const Text('Action'),
              ),
            ],
          ),
      ],
    );
  }
}
