import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui_example/demos/portrait.dart';

class ChatBubbleMedia extends StatelessWidget {
  const ChatBubbleMedia({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          const PlChatBubble(
            name: Text('Grace Hopper'),
            media: SizedBox(
              height: 128,
              width: double.infinity,
              child: Image(image: PortraitImage(1, pixels: 512), fit: BoxFit.cover),
            ),
            child: Text('Drawn edge to edge, so the bubble’s own corners crop it.'),
          ),
          PlChatBubble(
            side: PlChatBubbleSide.end,
            variant: PlassVariant.solid,
            preview: PlChatBubbleLinkPreview(
              onPressed: () {},
              site: const Text('plass.cdget.com'),
              title: const Text('Design language'),
              description: const Text(
                'Why a Plass surface looks and behaves the way it does — the tinted-glass '
                'rule and everything that follows from it.',
              ),
            ),
            child: const Text('Here is the page about it.'),
          ),
        ],
      ),
    );
  }
}
