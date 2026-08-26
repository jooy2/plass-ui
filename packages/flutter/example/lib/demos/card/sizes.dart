import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CardSizes extends StatelessWidget {
  const CardSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final size in <PlassSize>[PlassSize.sm, PlassSize.md, PlassSize.lg])
            PlCard(
              size: size,
              title: Text('size: ${size.name}'),
              subtitle: const Text('Title, subtitle, body'),
              child: const Text('The radius, the type scale and the padding move together.'),
            ),
        ],
      ),
    );
  }
}
