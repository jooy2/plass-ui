import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class WindowPaneOs extends StatelessWidget {
  const WindowPaneOs({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return Column(
      spacing: 24,
      children: <Widget>[
        for (final PlWindowOs os in PlWindowOs.values)
          PlWindowPane(
            os: os,
            title: Text(os.name),
            height: 110,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(os.name, style: TextStyle(fontSize: 14, color: tokens.mutedFg)),
            ),
          ),
      ],
    );
  }
}
