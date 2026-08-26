import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TabsControlled extends StatefulWidget {
  const TabsControlled({super.key});

  @override
  State<TabsControlled> createState() => _TabsControlledState();
}

class _TabsControlledState extends State<TabsControlled> {
  String _tab = 'write';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          PlTabs<String>(
            value: _tab,
            onChanged: (String next) => setState(() => _tab = next),
            tabs: const <PlTab<String>>[
              PlTab<String>(
                value: 'write',
                label: Text('Write'),
                panel: Text('Markdown goes in here.'),
              ),
              PlTab<String>(
                value: 'preview',
                label: Text('Preview'),
                panel: Text('And comes out rendered here.'),
              ),
            ],
          ),
          PlButton(
            size: PlassSize.sm,
            variant: PlassVariant.glass,
            color: PlassColor.secondary,
            onPressed: () => setState(() => _tab = _tab == 'write' ? 'preview' : 'write'),
            child: const Text('Toggle from outside'),
          ),
        ],
      ),
    );
  }
}
