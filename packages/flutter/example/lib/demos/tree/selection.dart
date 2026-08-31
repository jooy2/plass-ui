import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlTreeNode> _items = <PlTreeNode>[
  PlTreeNode(
    id: 'design',
    label: Text('Design'),
    children: <PlTreeNode>[
      PlTreeNode(id: 'colour', label: Text('Colour')),
      PlTreeNode(id: 'type', label: Text('Typography')),
    ],
  ),
  PlTreeNode(
    id: 'engineering',
    label: Text('Engineering'),
    children: <PlTreeNode>[
      PlTreeNode(id: 'web', label: Text('Web')),
      PlTreeNode(id: 'mobile', label: Text('Mobile')),
    ],
  ),
];

class TreeSelection extends StatefulWidget {
  const TreeSelection({super.key});

  @override
  State<TreeSelection> createState() => _TreeSelectionState();
}

class _TreeSelectionState extends State<TreeSelection> {
  final Set<String> _expanded = <String>{'design', 'engineering'};
  Set<String> _selected = <String>{'colour', 'web'};

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 320,
      child: PlCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PlTree(
              items: _items,
              selection: PlTreeSelection.multiple,
              expanded: _expanded,
              selected: _selected,
              onSelectedChanged: (Set<String> next) => setState(() => _selected = next),
            ),
            const SizedBox(height: 12),
            Text(
              '${_selected.length} chosen',
              style: TextStyle(color: tokens.mutedFg, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
