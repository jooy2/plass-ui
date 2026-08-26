import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SegmentedButtonHero extends StatefulWidget {
  const SegmentedButtonHero({super.key});

  @override
  State<SegmentedButtonHero> createState() => _SegmentedButtonHeroState();
}

class _SegmentedButtonHeroState extends State<SegmentedButtonHero> {
  String _period = 'week';

  @override
  Widget build(BuildContext context) {
    return PlSegmentedButton<String>(
      semanticLabel: 'Period',
      value: _period,
      onChanged: (String next) => setState(() => _period = next),
      segments: const <PlSegment<String>>[
        PlSegment<String>(value: 'day', label: Text('Day')),
        PlSegment<String>(value: 'week', label: Text('Week')),
        PlSegment<String>(value: 'month', label: Text('Month')),
        PlSegment<String>(value: 'year', label: Text('Year')),
      ],
    );
  }
}
