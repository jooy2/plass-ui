import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ToggleVariants extends StatelessWidget {
  const ToggleVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        for (final PlassVariant variant in PlassVariant.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              PlToggle(variant: variant, child: Text('${variant.name} off')),
              PlToggle(variant: variant, defaultPressed: true, child: Text('${variant.name} on')),
            ],
          ),
      ],
    );
  }
}
