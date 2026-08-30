import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MenubarOrientation extends StatelessWidget {
  const MenubarOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 176,
      child: PlBox(
        size: PlassSize.sm,
        child: PlMenubar(
          orientation: PlassOrientation.vertical,
          size: PlassSize.sm,
          menus: <PlMenubarMenu>[
            PlMenubarMenu(
              label: 'File',
              items: <PlMenuEntry>[
                PlMenuItem(label: 'New'),
                PlMenuItem(label: 'Open…'),
              ],
            ),
            PlMenubarMenu(
              label: 'Edit',
              items: <PlMenuEntry>[PlMenuItem(label: 'Undo')],
            ),
            PlMenubarMenu(
              label: 'Help',
              items: <PlMenuEntry>[PlMenuItem(label: 'About')],
            ),
          ],
        ),
      ),
    );
  }
}
