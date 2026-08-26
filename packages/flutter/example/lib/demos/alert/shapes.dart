import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AlertShapes extends StatelessWidget {
  const AlertShapes({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          PlAlert(showIcon: false, child: Text('A bare line, for a note among form fields.')),
          PlAlert(child: Text('A line with the severity glyph — the default.')),
          PlAlert(
            title: Text('A headline'),
            child: Text('And the detail under it, in the muted ink.'),
          ),
        ],
      ),
    );
  }
}
