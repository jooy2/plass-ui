import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class RadioGroupHero extends StatefulWidget {
  const RadioGroupHero({super.key});

  @override
  State<RadioGroupHero> createState() => _RadioGroupHeroState();
}

class _RadioGroupHeroState extends State<RadioGroupHero> {
  String _plan = 'team';

  @override
  Widget build(BuildContext context) {
    return PlRadioGroup<String>(
      label: const Text('Plan'),
      description: const Text('Change it whenever you like.'),
      value: _plan,
      onChanged: (String next) => setState(() => _plan = next),
      options: const <PlRadioOption<String>>[
        PlRadioOption<String>(
          value: 'starter',
          label: Text('Starter'),
          description: Text('One project, one seat.'),
        ),
        PlRadioOption<String>(
          value: 'team',
          label: Text('Team'),
          description: Text('Shared projects and audit logs.'),
        ),
        PlRadioOption<String>(
          value: 'enterprise',
          label: Text('Enterprise'),
          description: Text('SSO and a contract.'),
        ),
      ],
    );
  }
}
