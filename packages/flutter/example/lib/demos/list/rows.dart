import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class ListRows extends StatelessWidget {
  const ListRows({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: PlList(
        dividers: true,
        children: <Widget>[
          const PlListItem(child: Text('Not pressable')),
          PlListItem(onPressed: () {}, child: const Text('A real focus stop')),
          PlListItem(selected: true, onPressed: () {}, child: const Text('The chosen one')),
          PlListItem(disabled: true, onPressed: () {}, child: const Text('Unavailable')),
          PlListItem(
            startIcon: const BellGlyph(),
            description: const Text('Outside the pressable area, on purpose'),
            onPressed: () {},
            action: PlButton(
              size: PlassSize.xs,
              variant: PlassVariant.ghost,
              color: PlassColor.secondary,
              onPressed: () {},
              child: const Text('Mute'),
            ),
            child: const Text('With an action'),
          ),
        ],
      ),
    );
  }
}
