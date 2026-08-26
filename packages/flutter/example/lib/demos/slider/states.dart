import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SliderStates extends StatelessWidget {
  const SliderStates({super.key});

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
            label: const Text('Default'),
            values: const <double>[45],
            showValue: true,
            onChanged: (List<double> next) {},
          ),
          const PlSlider(
            label: Text('Disabled'),
            values: <double>[45],
            showValue: true,
            disabled: true,
          ),
        ],
      ),
    );
  }
}
