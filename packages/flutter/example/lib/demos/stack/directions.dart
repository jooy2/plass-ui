import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class StackDirections extends StatelessWidget {
  const StackDirections({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 40,
      runSpacing: 40,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final PlStackDirection direction in PlStackDirection.values)
          PlStack(
            direction: PlassResponsive<PlStackDirection>(direction),
            overlap: 14,
            children: const <Widget>[
              PlChip(variant: PlassVariant.solid, color: PlassColor.secondary, child: Text('One')),
              PlChip(variant: PlassVariant.solid, color: PlassColor.secondary, child: Text('Two')),
              PlChip(
                variant: PlassVariant.solid,
                color: PlassColor.secondary,
                child: Text('Three'),
              ),
            ],
          ),
      ],
    );
  }
}
