import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateScrambleHero extends StatelessWidget {
  const AnimateScrambleHero({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          PlAnimateScramble(
            text: 'Ship it on Friday',
            trigger: PlassAnimateTrigger.mount,
            style: TextStyle(color: tokens.fg, fontSize: 28, fontWeight: FontWeight.w600),
          ),
          PlAnimateScramble(
            text: '금요일에 배포합니다',
            trigger: PlassAnimateTrigger.mount,
            style: TextStyle(color: tokens.mutedFg, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
