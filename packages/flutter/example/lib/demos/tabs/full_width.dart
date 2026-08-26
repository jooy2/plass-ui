import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TabsFullWidth extends StatefulWidget {
  const TabsFullWidth({super.key});

  @override
  State<TabsFullWidth> createState() => _TabsFullWidthState();
}

class _TabsFullWidthState extends State<TabsFullWidth> {
  String _tab = 'open';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlTabs<String>(
        fullWidth: true,
        variant: PlassVariant.solid,
        value: _tab,
        onChanged: (String next) => setState(() => _tab = next),
        tabs: const <PlTab<String>>[
          PlTab<String>(
            value: 'open',
            label: Text('Open'),
            panel: Text('Three invoices are waiting.'),
          ),
          PlTab<String>(
            value: 'paid',
            label: Text('Paid'),
            panel: Text('Everything else has cleared.'),
          ),
          PlTab<String>(
            value: 'void',
            label: Text('Void'),
            panel: Text('Nothing has been voided this year.'),
          ),
        ],
      ),
    );
  }
}
