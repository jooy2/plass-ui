import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DrawerSides extends StatefulWidget {
  const DrawerSides({super.key});

  @override
  State<DrawerSides> createState() => _DrawerSidesState();
}

class _DrawerSidesState extends State<DrawerSides> {
  PlassSide? _side;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final PlassSide side in PlassSide.values)
                PlButton(
                  variant: PlassVariant.glass,
                  onPressed: () => setState(() => _side = side),
                  child: Text(side.name),
                ),
            ],
          ),
        ),
        PlDrawer(
          side: _side ?? PlassSide.left,
          open: _side != null,
          onOpenChanged: (bool next) => setState(() => _side = next ? _side : null),
          title: Text('side: ${(_side ?? PlassSide.left).name}'),
          description: const Text('Square against the screen, cut on the free side.'),
          child: const Text(
            'A top or bottom panel is as tall as what is in it, up to 85% of the screen.',
          ),
        ),
      ],
    );
  }
}
