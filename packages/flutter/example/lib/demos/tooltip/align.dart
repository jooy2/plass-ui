import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TooltipAlign extends StatelessWidget {
  const TooltipAlign({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Wrap(
        spacing: 24,
        runSpacing: 56,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          for (final align in PlassAlign.values)
            PlTooltip(
              open: true,
              align: align,
              content: Text(align.name),
              child: PlButton(
                size: PlassSize.sm,
                variant: PlassVariant.glass,
                color: PlassColor.secondary,
                onPressed: () {},
                child: const Text('A wide enough trigger'),
              ),
            ),
        ],
      ),
    );
  }
}
