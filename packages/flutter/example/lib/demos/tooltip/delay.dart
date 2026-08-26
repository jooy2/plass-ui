import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TooltipDelay extends StatelessWidget {
  const TooltipDelay({super.key});

  @override
  Widget build(BuildContext context) {
    Widget trigger(String label) {
      return PlButton(
        size: PlassSize.sm,
        variant: PlassVariant.glass,
        color: PlassColor.secondary,
        onPressed: () {},
        child: Text(label),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          PlTooltip(content: const Text('The house delay: 600ms'), child: trigger('Default')),
          PlTooltip(
            delay: Duration.zero,
            content: const Text('Opens the moment you arrive'),
            child: trigger('No delay'),
          ),
          PlTooltip(
            closeDelay: const Duration(milliseconds: 400),
            content: const Text('Waits before it goes'),
            child: trigger('Slow to close'),
          ),
          PlTooltip(disabled: true, content: const Text('Never shown'), child: trigger('Disabled')),
        ],
      ),
    );
  }
}
