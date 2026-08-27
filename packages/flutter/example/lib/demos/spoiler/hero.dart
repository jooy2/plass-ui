import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SpoilerHero extends StatelessWidget {
  const SpoilerHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 448,
      child: PlSpoiler(
        reversible: true,
        child: Text(
          'Rosebud was the name painted on the sled he had as a child, and it is thrown '
          'into the furnace in the last shot of the film.',
        ),
      ),
    );
  }
}
