import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Shortcut {
  const Shortcut(this.action, this.keys);

  final String action;
  final String keys;
}

const List<Shortcut> _rows = <Shortcut>[
  Shortcut('Command palette', 'Mod+K'),
  Shortcut('Save', 'Mod+S'),
  Shortcut('Find in page', 'Mod+F'),
  Shortcut('Close the tab', 'Mod+W'),
];

class HotKeysList extends StatelessWidget {
  const HotKeysList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlTable<Shortcut>(
        size: PlassSize.sm,
        caption: const Text('Keyboard shortcuts'),
        rows: _rows,
        columns: <PlTableColumn<Shortcut>>[
          PlTableColumn<Shortcut>(
            header: const Text('Action'),
            cell: (Shortcut row, int index) => Text(row.action),
          ),
          PlTableColumn<Shortcut>(
            header: const Text('Shortcut'),
            align: PlassAlign.end,
            cell: (Shortcut row, int index) => PlHotKeys(keys: row.keys, size: PlassSize.sm),
          ),
        ],
      ),
    );
  }
}
