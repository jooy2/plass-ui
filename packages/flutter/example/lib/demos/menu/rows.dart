import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class MenuRows extends StatelessWidget {
  const MenuRows({super.key});

  @override
  Widget build(BuildContext context) {
    return PlMenu(
      items: const <PlMenuEntry>[
        PlMenuItem(label: 'With an icon', startIcon: StarGlyph(), shortcut: '⌘D'),
        PlMenuItem(
          label: 'With a description',
          description: 'A second line, one step down and muted',
        ),
        PlMenuItem(label: 'Unavailable', disabled: true),
        PlMenuSeparator(),
        PlMenuItem(label: 'Delete everything', color: PlassColor.danger),
      ],
      trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
          PlButton(onPressed: open, variant: PlassVariant.glass, child: const Text('Rows')),
    );
  }
}
