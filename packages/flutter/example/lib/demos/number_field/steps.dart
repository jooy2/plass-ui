import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class NumberFieldSteps extends StatefulWidget {
  const NumberFieldSteps({super.key});

  @override
  State<NumberFieldSteps> createState() => _NumberFieldStepsState();
}

class _NumberFieldStepsState extends State<NumberFieldSteps> {
  double? _modifiers = 0;
  double? _snapped = 7;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          PlNumberField(
            fullWidth: true,
            label: const Text('Hold Shift for 10, Alt for 0.1'),
            description: const Text('The arrow keys and the steppers both take the modifiers.'),
            largeStep: 10,
            smallStep: 0.1,
            value: _modifiers,
            onChanged: (double? next) => setState(() => _modifiers = next),
          ),
          PlNumberField(
            fullWidth: true,
            label: const Text('Snapped to multiples of 5'),
            step: 5,
            snapOnStep: true,
            value: _snapped,
            onChanged: (double? next) => setState(() => _snapped = next),
          ),
        ],
      ),
    );
  }
}
