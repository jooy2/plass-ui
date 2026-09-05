import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlTreeSelectNode> _items = <PlTreeSelectNode>[
  PlTreeSelectNode(
    id: 'design',
    label: 'Design',
    children: <PlTreeSelectNode>[
      PlTreeSelectNode(id: 'tokens', label: 'Tokens'),
      PlTreeSelectNode(id: 'motion', label: 'Motion'),
    ],
  ),
  PlTreeSelectNode(
    id: 'engineering',
    label: 'Engineering',
    children: <PlTreeSelectNode>[
      PlTreeSelectNode(id: 'web', label: 'Web'),
      PlTreeSelectNode(id: 'mobile', label: 'Mobile'),
      PlTreeSelectNode(id: 'infra', label: 'Infrastructure'),
    ],
  ),
];

class TreeSelectMultiple extends StatefulWidget {
  const TreeSelectMultiple({super.key});

  @override
  State<TreeSelectMultiple> createState() => _TreeSelectMultipleState();
}

class _TreeSelectMultipleState extends State<TreeSelectMultiple> {
  Set<String> _value = <String>{'web', 'infra'};
  Set<String> _expanded = <String>{'engineering'};

  @override
  Widget build(BuildContext context) {
    return PlTreeSelect(
      items: _items,
      multiple: true,
      clearable: true,
      label: const Text('Teams'),
      placeholder: const Text('Pick a team or two'),
      value: _value,
      onValueChanged: (Set<String> next) => setState(() => _value = next),
      expanded: _expanded,
      onExpandedChanged: (Set<String> next) => setState(() => _expanded = next),
    );
  }
}
