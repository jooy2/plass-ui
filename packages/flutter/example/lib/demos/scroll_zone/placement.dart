import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ScrollZonePlacement extends StatelessWidget {
  const ScrollZonePlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          for (final PlScrollZoneButtonPlacement placement in PlScrollZoneButtonPlacement.values)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                PlTypography(
                  'buttonPlacement: \${placement.name}',
                  level: PlTypographyLevel.caption,
                ),
                PlScrollZone(
                  label: placement.name,
                  buttons: PlScrollZoneButtons.always,
                  buttonPlacement: placement,
                  children: <Widget>[
                    for (var index = 1; index <= 12; index += 1)
                      SizedBox(
                        width: 112,
                        child: PlCard(size: PlassSize.sm, child: Text('Item $index')),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
