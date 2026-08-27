import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonGroupSizes extends StatelessWidget {
  const ButtonGroupSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        for (final PlassSize size in PlassSize.values)
          PlButtonGroup(
            size: size,
            variant: PlassVariant.glass,
            color: PlassColor.secondary,
            children: <Widget>[
              PlButton(onPressed: () {}, child: const Text('Back')),
              PlButton(onPressed: () {}, child: const Text('Forward')),
            ],
          ),
      ],
    );
  }
}
