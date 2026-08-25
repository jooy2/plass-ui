import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonVariants extends StatelessWidget {
  const ButtonVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlButton(variant: PlassVariant.solid, onPressed: () {}, child: const Text('Save')),
        PlButton(variant: PlassVariant.glass, onPressed: () {}, child: const Text('Cancel')),
        PlButton(
          variant: PlassVariant.glass,
          color: PlassColor.secondary,
          onPressed: () {},
          child: const Text('Dismiss'),
        ),
        PlButton(variant: PlassVariant.ghost, onPressed: () {}, child: const Text('Details')),
      ],
    );
  }
}
