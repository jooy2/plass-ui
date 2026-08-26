import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ChipSelected extends StatelessWidget {
  const ChipSelected({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final variant in PlassVariant.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              SizedBox(
                width: 56,
                child: PlTypography(variant.name, level: PlTypographyLevel.caption),
              ),
              PlChip(variant: variant, onPressed: () {}, child: const Text('off')),
              PlChip(variant: variant, selected: true, onPressed: () {}, child: const Text('on')),
            ],
          ),
      ],
    );
  }
}
