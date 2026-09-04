import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateSplitHero extends StatelessWidget {
  const AnimateSplitHero({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 360,
      child: PlAnimateSplit(
        text: 'One design language, two libraries',
        style: TextStyle(color: tokens.fg, fontSize: 28, height: 1.3, fontWeight: FontWeight.w600),
      ),
    );
  }
}
