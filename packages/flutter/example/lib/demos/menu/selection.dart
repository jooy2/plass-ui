import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MenuSelection extends StatefulWidget {
  const MenuSelection({super.key});

  @override
  State<MenuSelection> createState() => _MenuSelectionState();
}

class _MenuSelectionState extends State<MenuSelection> {
  bool _wrap = true;
  bool _minimap = false;
  String _layout = 'list';

  @override
  Widget build(BuildContext context) {
    return PlMenu(
      items: <PlMenuEntry>[
        PlMenuGroup(
          label: 'Show',
          items: <PlMenuEntry>[
            PlMenuCheckboxItem(
              label: 'Word wrap',
              shortcut: '⌥Z',
              checked: _wrap,
              onChanged: (bool next) => setState(() => _wrap = next),
            ),
            PlMenuCheckboxItem(
              label: 'Minimap',
              checked: _minimap,
              onChanged: (bool next) => setState(() => _minimap = next),
            ),
          ],
        ),
        const PlMenuSeparator(),
        PlMenuGroup(
          label: 'Layout',
          items: <PlMenuEntry>[
            for (final String layout in <String>['list', 'grid', 'columns'])
              PlMenuRadioItem(
                label: layout,
                selected: _layout == layout,
                onPressed: () => setState(() => _layout = layout),
              ),
          ],
        ),
      ],
      trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
          PlButton(onPressed: open, variant: PlassVariant.glass, child: const Text('View')),
    );
  }
}
