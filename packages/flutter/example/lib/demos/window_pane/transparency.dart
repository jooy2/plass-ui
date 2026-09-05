import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class WindowPaneTransparency extends StatelessWidget {
  const WindowPaneTransparency({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return Column(
      spacing: 24,
      children: <Widget>[
        for (final double transparency in <double>[0, 0.45])
          PlWindowPane(
            os: PlWindowOs.windows7,
            title: Text(transparency == 0 ? 'Opaque' : 'Translucent'),
            transparency: transparency,
            height: 130,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'The content stays exactly as legible as it was.',
                style: TextStyle(fontSize: 14, color: tokens.mutedFg),
              ),
            ),
          ),
      ],
    );
  }
}
