import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TabsSizes extends StatelessWidget {
  const TabsSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          for (final size in <PlassSize>[PlassSize.sm, PlassSize.md, PlassSize.lg])
            PlTabs<String>(
              size: size,
              value: 'one',
              onChanged: (String next) {},
              tabs: <PlTab<String>>[
                PlTab<String>(
                  value: 'one',
                  label: Text('size: ${size.name}'),
                  panel: const Text('The tabs take the control height ladder.'),
                ),
                const PlTab<String>(
                  value: 'two',
                  label: Text('Second'),
                  panel: Text('So a tab bar lines up with a button beside it.'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
