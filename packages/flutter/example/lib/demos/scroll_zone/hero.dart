import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Show {
  const Show(this.name, this.note, this.still);

  final String name;
  final String note;
  final String still;
}

const List<Show> _shows = <Show>[
  Show('Aurora', 'Documentary', 'desert-rocks-milky-way'),
  Show('Deep Field', 'Science', 'lakeside-observatory-blue-hour'),
  Show('The Long Road', 'Drama', 'bicycle-coastal-path'),
  Show('Salt & Stone', 'Cooking', 'artisan-bread-wooden-rack'),
  Show('Night Shift', 'Thriller', 'rainy-city-crosswalk-reflections'),
  Show('Paper Boats', 'Family', 'rowboat-misty-pond-sunrise'),
  Show('Signal', 'Mystery', 'snowy-cabin-frozen-stream'),
];

class ScrollZoneHero extends StatelessWidget {
  const ScrollZoneHero({super.key});

  @override
  Widget build(BuildContext context) {
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.sm]!),
                      child: SizedBox(
                        height: 64,
                        child: Image(
                          image: NetworkImage('/samples/photos/${show.still}.webp'),
                          fit: BoxFit.cover,
                        ),
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
