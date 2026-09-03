import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TabsOrientation extends StatefulWidget {
  const TabsOrientation({super.key});

  @override
  State<TabsOrientation> createState() => _TabsOrientationState();
}

class _TabsOrientationState extends State<TabsOrientation> {
  String _tab = 'general';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlTabs<String>(
        orientation: const PlassResponsive<PlassOrientation>(PlassOrientation.vertical),
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
            value: 'webhooks',
            label: Text('Webhooks'),
            panel: Text('Point a URL at an event and we will POST to it.'),
          ),
        ],
      ),
    );
  }
}
