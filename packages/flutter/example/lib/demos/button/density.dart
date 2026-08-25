import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonDensity extends StatelessWidget {
  const ButtonDensity({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlButton(size: PlassSize.lg, onPressed: () {}, child: const Text('Standard')),
        PlButton(
          size: PlassSize.lg,
          density: PlassDensity.compact,
          onPressed: () {},
          child: const Text('Compact'),
        ),
        PlButton(
          size: PlassSize.lg,
          variant: PlassVariant.glass,
          onPressed: () {},
          child: const Text('Standard'),
        ),
        PlButton(
          size: PlassSize.lg,
          variant: PlassVariant.glass,
          density: PlassDensity.compact,
          onPressed: () {},
          child: const Text('Compact'),
        ),
      ],
    );
  }
}
