import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SpoilerMedia extends StatelessWidget {
  const SpoilerMedia({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 384,
      child: PlSpoiler(
        padded: false,
        reversible: true,
        label: 'Show anyway',
        description: const Text('Sensitive image'),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                tokens.family(PlassColor.danger).soft,
                tokens.family(PlassColor.warning).soft,
              ],
            ),
          ),
          child: const SizedBox(
            height: 160,
            child: Center(child: Text('A photograph somebody has not asked to see')),
          ),
        ),
      ),
    );
  }
}
