import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/floating_bottom_navigation/destinations.dart';

class FloatingBottomNavigationColors extends StatelessWidget {
  const FloatingBottomNavigationColors({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final PlassColor color in <PlassColor>[
            PlassColor.primary,
            PlassColor.success,
            PlassColor.danger,
          ])
            PlFloatingBottomNavigation<String>(
              items: destinations.take(3).toList(),
              value: 'search',
              color: color,
              safeArea: false,
              onChanged: (String _) {},
            ),
        ],
      ),
    );
  }
}
