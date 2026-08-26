import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AlertHero extends StatelessWidget {
  const AlertHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          const PlAlert(color: PlassColor.success, child: Text('Your changes are live.')),
          PlAlert(
            color: PlassColor.danger,
            title: const Text('The deploy failed'),
            action: PlButton(
              size: PlassSize.xs,
              variant: PlassVariant.ghost,
              color: PlassColor.danger,
              onPressed: () {},
              child: const Text('Retry'),
            ),
            child: const Text('Two of the health checks never came back.'),
          ),
        ],
      ),
    );
  }
}
