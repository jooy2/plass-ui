import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class NavigationMenuHero extends StatelessWidget {
  const NavigationMenuHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlNavigationMenu(
      items: <PlNavigationMenuItem>[
        PlNavigationMenuItem(
          label: 'Product',
          columns: 2,
          links: <PlNavigationMenuLink>[
            PlNavigationMenuLink(
              title: 'Analytics',
              description: 'Numbers over time',
              onPressed: () {},
            ),
            PlNavigationMenuLink(
              title: 'Billing',
              description: 'Invoices and plans',
              onPressed: () {},
            ),
            PlNavigationMenuLink(
              title: 'Audit log',
              description: 'Who did what, when',
              onPressed: () {},
            ),
            PlNavigationMenuLink(
              title: 'Integrations',
              description: 'Everything else',
              onPressed: () {},
            ),
          ],
        ),
        PlNavigationMenuItem(
          label: 'Developers',
          links: <PlNavigationMenuLink>[
            PlNavigationMenuLink(
              title: 'Documentation',
              description: 'Guides and reference',
              onPressed: () {},
            ),
            PlNavigationMenuLink(title: 'API', description: 'The REST surface', onPressed: () {}),
          ],
        ),
        PlNavigationMenuItem(label: 'Pricing', onPressed: () {}),
      ],
    );
  }
}
