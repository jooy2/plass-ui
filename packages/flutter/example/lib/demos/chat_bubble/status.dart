import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ChatBubbleStatus extends StatelessWidget {
  const ChatBubbleStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final status in PlChatBubbleStatus.values)
            PlChatBubble(
              side: PlChatBubbleSide.end,
              variant: PlassVariant.solid,
              status: status,
              child: Text(status.name),
            ),
        ],
      ),
    );
  }
}
