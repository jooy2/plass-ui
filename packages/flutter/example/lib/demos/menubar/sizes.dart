import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MenubarSizes extends StatelessWidget {
  const MenubarSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final PlassSize size in PlassSize.values)
          PlMenubar(
            size: size,
            menus: <PlMenubarMenu>[
              PlMenubarMenu(
                label: size.name,
                items: const <PlMenuEntry>[PlMenuItem(label: 'New')],
              ),
              const PlMenubarMenu(
                label: 'Edit',
                items: <PlMenuEntry>[PlMenuItem(label: 'Copy')],
              ),
            ],
          ),
      ],
    );
  }
}
