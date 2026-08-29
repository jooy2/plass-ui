import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateRotateOrigin extends StatelessWidget {
  const AnimateRotateOrigin({super.key});

  static const Map<String, Alignment> _origins = <String, Alignment>{
    'center': Alignment.center,
    'bottomLeft': Alignment.bottomLeft,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 40,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final MapEntry<String, Alignment> origin in _origins.entries)
          PlAnimateRotate(
            origin: origin.value,
            from: -30,
            duration: const Duration(milliseconds: 1400),
            repeat: null,
            alternate: true,
            fade: false,
            child: PlBox(size: PlassSize.sm, child: Text(origin.key)),
          ),
      ],
    );
  }
}
