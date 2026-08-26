import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ChipInteractive extends StatefulWidget {
  const ChipInteractive({super.key});

  @override
  State<ChipInteractive> createState() => _ChipInteractiveState();
}

class _ChipInteractiveState extends State<ChipInteractive> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        const PlChip(child: Text('Not pressable')),
        PlChip(
          selected: _on,
          onPressed: () => setState(() => _on = !_on),
          child: const Text('Pressable'),
        ),
        PlChip(onDeleted: () {}, child: const Text('Removable')),
        PlChip(onPressed: () {}, onDeleted: () {}, child: const Text('Both')),
        PlChip(disabled: true, onPressed: () {}, child: const Text('Disabled')),
      ],
    );
  }
}
