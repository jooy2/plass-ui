import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<String> _notices = <String>[
  'Free delivery over \$40',
  'Returns within 30 days',
  'Members get early access',
];

class CarouselAutoPlay extends StatefulWidget {
  const CarouselAutoPlay({super.key});

  @override
  State<CarouselAutoPlay> createState() => _CarouselAutoPlayState();
}

class _CarouselAutoPlayState extends State<CarouselAutoPlay> {
  int _slide = 0;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 448,
      child: PlCarousel(
        label: 'Notices',
        autoPlay: true,
        arrows: false,
        interval: const Duration(milliseconds: 2500),
        value: _slide,
        aspectRatio: 8,
        onChanged: (int next) => setState(() => _slide = next),
        children: <Widget>[
          for (final String notice in _notices)
            ColoredBox(
              color: tokens.family(PlassColor.info).soft,
              child: Center(child: Text(notice)),
            ),
        ],
      ),
    );
  }
}
