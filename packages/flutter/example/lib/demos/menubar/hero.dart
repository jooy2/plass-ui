import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MenubarHero extends StatelessWidget {
  const MenubarHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlToolbar(
      size: PlassSize.sm,
      density: PlassDensity.compact,
      child: PlMenubar(
        menus: <PlMenubarMenu>[
          PlMenubarMenu(
            label: 'File',
            items: <PlMenuEntry>[
              PlMenuItem(label: 'New', shortcut: '⌘N'),
              PlMenuItem(label: 'Open…', shortcut: '⌘O'),
              PlMenuSeparator(),
              PlMenuItem(label: 'Save', shortcut: '⌘S'),
            ],
          ),
          PlMenubarMenu(
            label: 'Edit',
            items: <PlMenuEntry>[
              PlMenuItem(label: 'Undo', shortcut: '⌘Z'),
              PlMenuItem(label: 'Redo', shortcut: '⇧⌘Z'),
              PlMenuSeparator(),
              PlMenuItem(label: 'Cut', shortcut: '⌘X'),
              PlMenuItem(label: 'Copy', shortcut: '⌘C'),
            ],
          ),
          PlMenubarMenu(
            label: 'View',
            items: <PlMenuEntry>[
              PlMenuItem(label: 'Zoom in'),
              PlMenuItem(label: 'Zoom out'),
              PlMenuItem(label: 'Enter full screen', disabled: true),
            ],
          ),
        ],
      ),
    );
  }
}
