import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Place {
  const Place(this.name, this.from, this.to);

  final String name;
  final Color from;
  final Color to;
}

const List<Place> _places = <Place>[
  Place('Harbour', Color(0xFF5B8DEF), Color(0xFF57C7D4)),
  Place('Dunes', Color(0xFFE0A458), Color(0xFFE07A5F)),
  Place('Pines', Color(0xFF4CAF7D), Color(0xFF3FA6A6)),
];

class CarouselHero extends StatefulWidget {
  const CarouselHero({super.key});

  @override
  State<CarouselHero> createState() => _CarouselHeroState();
}

class _CarouselHeroState extends State<CarouselHero> {
  int _slide = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: PlCarousel(
        label: 'Places',
        value: _slide,
        aspectRatio: 16 / 7,
        onChanged: (int next) => setState(() => _slide = next),
        children: <Widget>[
          for (final Place place in _places)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[place.from, place.to],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    place.name,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
