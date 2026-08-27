import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CarouselLoop extends StatefulWidget {
  const CarouselLoop({super.key});

  @override
  State<CarouselLoop> createState() => _CarouselLoopState();
}

class _CarouselLoopState extends State<CarouselLoop> {
  final List<int> _slides = <int>[0, 0];

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (var index = 0; index < 2; index += 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                PlTypography(
                  index == 0 ? 'loop — the default' : 'loop: false — inert at the ends',
                  level: PlTypographyLevel.caption,
                ),
                PlCarousel(
                  label: index == 0 ? 'Looping' : 'Bounded',
                  loop: index == 0,
                  value: _slides[index],
                  aspectRatio: 4,
                  onChanged: (int next) => setState(() => _slides[index] = next),
                  children: <Widget>[
                    for (final String word in const <String>['One', 'Two', 'Three'])
                      ColoredBox(
                        color: tokens.family(PlassColor.secondary).soft,
                        child: Center(child: Text(word)),
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
