import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlTreeSelectNode> _items = <PlTreeSelectNode>[
  PlTreeSelectNode(
    id: 'europe',
    label: 'Europe',
    children: <PlTreeSelectNode>[
      PlTreeSelectNode(id: 'france', label: 'France'),
      PlTreeSelectNode(id: 'germany', label: 'Germany'),
      PlTreeSelectNode(id: 'spain', label: 'Spain'),
    ],
  ),
  PlTreeSelectNode(
    id: 'asia',
    label: 'Asia',
    children: <PlTreeSelectNode>[
      PlTreeSelectNode(id: 'korea', label: 'South Korea'),
      PlTreeSelectNode(id: 'japan', label: 'Japan'),
      PlTreeSelectNode(id: 'singapore', label: 'Singapore'),
    ],
  ),
  PlTreeSelectNode(
    id: 'americas',
    label: 'Americas',
    children: <PlTreeSelectNode>[
      PlTreeSelectNode(id: 'brazil', label: 'Brazil'),
      PlTreeSelectNode(id: 'canada', label: 'Canada'),
    ],
  ),
  PlTreeSelectNode(id: 'antarctica', label: 'Antarctica'),
];

class TreeSelectHero extends StatefulWidget {
  const TreeSelectHero({super.key});

  @override
  State<TreeSelectHero> createState() => _TreeSelectHeroState();
}

class _TreeSelectHeroState extends State<TreeSelectHero> {
  Set<String> _value = <String>{'france'};
  Set<String> _expanded = <String>{'europe'};

  @override
  Widget build(BuildContext context) {
    return PlTreeSelect(
      items: _items,
      label: const Text('Region'),
      placeholder: const Text('Pick a region'),
      clearable: true,
      value: _value,
      onValueChanged: (Set<String> next) => setState(() => _value = next),
      expanded: _expanded,
      onExpandedChanged: (Set<String> next) => setState(() => _expanded = next),
    );
  }
}
