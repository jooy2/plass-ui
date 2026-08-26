import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/bottom_navigation/destinations.dart';

class BottomNavigationLabels extends StatelessWidget {
  const BottomNavigationLabels({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final PlBottomNavigationLabels labels in PlBottomNavigationLabels.values)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                PlTypography('labels: ${labels.name}', level: PlTypographyLevel.caption),
                PlBottomNavigation<String>(
                  items: destinations.take(3).toList(),
                  value: 'search',
                  labels: labels,
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
