import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MenubarRows extends StatefulWidget {
  const MenubarRows({super.key});

  @override
  State<MenubarRows> createState() => _MenubarRowsState();
}

class _MenubarRowsState extends State<MenubarRows> {
  bool _grid = true;
  bool _rulers = false;

  @override
  Widget build(BuildContext context) {
    return PlMenubar(
      menus: <PlMenubarMenu>[
        PlMenubarMenu(
          label: 'View',
          items: <PlMenuEntry>[
            PlMenuCheckboxItem(
              label: 'Grid',
              checked: _grid,
              onChanged: (bool next) => setState(() => _grid = next),
            ),
            PlMenuCheckboxItem(
              label: 'Rulers',
              checked: _rulers,
              onChanged: (bool next) => setState(() => _rulers = next),
            ),
            const PlMenuSeparator(),
            const PlMenuSubmenu(
              label: 'Appearance',
              items: <PlMenuEntry>[
                PlMenuItem(label: 'Light'),
                PlMenuItem(label: 'Dark'),
                PlMenuItem(label: 'System'),
              ],
            ),
          ],
        ),
        const PlMenubarMenu(
          label: 'Help',
          items: <PlMenuEntry>[
            PlMenuItem(label: 'Documentation'),
            PlMenuItem(label: 'About'),
          ],
        ),
      ],
    );
  }
}
