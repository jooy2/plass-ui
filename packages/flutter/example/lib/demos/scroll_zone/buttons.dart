import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<String> _people = <String>[
  'Ada',
  'Bo',
  'Cai',
  'Dana',
  'Eun',
  'Fen',
  'Gus',
  'Hana',
  'Ivo',
  'Jun',
];

class ScrollZoneButtons extends StatelessWidget {
  const ScrollZoneButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: <Widget>[
              const PlTypography('buttons: always', level: PlTypographyLevel.caption),
              PlScrollZone(
                label: 'Always',
                spacing: 12,
                buttons: PlScrollZoneButtons.always,
                children: <Widget>[
                  for (final String name in _people) PlAvatar(size: PlassSize.lg, name: name),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: <Widget>[
              const PlTypography('buttons: none · snap', level: PlTypographyLevel.caption),
              PlScrollZone(
                label: 'None',
                spacing: 12,
                snap: true,
                buttons: PlScrollZoneButtons.none,
                children: <Widget>[
                  for (final String name in _people)
                    PlAvatar(size: PlassSize.lg, color: PlassColor.secondary, name: name),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
