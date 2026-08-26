import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MenuSubmenus extends StatelessWidget {
  const MenuSubmenus({super.key});

  @override
  Widget build(BuildContext context) {
    return PlMenu(
      items: const <PlMenuEntry>[
        PlMenuItem(label: 'Copy link'),
        PlMenuSeparator(),
        PlMenuSubmenu(
          label: 'Send to',
          items: <PlMenuEntry>[
            PlMenuItem(label: 'Email'),
            PlMenuItem(label: 'Message'),
            PlMenuSubmenu(
              label: 'More',
              items: <PlMenuEntry>[
                PlMenuItem(label: 'Print'),
                PlMenuItem(label: 'Fax, apparently'),
              ],
            ),
          ],
        ),
        PlMenuSubmenu(
          label: 'Export as',
          items: <PlMenuEntry>[
            PlMenuItem(label: 'PDF'),
            PlMenuItem(label: 'Markdown'),
          ],
        ),
      ],
      trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
          PlButton(onPressed: open, variant: PlassVariant.glass, child: const Text('Share')),
    );
  }
}
