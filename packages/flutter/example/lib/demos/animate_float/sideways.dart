import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateFloatSideways extends StatelessWidget {
  const AnimateFloatSideways({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 320,
      height: 160,
      child: Center(
        child: PlAnimateFloat(
          orientation: PlassOrientation.horizontal,
          distance: 16,
          duration: const Duration(milliseconds: 5000),
          child: Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: tokens.family(PlassColor.secondary).fill,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Text(
              '☁',
              style: TextStyle(color: tokens.family(PlassColor.secondary).onSolid, fontSize: 34),
            ),
          ),
        ),
      ),
    );
  }
}
