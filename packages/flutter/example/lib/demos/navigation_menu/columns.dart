import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class NavigationMenuColumns extends StatelessWidget {
  const NavigationMenuColumns({super.key});

  @override
  Widget build(BuildContext context) {
    return PlNavigationMenu(
      items: <PlNavigationMenuItem>[
        PlNavigationMenuItem(
          label: 'One column',
          links: <PlNavigationMenuLink>[
            PlNavigationMenuLink(title: 'Overview', onPressed: () {}),
            PlNavigationMenuLink(title: 'Changelog', onPressed: () {}),
          ],
        ),
        PlNavigationMenuItem(
          label: 'Three columns',
          columns: 3,
          links: <PlNavigationMenuLink>[
            for (final String title in <String>[
              'Analytics',
              'Billing',
              'Audit log',
              'Integrations',
              'Webhooks',
              'Exports',
            ])
              PlNavigationMenuLink(title: title, onPressed: () {}),
          ],
        ),
      ],
    );
  }
}
