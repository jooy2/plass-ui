import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class EmptyHero extends StatelessWidget {
  const EmptyHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: PlCard(
        child: PlEmpty(
          icon: const SizedBox.square(
            dimension: 128,
            child: Image(
              image: NetworkImage('/samples/illustrations/fox-reading-under-tree.webp'),
              fit: BoxFit.contain,
            ),
          ),
          title: const Text('No projects yet'),
          description: const Text(
            'Start one and it will show up here, with everyone you invite to it.',
          ),
          actions: <Widget>[PlButton(onPressed: () {}, child: const Text('New project'))],
        ),
      ),
    );
  }
}
