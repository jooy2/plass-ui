import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TooltipSides extends StatelessWidget {
  const TooltipSides({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 72),
      child: Wrap(
        spacing: 140,
        runSpacing: 48,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          for (final side in PlassSide.values)
            PlTooltip(
              // Held open, so the page shows what each side looks like rather
              // than what it looks like to wait for one.
              open: true,
              side: side,
              content: Text('On the ${side.name}'),
              child: PlButton(
                size: PlassSize.sm,
                variant: PlassVariant.glass,
                color: PlassColor.secondary,
                onPressed: () {},
                child: Text(side.name),
              ),
            ),
        ],
      ),
    );
  }
}
