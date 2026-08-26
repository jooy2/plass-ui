import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ContainerHero extends StatelessWidget {
  const ContainerHero({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 640,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.glassPress,
          borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.lg]!),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: PlContainer(
            maxWidth: PlassSize.xs,
            child: PlCard(
              title: Text('Inside the measure'),
              child: Text(
                'The container is the gutter down each side and the width the '
                'content stops at. It draws nothing itself — the sheet you can '
                'see is this card.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
