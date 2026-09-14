import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateMarqueePaused extends StatefulWidget {
  const AnimateMarqueePaused({super.key});

  @override
  State<AnimateMarqueePaused> createState() => _AnimateMarqueePausedState();
}

class _AnimateMarqueePausedState extends State<AnimateMarqueePaused> {
  static const List<String> _updates = <String>[
    'Build 412 passed',
    'Staging deployed',
    'Two reviews waiting',
    'Backup finished',
    'Cache cleared',
    'Release notes drafted',
  ];

  bool _paused = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          PlButton(
            size: PlassSize.sm,
            onPressed: () => setState(() => _paused = !_paused),
            child: Text(_paused ? 'Play' : 'Pause'),
          ),
          PlAnimateMarquee(
            gap: 16,
            speed: 45,
            paused: _paused,
            children: <Widget>[for (final String update in _updates) PlChip(child: Text(update))],
          ),
        ],
      ),
    );
  }
}
