import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateLightingColors extends StatelessWidget {
  const AnimateLightingColors({super.key});

  static const List<PlassColor> _colors = <PlassColor>[
    PlassColor.primary,
    PlassColor.success,
    PlassColor.warning,
    PlassColor.danger,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final PlassColor color in _colors)
          PlAnimateLighting(
            size: PlassSize.sm,
            color: color,
            duration: const Duration(milliseconds: 2400),
            child: PlBox(size: PlassSize.sm, child: Text(color.name)),
          ),
      ],
    );
  }
}
