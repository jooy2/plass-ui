import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateBlinkMin extends StatelessWidget {
  const AnimateBlinkMin({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final double min in <double>[0, 0.3, 0.6])
          PlAnimateBlink(
            min: min,
            duration: const Duration(milliseconds: 1400),
            child: PlChip(color: PlassColor.danger, child: Text('min=$min')),
          ),
      ],
    );
  }
}
