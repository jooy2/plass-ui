import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateAppearHero extends StatefulWidget {
  const AnimateAppearHero({super.key});

  @override
  State<AnimateAppearHero> createState() => _AnimateAppearHeroState();
}

class _AnimateAppearHeroState extends State<AnimateAppearHero> {
  static const Map<String, String> _rows = <String, String>{
    'api-gateway': 'Deployed 2 minutes ago',
    'billing': 'Deployed 14 minutes ago',
    'search-index': 'Rebuilding',
    'mailer': 'Deployed yesterday',
  };

  int _run = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        PlButton(
          size: PlassSize.sm,
          variant: PlassVariant.glass,
          color: PlassColor.secondary,
          onPressed: () => setState(() => _run += 1),
          child: const Text('Play again'),
        ),
        SizedBox(
          width: 320,
          child: PlAnimateAppear(
            key: ValueKey<int>(_run),
            spacing: 8,
            children: <Widget>[
              for (final MapEntry<String, String> row in _rows.entries)
                PlCard(size: PlassSize.sm, title: Text(row.key), subtitle: Text(row.value)),
            ],
          ),
        ),
      ],
    );
  }
}
