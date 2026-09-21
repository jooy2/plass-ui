import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TabsAlign extends StatefulWidget {
  const TabsAlign({super.key});

  @override
  State<TabsAlign> createState() => _TabsAlignState();
}

class _TabsAlignState extends State<TabsAlign> {
  String _tab = 'general';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlTabs<String>(
        orientation: const PlassResponsive<PlassOrientation>(PlassOrientation.vertical),
        align: PlassAlign.start,
        value: _tab,
        onChanged: (String next) => setState(() => _tab = next),
        tabs: const <PlTab<String>>[
          PlTab<String>(
            value: 'general',
            label: Text('General'),
            panel: Text('The name of the project and who owns it.'),
          ),
          PlTab<String>(
            value: 'security',
            label: Text('Security'),
            panel: Text('Two-factor authentication and session alerts.'),
          ),
          PlTab<String>(
            value: 'notifications',
            label: Text('Notifications'),
            panel: Text('Which events reach you, and where.'),
          ),
        ],
      ),
    );
  }
}
