import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ChatBubbleSizes extends StatelessWidget {
  const ChatBubbleSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final size in PlassSize.values)
            PlChatBubble(
              size: size,
              name: Text(size.name),
              time: const Text('09:12'),
              child: const Text('The corner cut is a flat 4px at every step.'),
            ),
        ],
      ),
    );
  }
}
