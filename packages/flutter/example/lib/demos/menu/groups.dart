import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MenuGroups extends StatelessWidget {
  const MenuGroups({super.key});

  @override
  Widget build(BuildContext context) {
    return PlMenu(
      items: const <PlMenuEntry>[
        PlMenuGroup(
          label: 'Edit',
          items: <PlMenuEntry>[
            PlMenuItem(label: 'Cut', shortcut: '⌘X'),
            PlMenuItem(label: 'Copy', shortcut: '⌘C'),
          ],
        ),
        PlMenuSeparator(),
        PlMenuGroup(
          label: 'Document',
          items: <PlMenuEntry>[
            PlMenuItem(label: 'Save', shortcut: '⌘S'),
            PlMenuItem(label: 'Print', shortcut: '⌘P'),
          ],
        ),
      ],
      trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
          PlButton(onPressed: open, variant: PlassVariant.glass, child: const Text('Grouped')),
    );
  }
}
