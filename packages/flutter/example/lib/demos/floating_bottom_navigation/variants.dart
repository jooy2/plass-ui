import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/floating_bottom_navigation/destinations.dart';

class FloatingBottomNavigationVariants extends StatelessWidget {
  const FloatingBottomNavigationVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: <Widget>[
          for (final PlassVariant variant in PlassVariant.values)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                PlTypography(variant.name, level: PlTypographyLevel.caption),
                PlFloatingBottomNavigation<String>(
                  items: destinations.take(3).toList(),
                  value: 'home',
                  variant: variant,
                  safeArea: false,
                  onChanged: (String _) {},
                ),
              ],
            ),
        ],
      ),
    );
  }
}
