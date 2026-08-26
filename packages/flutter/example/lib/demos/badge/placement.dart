import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BadgePlacement extends StatelessWidget {
  const BadgePlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 32,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final corner in PlassCorner.values)
          PlBadge(
            count: 3,
            placement: corner,
            child: PlButton(
              variant: PlassVariant.glass,
              color: PlassColor.secondary,
              size: PlassSize.sm,
              onPressed: () {},
              child: Text(corner.name),
            ),
          ),
      ],
    );
  }
}
