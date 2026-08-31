import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class StepperVertical extends StatefulWidget {
  const StepperVertical({super.key});

  @override
  State<StepperVertical> createState() => _StepperVerticalState();
}

class _StepperVerticalState extends State<StepperVertical> {
  int _active = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: PlStepper(
        orientation: PlassOrientation.vertical,
        active: _active,
        onActiveChanged: (int next) => setState(() => _active = next),
        steps: <PlStep>[
          for (final (int index, (String label, String body)) in <(String, String)>[
            ('Pick a plan', 'Ten seats on the team plan.'),
            ('Add a card', 'Charged on the first of the month.'),
            ('Invite the team', 'You can do this later.'),
          ].indexed)
            PlStep(
              label: Text(label),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(body),
                  const SizedBox(height: 8),
                  PlButton(
                    size: PlassSize.sm,
                    onPressed: index == 2 ? null : () => setState(() => _active = index + 1),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
