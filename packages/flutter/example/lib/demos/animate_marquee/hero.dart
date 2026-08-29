import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateMarqueeHero extends StatelessWidget {
  const AnimateMarqueeHero({super.key});

  static const List<String> _names = <String>[
    'Northwind',
    'Contoso',
    'Fabrikam',
    'Tailspin',
    'Adventure Works',
    'Wide World',
    'Proseware',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: PlAnimateMarquee(
        gap: 24,
        speed: 45,
        children: <Widget>[
          for (final String name in _names)
            PlChip(variant: PlassVariant.glass, color: PlassColor.secondary, child: Text(name)),
        ],
      ),
    );
  }
}
