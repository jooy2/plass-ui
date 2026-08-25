import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonElevation extends StatelessWidget {
  const ButtonElevation({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlButton(elevation: 0, onPressed: () {}, child: const Text('Flush')),
        PlButton(elevation: 1, onPressed: () {}, child: const Text('Resting')),
        PlButton(elevation: 2, onPressed: () {}, child: const Text('Raised')),
        PlButton(elevation: 3, onPressed: () {}, child: const Text('Floating')),
      ],
    );
  }
}
