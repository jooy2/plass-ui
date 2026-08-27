import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DrawerHero extends StatefulWidget {
  const DrawerHero({super.key});

  @override
  State<DrawerHero> createState() => _DrawerHeroState();
}

class _DrawerHeroState extends State<DrawerHero> {
  bool _open = false;
  final Set<String> _on = <String>{'In stock only'};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: PlButton(
            variant: PlassVariant.glass,
            onPressed: () => setState(() => _open = true),
            child: const Text('Filters'),
          ),
        ),
        PlDrawer(
          side: PlassSide.right,
          open: _open,
          onOpenChanged: (bool next) => setState(() => _open = next),
          title: const Text('Filters'),
          description: const Text('Nothing is applied yet'),
          actions: <Widget>[
            PlButton(
              variant: PlassVariant.ghost,
              onPressed: () => setState(() => _open = false),
              child: const Text('Cancel'),
            ),
            PlButton(onPressed: () => setState(() => _open = false), child: const Text('Apply')),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              for (final String name in const <String>['In stock only', 'On sale', 'Free delivery'])
                PlSwitch(
                  value: _on.contains(name),
                  onChanged: (bool next) => setState(() {
                    next ? _on.add(name) : _on.remove(name);
                  }),
                  label: Text(name),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
