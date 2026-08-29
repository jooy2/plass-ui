import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateSlideSides extends StatelessWidget {
  const AnimateSlideSides({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final PlassSide side in PlassSide.values)
          PlAnimateSlide(
            from: side,
            distance: 24,
            duration: const Duration(milliseconds: 1200),
            repeat: null,
            alternate: true,
            child: PlChip(child: Text(side.name)),
          ),
      ],
    );
  }
}
