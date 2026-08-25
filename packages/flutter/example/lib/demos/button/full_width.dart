import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonFullWidth extends StatelessWidget {
  const ButtonFullWidth({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PlButton(fullWidth: true, onPressed: () {}, child: const Text('Continue')),
          const SizedBox(height: 12),
          PlButton(
            fullWidth: true,
            variant: PlassVariant.glass,
            onPressed: () {},
            child: const Text('Use another account'),
          ),
        ],
      ),
    );
  }
}
