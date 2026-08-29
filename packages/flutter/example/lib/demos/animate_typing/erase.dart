import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateTypingErase extends StatelessWidget {
  const AnimateTypingErase({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTextStyle(
      style: TextStyle(fontFamily: 'monospace', fontSize: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          PlAnimateTyping(
            'rewritten, not replaced',
            speed: 18,
            hold: Duration(milliseconds: 900),
            erase: true,
            repeat: null,
          ),
          PlAnimateTyping(
            'replaced in one frame',
            speed: 18,
            hold: Duration(milliseconds: 900),
            repeat: null,
            caret: false,
          ),
        ],
      ),
    );
  }
}
