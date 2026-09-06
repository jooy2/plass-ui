import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TabsOverflow extends StatefulWidget {
  const TabsOverflow({super.key});

  @override
  State<TabsOverflow> createState() => _TabsOverflowState();
}

class _TabsOverflowState extends State<TabsOverflow> {
  String _tab = 'seoul';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: PlTabs<String>(
        value: _tab,
        onChanged: (String next) => setState(() => _tab = next),
        tabs: const <PlTab<String>>[
          PlTab<String>(
            value: 'seoul',
            label: Text('Seoul'),
            panel: Text('Nine racks, all of them warm.'),
          ),
          PlTab<String>(
            value: 'tokyo',
            label: Text('Tokyo'),
            panel: Text('Two racks, one of them new.'),
          ),
          PlTab<String>(
            value: 'sydney',
            label: Text('Sydney'),
            panel: Text('A single rack, and a quiet week.'),
          ),
          PlTab<String>(
            value: 'mumbai',
            label: Text('Mumbai'),
            panel: Text('Four racks, and the busiest queue.'),
          ),
          PlTab<String>(
            value: 'frankfurt',
            label: Text('Frankfurt'),
            panel: Text('Six racks, and a spare.'),
          ),
          PlTab<String>(
            value: 'dublin',
            label: Text('Dublin'),
            panel: Text('Three racks, one being replaced.'),
          ),
          PlTab<String>(
            value: 'saopaulo',
            label: Text('São Paulo'),
            panel: Text('Two racks, both new this month.'),
          ),
          PlTab<String>(
            value: 'virginia',
            label: Text('N. Virginia'),
            panel: Text('Twelve racks, and the oldest of them.'),
          ),
        ],
      ),
    );
  }
}
