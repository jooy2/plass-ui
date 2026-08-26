import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/bottom_navigation/destinations.dart';

class BottomNavigationHero extends StatefulWidget {
  const BottomNavigationHero({super.key});

  @override
  State<BottomNavigationHero> createState() => _BottomNavigationHeroState();
}

class _BottomNavigationHeroState extends State<BottomNavigationHero> {
  String _where = 'home';

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 384,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.lg]!),
        child: ColoredBox(
          color: tokens.glassPress,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'The screen the bar is over.',
                  style: TextStyle(fontSize: 13, color: tokens.mutedFg),
                ),
              ),
              PlBottomNavigation<String>(
                items: destinations,
                value: _where,
                label: 'Main',
                safeArea: false,
                onChanged: (String next) => setState(() => _where = next),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
