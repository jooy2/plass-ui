import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MenuSizes extends StatelessWidget {
  const MenuSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        for (final PlassSize size in <PlassSize>[PlassSize.sm, PlassSize.md, PlassSize.lg])
          PlMenu(
            size: size,
            items: const <PlMenuEntry>[
              PlMenuItem(label: 'Cut', shortcut: '⌘X'),
              PlMenuItem(label: 'Copy', shortcut: '⌘C'),
            ],
            trigger: (BuildContext context, VoidCallback open, bool isOpen) => PlButton(
              size: size,
              onPressed: open,
              variant: PlassVariant.glass,
              child: Text(size.name),
            ),
          ),
      ],
    );
  }
}
