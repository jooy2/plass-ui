import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonHero extends StatelessWidget {
  const ButtonHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlButton(onPressed: () {}, child: const Text('Save')),
        PlButton(variant: PlassVariant.glass, onPressed: () {}, child: const Text('Cancel')),
        PlButton(variant: PlassVariant.ghost, onPressed: () {}, child: const Text('Details')),
        PlButton(color: PlassColor.danger, onPressed: () {}, child: const Text('Delete')),
        PlButton(loading: true, onPressed: () {}, child: const Text('Saving')),
        PlButton(disabled: true, onPressed: () {}, child: const Text('Unavailable')),
      ],
    );
  }
}
