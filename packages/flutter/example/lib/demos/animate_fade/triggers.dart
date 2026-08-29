import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateFadeTriggers extends StatefulWidget {
  const AnimateFadeTriggers({super.key});

  @override
  State<AnimateFadeTriggers> createState() => _AnimateFadeTriggersState();
}

class _AnimateFadeTriggersState extends State<AnimateFadeTriggers> {
  bool _play = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        const Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: <Widget>[
            PlAnimateFade(
              trigger: PlassAnimateTrigger.hover,
              duration: Duration(milliseconds: 400),
              child: PlBox(size: PlassSize.sm, child: Text('Hover me')),
            ),
            PlAnimateFade(
              trigger: PlassAnimateTrigger.visible,
              duration: Duration(milliseconds: 600),
              child: PlBox(size: PlassSize.sm, child: Text('On scrolling into view')),
            ),
          ],
        ),
        PlSwitch(
          size: PlassSize.sm,
          value: _play,
          onChanged: (bool value) => setState(() => _play = value),
          label: const Text('Play the manual one'),
        ),
        PlAnimateFade(
          trigger: PlassAnimateTrigger.manual,
          play: _play,
          duration: const Duration(milliseconds: 500),
          child: const PlBox(size: PlassSize.sm, child: Text('Driven by the switch')),
        ),
      ],
    );
  }
}
