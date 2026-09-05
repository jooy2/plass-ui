import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlTreeSelectNode> _items = <PlTreeSelectNode>[
  PlTreeSelectNode(
    id: 'src',
    label: 'src',
    children: <PlTreeSelectNode>[
      PlTreeSelectNode(id: 'index', label: 'index.ts'),
      PlTreeSelectNode(
        id: 'components',
        label: 'components',
        children: <PlTreeSelectNode>[
          PlTreeSelectNode(id: 'button', label: 'PlButton.tsx'),
          PlTreeSelectNode(id: 'card', label: 'PlCard.tsx'),
          PlTreeSelectNode(id: 'tree-select', label: 'PlTreeSelect.tsx'),
        ],
      ),
      PlTreeSelectNode(
        id: 'internal',
        label: 'internal',
        children: <PlTreeSelectNode>[
          PlTreeSelectNode(id: 'styles', label: 'styles.ts'),
          PlTreeSelectNode(id: 'search', label: 'search.ts'),
        ],
      ),
    ],
  ),
  PlTreeSelectNode(id: 'readme', label: 'README.md'),
];

class TreeSelectSearchable extends StatefulWidget {
  const TreeSelectSearchable({super.key});

  @override
  State<TreeSelectSearchable> createState() => _TreeSelectSearchableState();
}

class _TreeSelectSearchableState extends State<TreeSelectSearchable> {
  Set<String> _value = <String>{};
  Set<String> _expanded = <String>{'src'};

  @override
  Widget build(BuildContext context) {
    return PlTreeSelect(
      items: _items,
      searchable: true,
      label: const Text('File'),
      placeholder: const Text('Pick a file'),
      value: _value,
      onValueChanged: (Set<String> next) => setState(() => _value = next),
      expanded: _expanded,
      onExpandedChanged: (Set<String> next) => setState(() => _expanded = next),
    );
  }
}
