import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateZoomResult extends StatefulWidget {
  const AnimateZoomResult({super.key});

  @override
  State<AnimateZoomResult> createState() => _AnimateZoomResultState();
}

class _AnimateZoomResultState extends State<AnimateZoomResult> {
  int? _score;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        PlButton(
          size: PlassSize.sm,
          onPressed: () => setState(() => _score = _score == null ? 92 : null),
          child: Text(_score == null ? 'Run the check' : 'Reset'),
        ),
        if (_score != null)
          PlAnimateZoom(
            duration: const Duration(milliseconds: 380),
            child: PlBox(
              size: PlassSize.lg,
              color: PlassColor.success,
              child: PlTypography('$_score', level: PlTypographyLevel.h2),
            ),
          ),
      ],
    );
  }
}
