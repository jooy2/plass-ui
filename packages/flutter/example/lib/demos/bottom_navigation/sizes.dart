import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/bottom_navigation/destinations.dart';

class BottomNavigationSizes extends StatelessWidget {
  const BottomNavigationSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final PlassSize size in <PlassSize>[PlassSize.sm, PlassSize.md, PlassSize.lg])
            PlBottomNavigation<String>(
              items: destinations.take(3).toList(),
              value: 'home',
              size: size,
              safeArea: false,
              onChanged: (String _) {},
            ),
        ],
      ),
    );
  }
}
