import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonGroupHero extends StatelessWidget {
  const ButtonGroupHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlButtonGroup(
      variant: PlassVariant.glass,
      color: PlassColor.secondary,
      children: <Widget>[
        PlButton(onPressed: () {}, child: const Text('Day')),
        PlButton(onPressed: () {}, child: const Text('Week')),
        PlButton(onPressed: () {}, child: const Text('Month')),
      ],
    );
  }
}
