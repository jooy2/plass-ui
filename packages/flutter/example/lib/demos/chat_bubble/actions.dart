import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ChatBubbleActions extends StatelessWidget {
  const ChatBubbleActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlChatBubble(
        name: const Text('Ada Lovelace'),
        actions: PlButton(
          size: PlassSize.xs,
          variant: PlassVariant.ghost,
          color: PlassColor.secondary,
          semanticLabel: 'More',
          onPressed: () {},
          child: const Text('⋯'),
        ),
        child: const Text('The handle sits beside the message, and stays there.'),
      ),
    );
  }
}
