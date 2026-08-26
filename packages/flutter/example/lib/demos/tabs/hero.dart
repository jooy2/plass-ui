import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TabsHero extends StatefulWidget {
  const TabsHero({super.key});

  @override
  State<TabsHero> createState() => _TabsHeroState();
}

class _TabsHeroState extends State<TabsHero> {
  String _tab = 'account';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlTabs<String>(
        value: _tab,
        onChanged: (String next) => setState(() => _tab = next),
        tabs: const <PlTab<String>>[
          PlTab<String>(
            value: 'account',
            label: Text('Account'),
            panel: Text('Your name, your avatar and the language you read in.'),
          ),
          PlTab<String>(
            value: 'billing',
            label: Text('Billing'),
            panel: Text('Cards, invoices and the plan you are on.'),
          ),
          PlTab<String>(
            value: 'team',
            label: Text('Team'),
            endIcon: Text('4'),
            panel: Text('Four people, and what each of them can do.'),
          ),
        ],
      ),
    );
  }
}
