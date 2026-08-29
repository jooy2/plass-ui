import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateGrowFrom extends StatelessWidget {
  const AnimateGrowFrom({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final double from in <double>[0.6, 0.9, 1.25])
          PlAnimateGrow(
            from: from,
            duration: const Duration(milliseconds: 1200),
            repeat: null,
            alternate: true,
            child: PlChip(
              color: from > 1 ? PlassColor.warning : PlassColor.primary,
              child: Text('from=$from'),
            ),
          ),
      ],
    );
  }
}
