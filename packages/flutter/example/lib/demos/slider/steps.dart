import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SliderSteps extends StatelessWidget {
  const SliderSteps({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: <Widget>[
          PlSlider(
            label: const Text('Continuous'),
            values: const <double>[40],
            showValue: true,
            onChanged: (List<double> next) {},
          ),
          PlSlider(
            label: const Text('In tens'),
            values: const <double>[40],
            step: 10,
            showValue: true,
            onChanged: (List<double> next) {},
          ),
          PlSlider(
            label: const Text('1 to 5'),
            values: const <double>[3],
            min: 1,
            max: 5,
            showValue: true,
            description: const Text('Every step is a whole number, so the thumb snaps.'),
            onChanged: (List<double> next) {},
          ),
        ],
      ),
    );
  }
}
