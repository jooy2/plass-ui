import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateGrowOrigin extends StatelessWidget {
  const AnimateGrowOrigin({super.key});

  static const Map<String, Alignment> _origins = <String, Alignment>{
    'center': Alignment.center,
    'topCenter': Alignment.topCenter,
    'bottomRight': Alignment.bottomRight,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final MapEntry<String, Alignment> origin in _origins.entries)
          PlAnimateGrow(
            origin: origin.value,
            from: 0.4,
            duration: const Duration(milliseconds: 1400),
            repeat: null,
            alternate: true,
            child: PlBox(size: PlassSize.sm, child: Text(origin.key)),
          ),
      ],
    );
  }
}
