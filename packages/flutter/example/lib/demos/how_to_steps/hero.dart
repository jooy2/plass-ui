import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HowToStepsHero extends StatelessWidget {
  const HowToStepsHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 380,
      child: PlHowToSteps(
        active: 1,
        steps: <PlHowToStep>[
          PlHowToStep(
            title: Text('Add the package'),
            child: Text('flutter pub add plass_ui — there is nothing else to install.'),
          ),
          PlHowToStep(
            title: Text('Import it'),
            child: Text("One line at the top of the file you are working in."),
          ),
          PlHowToStep(
            title: Text('Drop a component in'),
            child: Text('A PlButton looks like a PlButton with no setup at all.'),
          ),
        ],
      ),
    );
  }
}
