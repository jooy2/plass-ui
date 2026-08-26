import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MenuHero extends StatelessWidget {
  const MenuHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlMenu(
      label: 'Actions',
      items: const <PlMenuEntry>[
        PlMenuItem(label: 'Cut', shortcut: '⌘X'),
        PlMenuItem(label: 'Copy', shortcut: '⌘C'),
        PlMenuItem(label: 'Paste', shortcut: '⌘V'),
        PlMenuSeparator(),
        PlMenuItem(label: 'Delete', shortcut: '⌫', color: PlassColor.danger),
      ],
      trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
          PlButton(onPressed: open, variant: PlassVariant.glass, child: const Text('Actions')),
    );
  }
}
