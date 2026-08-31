import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlTreeNode> _items = <PlTreeNode>[
  PlTreeNode(
    id: 'src',
    label: Text('src'),
    children: <PlTreeNode>[
      PlTreeNode(id: 'index', label: Text('index.ts')),
      PlTreeNode(
        id: 'components',
        label: Text('components'),
        children: <PlTreeNode>[
          PlTreeNode(id: 'button', label: Text('PlButton.tsx')),
          PlTreeNode(id: 'card', label: Text('PlCard.tsx')),
          PlTreeNode(id: 'tree', label: Text('PlTree.tsx')),
        ],
      ),
      PlTreeNode(
        id: 'internal',
        label: Text('internal'),
        children: <PlTreeNode>[PlTreeNode(id: 'styles', label: Text('styles.ts'))],
      ),
    ],
  ),
  PlTreeNode(id: 'readme', label: Text('README.md')),
  PlTreeNode(id: 'lock', label: Text('package-lock.json'), disabled: true),
];

class TreeHero extends StatefulWidget {
  const TreeHero({super.key});

  @override
  State<TreeHero> createState() => _TreeHeroState();
}

class _TreeHeroState extends State<TreeHero> {
  Set<String> _expanded = <String>{'src', 'components'};
  Set<String> _selected = <String>{'button'};

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
              expanded: _expanded,
              onExpandedChanged: (Set<String> next) => setState(() => _expanded = next),
              selected: _selected,
              onSelectedChanged: (Set<String> next) => setState(() => _selected = next),
            ),
            const SizedBox(height: 12),
            Text(
              _selected.isEmpty ? 'Nothing chosen' : _selected.first,
              style: TextStyle(color: tokens.mutedFg, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
