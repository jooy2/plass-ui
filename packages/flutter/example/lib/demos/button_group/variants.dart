import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonGroupVariants extends StatelessWidget {
  const ButtonGroupVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        for (final PlassVariant variant in PlassVariant.values)
          PlButtonGroup(
            variant: variant,
            color: variant == PlassVariant.solid ? PlassColor.primary : PlassColor.secondary,
            children: <Widget>[
              PlButton(onPressed: () {}, child: const Text('Cut')),
              PlButton(onPressed: () {}, child: const Text('Copy')),
              PlButton(onPressed: () {}, child: const Text('Paste')),
            ],
          ),
      ],
    );
  }
}
