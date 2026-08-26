import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SliderColors extends StatelessWidget {
  const SliderColors({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: <Widget>[
          for (final color in <PlassColor>[
            PlassColor.primary,
            PlassColor.success,
            PlassColor.warning,
            PlassColor.danger,
          ])
            PlSlider(
              color: color,
              label: Text(color.name),
              values: const <double>[60],
              showValue: true,
              onChanged: (List<double> next) {},
            ),
        ],
      ),
    );
  }
}
