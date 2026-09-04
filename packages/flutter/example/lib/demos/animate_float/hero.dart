import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateFloatHero extends StatelessWidget {
  const AnimateFloatHero({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 320,
      height: 180,
      child: Center(
        child: PlAnimateFloat(
          child: Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: tokens.family(PlassColor.primary).fill,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Text(
              '☁',
              style: TextStyle(color: tokens.family(PlassColor.primary).onSolid, fontSize: 34),
            ),
          ),
        ),
      ),
    );
  }
}
