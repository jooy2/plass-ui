import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HoverCardDelays extends StatelessWidget {
  const HoverCardDelays({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: <Widget>[
          PlHoverCard(
            title: const Text('Slow to open'),
            trigger: PlTextLink(onPressed: () {}, child: const Text('600ms, the default')),
            child: const Text('Long enough not to fire at every link a pointer passes.'),
          ),
          PlHoverCard(
            delay: const Duration(milliseconds: 120),
            title: const Text('Quick to open'),
            trigger: PlTextLink(onPressed: () {}, child: const Text('120ms')),
            child: const Text('For a page whose links are all previews, and only there.'),
          ),
        ],
      ),
    );
  }
}
