import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SliderSizes extends StatelessWidget {
  const SliderSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: <Widget>[
          for (final size in PlassSize.values)
            PlSlider(
              size: size,
              label: Text(size.name),
              values: const <double>[55],
              showValue: true,
              onChanged: (List<double> next) {},
            ),
        ],
      ),
    );
  }
}
