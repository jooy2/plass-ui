import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ToolbarDensity extends StatelessWidget {
  const ToolbarDensity({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        for (final PlassDensity density in PlassDensity.values)
          PlToolbar(
            density: density,
            start: <Widget>[
              PlTypography('density: ${density.name}', level: PlTypographyLevel.caption),
            ],
            end: <Widget>[
              PlButton(
                size: PlassSize.sm,
                density: density,
                onPressed: () {},
                child: const Text('Save'),
              ),
            ],
          ),
      ],
    );
  }
}
