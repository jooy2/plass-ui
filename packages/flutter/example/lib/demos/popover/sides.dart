import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PopoverSides extends StatefulWidget {
  const PopoverSides({super.key});

  @override
  State<PopoverSides> createState() => _PopoverSidesState();
}

class _PopoverSidesState extends State<PopoverSides> {
  PlassSide? _open;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final PlassSide side in PlassSide.values)
          PlPopover(
            side: side,
            arrow: true,
            open: _open == side,
            onOpenChanged: (bool next) => setState(() => _open = next ? side : null),
            title: Text('side: ${side.name}'),
            trigger: PlButton(
              variant: PlassVariant.glass,
              onPressed: () => setState(() => _open = side),
              child: Text(side.name),
            ),
            child: const Text('It flips to the opposite side when there is no room.'),
          ),
      ],
    );
  }
}
