import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TooltipSizes extends StatelessWidget {
  const TooltipSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Wrap(
        spacing: 32,
        runSpacing: 48,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          for (final size in PlassSize.values)
            PlTooltip(
              open: true,
              size: size,
              content: Text(size.name),
              child: PlButton(
                size: size,
                variant: PlassVariant.glass,
                color: PlassColor.secondary,
                onPressed: () {},
                child: Text(size.name),
              ),
            ),
        ],
      ),
    );
  }
}
