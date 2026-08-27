import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CollapsibleHero extends StatefulWidget {
  const CollapsibleHero({super.key});

  @override
  State<CollapsibleHero> createState() => _CollapsibleHeroState();
}

class _CollapsibleHeroState extends State<CollapsibleHero> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: PlCollapsible(
        open: _open,
        onOpenChanged: (bool next) => setState(() => _open = next),
        title: const Text('Advanced'),
        subtitle: const Text('Nine settings'),
        child: const Text(
          'Everything a form does not need to ask on the first pass lives behind one of '
          'these, and the screen does not grow until somebody asks for it.',
        ),
      ),
    );
  }
}
