import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Show {
  const Show(this.name, this.note);

  final String name;
  final String note;
}

const List<Show> _shows = <Show>[
  Show('Aurora', 'Documentary'),
  Show('Deep Field', 'Science'),
  Show('The Long Road', 'Drama'),
  Show('Salt & Stone', 'Cooking'),
  Show('Night Shift', 'Thriller'),
  Show('Paper Boats', 'Family'),
  Show('Signal', 'Mystery'),
];

class ScrollZoneHero extends StatelessWidget {
  const ScrollZoneHero({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: <Widget>[
          const PlTypography('Continue watching', level: PlTypographyLevel.h6),
          PlScrollZone(
            label: 'Continue watching',
            spacing: 12,
            children: <Widget>[
              for (final Show show in _shows)
                SizedBox(
                  width: 160,
                  child: PlCard(
                    size: PlassSize.sm,
                    title: Text(show.name),
                    subtitle: Text(show.note),
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: tokens.family(PlassColor.primary).soft,
                        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.sm]!),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
