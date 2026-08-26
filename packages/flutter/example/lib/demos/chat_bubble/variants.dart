import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ChatBubbleVariants extends StatelessWidget {
  const ChatBubbleVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final variant in PlassVariant.values)
            PlChatBubble(
              variant: variant,
              name: Text(variant.name),
              child: const Text(
                'A bubble is the thing being coloured, so its sheet takes the tint.',
              ),
            ),
        ],
      ),
    );
  }
}
