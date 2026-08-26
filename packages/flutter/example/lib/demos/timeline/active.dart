import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<String> _steps = <String>['Account', 'Payment', 'Review', 'Done'];

class TimelineActive extends StatefulWidget {
  const TimelineActive({super.key});

  @override
  State<TimelineActive> createState() => _TimelineActiveState();
}

class _TimelineActiveState extends State<TimelineActive> {
  int _active = 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: <Widget>[
          PlTimeline(
            active: _active,
            items: <PlTimelineItem>[for (final step in _steps) PlTimelineItem(title: Text(step))],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: <Widget>[
              PlButton(
                size: PlassSize.sm,
                variant: PlassVariant.glass,
                color: PlassColor.secondary,
                onPressed: () => setState(() => _active = _active <= 0 ? 0 : _active - 1),
                child: const Text('Back'),
              ),
              PlButton(
                size: PlassSize.sm,
                onPressed: () => setState(
                  () => _active = _active >= _steps.length ? _steps.length : _active + 1,
                ),
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
