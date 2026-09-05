import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateMarqueeHero extends StatelessWidget {
  const AnimateMarqueeHero({super.key});

  /// The row of customer logos a marquee is nearly always asked for.
  static const List<(String, String)> _brands = <(String, String)>[
    ('Lanterna', '/samples/marks/lantern.webp'),
    ('Northpin', '/samples/marks/compass.webp'),
    ('Kitewind', '/samples/marks/kite.webp'),
    ('Layerloom', '/samples/marks/layers.webp'),
    ('Sunmeadow', '/samples/marks/solar.webp'),
    ('Farglass', '/samples/marks/telescope.webp'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: PlAnimateMarquee(
        gap: 40,
        speed: 45,
        children: <Widget>[
          for (final (String name, String mark) in _brands)
            PlAppLogo(
              size: PlassSize.sm,
              name: Text(name),
              child: Image(image: NetworkImage(mark)),
            ),
        ],
      ),
    );
  }
}
