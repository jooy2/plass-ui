import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class WindowPaneAccent extends StatelessWidget {
  const WindowPaneAccent({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return Column(
      spacing: 24,
      children: <Widget>[
        PlWindowPane(
          os: PlWindowOs.windows11,
          title: const Text('In front'),
          accent: true,
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('accent, active', style: TextStyle(fontSize: 14, color: tokens.mutedFg)),
          ),
        ),
        PlWindowPane(
          os: PlWindowOs.windows11,
          title: const Text('Behind'),
          active: false,
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'its colour drains and its shadow drops a step',
              style: TextStyle(fontSize: 14, color: tokens.mutedFg),
            ),
          ),
        ),
      ],
    );
  }
}
