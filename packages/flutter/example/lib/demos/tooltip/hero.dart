import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TooltipHero extends StatelessWidget {
  const TooltipHero({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return PlTooltipProvider(
      // Room above and below for a plate to appear in.
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            PlTooltip(
              content: const Text('Copy to clipboard'),
              child: PlButton(
                variant: PlassVariant.glass,
                color: PlassColor.secondary,
                semanticLabel: 'Copy',
                onPressed: () {},
                child: const Text('⧉'),
              ),
            ),
            PlTooltip(
              content: const Text('Nothing is deleted until you confirm'),
              side: PlassSide.bottom,
              child: PlButton(
                variant: PlassVariant.ghost,
                color: PlassColor.danger,
                onPressed: () {},
                child: const Text('Delete'),
              ),
            ),
            PlTooltip(
              content: const Text('Saved two minutes ago'),
              side: PlassSide.right,
              child: Text(
                'Saved',
                style: TextStyle(
                  color: tokens.mutedFg,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
