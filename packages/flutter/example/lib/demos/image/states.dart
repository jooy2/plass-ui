import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ImageStates extends StatelessWidget {
  const ImageStates({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 420,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PlImage(
                  image: const NetworkImage('/portrait-1.svg'),
                  semanticLabel: 'A portrait',
                  ratio: 1,
                  rounded: true,
                ),
                const SizedBox(height: 8),
                Text('Arrived', style: TextStyle(color: tokens.mutedFg, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // A URL that is not a picture, so this one always fails.
                PlImage(
                  image: const NetworkImage('/does-not-exist.png'),
                  semanticLabel: 'The team, at the 2019 offsite',
                  ratio: 1,
                  rounded: true,
                ),
                const SizedBox(height: 8),
                Text(
                  'Did not — the label is drawn instead',
                  style: TextStyle(color: tokens.mutedFg, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
