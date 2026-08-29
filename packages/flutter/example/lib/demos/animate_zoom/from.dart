import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateZoomFrom extends StatelessWidget {
  const AnimateZoomFrom({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final double from in <double>[0.2, 0.4, 1.6])
          PlAnimateZoom(
            from: from,
            duration: const Duration(milliseconds: 1300),
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
