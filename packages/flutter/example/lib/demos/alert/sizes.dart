import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AlertSizes extends StatelessWidget {
  const AlertSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final size in <PlassSize>[PlassSize.sm, PlassSize.md, PlassSize.lg])
            PlAlert(
              size: size,
              title: Text('size: ${size.name}'),
              child: const Text('The glyph, the title and the message move together.'),
            ),
        ],
      ),
    );
  }
}
