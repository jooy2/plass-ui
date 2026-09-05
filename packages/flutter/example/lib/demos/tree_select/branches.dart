import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlTreeSelectNode> _items = <PlTreeSelectNode>[
  PlTreeSelectNode(
    id: 'clothing',
    label: 'Clothing',
    children: <PlTreeSelectNode>[
      PlTreeSelectNode(id: 'coats', label: 'Coats'),
      PlTreeSelectNode(id: 'shirts', label: 'Shirts'),
    ],
  ),
  PlTreeSelectNode(
    id: 'home',
    label: 'Home',
    // Chosen on its own even though the rest of the branches cannot be.
    selectable: true,
    children: <PlTreeSelectNode>[
      PlTreeSelectNode(id: 'lighting', label: 'Lighting'),
      PlTreeSelectNode(id: 'kitchen', label: 'Kitchen'),
    ],
  ),
];

class TreeSelectBranches extends StatefulWidget {
  const TreeSelectBranches({super.key});

  @override
  State<TreeSelectBranches> createState() => _TreeSelectBranchesState();
}

class _TreeSelectBranchesState extends State<TreeSelectBranches> {
  Set<String> _leaves = <String>{};
  Set<String> _both = <String>{};
  Set<String> _leavesOpen = <String>{'clothing'};
  Set<String> _bothOpen = <String>{'clothing'};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        PlTreeSelect(
          items: _items,
          label: const Text('Leaves only'),
          placeholder: const Text('Pick a category'),
          value: _leaves,
          onValueChanged: (Set<String> next) => setState(() => _leaves = next),
          expanded: _leavesOpen,
          onExpandedChanged: (Set<String> next) => setState(() => _leavesOpen = next),
        ),
        PlTreeSelect(
          items: _items,
          selectableBranches: true,
          label: const Text('Branches too'),
          placeholder: const Text('Pick a category'),
          value: _both,
          onValueChanged: (Set<String> next) => setState(() => _both = next),
          expanded: _bothOpen,
          onExpandedChanged: (Set<String> next) => setState(() => _bothOpen = next),
        ),
      ],
    );
  }
}
