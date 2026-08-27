import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PopoverHero extends StatefulWidget {
  const PopoverHero({super.key});

  @override
  State<PopoverHero> createState() => _PopoverHeroState();
}

class _PopoverHeroState extends State<PopoverHero> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return PlPopover(
      open: _open,
      onOpenChanged: (bool next) => setState(() => _open = next),
      title: const Text('Effective rate'),
      description: const Text('Updated hourly'),
      trigger: PlButton(
        variant: PlassVariant.glass,
        onPressed: () => setState(() => _open = true),
        child: const Text('How is this worked out?'),
      ),
      child: const Text(
        'Your rate is the base rate plus whatever your plan adds to it. The full '
        'breakdown is on the billing page.',
      ),
    );
  }
}
