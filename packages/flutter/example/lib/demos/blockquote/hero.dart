import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BlockquoteHero extends StatelessWidget {
  const BlockquoteHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: <Widget>[
          PlBlockquote(
            author: Text('Antoine de Saint-Exupéry'),
            source: Text('Terre des hommes'),
            child: Text(
              'Perfection is achieved not when there is nothing more to add, but when there '
              'is nothing left to take away.',
            ),
          ),
          PlBlockquote(
            variant: PlassVariant.glass,
            color: PlassColor.info,
            showIcon: false,
            child: Text(
              'A gradient that turns is a piece of tinted glass, and it needs nothing else.',
            ),
          ),
        ],
      ),
    );
  }
}
