import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class NavigationMenuStates extends StatelessWidget {
  const NavigationMenuStates({super.key});

  @override
  Widget build(BuildContext context) {
    return PlNavigationMenu(
      items: <PlNavigationMenuItem>[
        PlNavigationMenuItem(label: 'A destination', onPressed: () {}),
        PlNavigationMenuItem(
          label: 'A panel',
          links: <PlNavigationMenuLink>[PlNavigationMenuLink(title: 'Somewhere', onPressed: () {})],
        ),
        const PlNavigationMenuItem(
          label: 'Unavailable',
          disabled: true,
          links: <PlNavigationMenuLink>[PlNavigationMenuLink(title: 'Nowhere')],
        ),
      ],
    );
  }
}
