import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HowToStepsPlain extends StatelessWidget {
  const HowToStepsPlain({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 380,
      child: PlHowToSteps(
        numbered: false,
        connector: PlHowToStepsConnector.none,
        density: PlassDensity.compact,
        steps: <PlHowToStep>[
          PlHowToStep(title: Text('Check the licence'), child: Text('Before anything is added.')),
          PlHowToStep(title: Text('Check the size'), child: Text('Before anything is shipped.')),
          PlHowToStep(title: Text('Check the contrast'), child: Text('Before anything is drawn.')),
        ],
      ),
    );
  }
}
