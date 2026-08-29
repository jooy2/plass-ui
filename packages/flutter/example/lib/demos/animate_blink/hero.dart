import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateBlinkHero extends StatelessWidget {
  const AnimateBlinkHero({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return Wrap(
      spacing: 32,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: <Widget>[
            PlAnimateBlink(
              duration: const Duration(milliseconds: 1400),
              min: 0.15,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.family(PlassColor.danger).accent,
                ),
              ),
            ),
            const PlTypography('Recording'),
          ],
        ),
        const PlAnimateBlink(
          duration: Duration(milliseconds: 1600),
          min: 0.45,
          child: PlChip(color: PlassColor.warning, child: Text('Awaiting approval')),
        ),
      ],
    );
  }
}
