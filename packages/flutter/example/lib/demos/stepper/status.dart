import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class StepperStatus extends StatelessWidget {
  const StepperStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      // The reader has moved on, and the second step failed validation behind
      // them. `status` and `color` say so without moving `active`.
      child: PlStepper(
        active: 2,
        linear: false,
        onActiveChanged: (int _) {},
        steps: const <PlStep>[
          PlStep(label: Text('Account')),
          PlStep(
            label: Text('Verify'),
            description: Text('Code expired'),
            status: PlStepStatus.current,
            color: PlassColor.danger,
          ),
          PlStep(label: Text('Profile')),
        ],
      ),
    );
  }
}
