import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SpoilerMedia extends StatelessWidget {
  const SpoilerMedia({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 384,
      child: PlSpoiler(
        padded: false,
        reversible: true,
        label: 'Show anyway',
        description: Text('Sensitive image'),
        child: SizedBox(
          height: 160,
          child: Image(
            image: NetworkImage('/samples/photos/desert-rocks-milky-way.webp'),
            fit: BoxFit.cover,
            semanticLabel: 'The Milky Way over a desert rock formation',
          ),
        ),
      ),
    );
  }
}
