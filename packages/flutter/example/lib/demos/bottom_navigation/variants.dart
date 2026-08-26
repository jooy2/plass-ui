import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/bottom_navigation/destinations.dart';

class BottomNavigationVariants extends StatelessWidget {
  const BottomNavigationVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final PlassVariant variant in PlassVariant.values)
            PlBottomNavigation<String>(
              items: destinations.take(3).toList(),
              value: 'home',
              variant: variant,
              safeArea: false,
              onChanged: (String _) {},
            ),
        ],
      ),
    );
  }
}
