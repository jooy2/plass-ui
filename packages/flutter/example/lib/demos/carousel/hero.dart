import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Place {
  const Place(this.name, this.image, this.label);

  final String name;
  final String image;
  final String label;
}

const List<Place> _places = <Place>[
  Place(
    'Alpine lake',
    '/samples/photos/alpine-lake-dawn.webp',
    'A still mountain lake at first light',
  ),
  Place(
    'Tea terraces',
    '/samples/photos/misty-tea-terraces-sunrise.webp',
    'Terraced tea fields under morning mist',
  ),
  Place(
    'Forest trail',
    '/samples/photos/forest-trail-sunbeams.webp',
    'Sunbeams across a forest trail',
  ),
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
            Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image(
                  image: NetworkImage(place.image),
                  fit: BoxFit.cover,
                  semanticLabel: place.label,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: <Color>[Color(0x99000000), Color(0x00000000)],
                    ),
                  ),
                ),
                Align(
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
              ],
            ),
        ],
      ),
    );
  }
}
