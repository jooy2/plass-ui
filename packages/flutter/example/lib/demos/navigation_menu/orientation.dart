import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class NavigationMenuOrientation extends StatelessWidget {
  const NavigationMenuOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 192,
      child: PlNavigationMenu(
        orientation: PlassOrientation.vertical,
        size: PlassSize.sm,
        items: <PlNavigationMenuItem>[
          PlNavigationMenuItem(label: 'Overview', onPressed: () {}),
          PlNavigationMenuItem(
            label: 'Reports',
            links: <PlNavigationMenuLink>[
              PlNavigationMenuLink(title: 'Usage', onPressed: () {}),
              PlNavigationMenuLink(title: 'Revenue', onPressed: () {}),
            ],
          ),
          PlNavigationMenuItem(label: 'Settings', onPressed: () {}),
        ],
      ),
    );
  }
}
