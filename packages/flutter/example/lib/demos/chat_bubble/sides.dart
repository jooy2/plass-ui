import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ChatBubbleSides extends StatelessWidget {
  const ChatBubbleSides({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          PlChatBubble(child: Text('Theirs, at the start. The near corner is cut short.')),
          PlChatBubble(
            side: PlChatBubbleSide.end,
            variant: PlassVariant.solid,
            child: Text('Yours, at the end. The other corner is.'),
          ),
        ],
      ),
    );
  }
}
