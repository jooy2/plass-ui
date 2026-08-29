import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateFadeTiming extends StatelessWidget {
  const AnimateFadeTiming({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final int delay in <int>[0, 200, 400, 600])
          PlAnimateFade(
            delay: Duration(milliseconds: delay),
            duration: const Duration(milliseconds: 500),
            child: PlChip(child: Text('${delay}ms')),
          ),
      ],
    );
  }
}
