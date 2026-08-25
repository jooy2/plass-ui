import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonStates extends StatelessWidget {
  const ButtonStates({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlButton(onPressed: () {}, child: const Text('Idle')),
        PlButton(loading: true, onPressed: () {}, child: const Text('Loading')),
        PlButton(readOnly: true, onPressed: () {}, child: const Text('Read-only')),
        PlButton(disabled: true, onPressed: () {}, child: const Text('Disabled')),
      ],
    );
  }
}
