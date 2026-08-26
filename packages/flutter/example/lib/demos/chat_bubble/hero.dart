import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui_example/demos/portrait.dart';

class ChatBubbleHero extends StatelessWidget {
  const ChatBubbleHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          const PlChatBubble(
            name: Text('Ada Lovelace'),
            time: Text('09:12'),
            avatar: PlAvatar(size: PlassSize.sm, name: 'Ada Lovelace', image: PortraitImage(0)),
            child: Text('The gradient turns rather than shades. Have a look at the new fills.'),
          ),
          const PlChatBubble(
            side: PlChatBubbleSide.end,
            variant: PlassVariant.solid,
            time: Text('09:14'),
            status: PlChatBubbleStatus.read,
            child: Text('Already did — the vermilion one is much better.'),
          ),
          const PlChatBubble(
            typing: true,
            avatar: PlAvatar(size: PlassSize.sm, name: 'Ada Lovelace', image: PortraitImage(0)),
          ),
        ],
      ),
    );
  }
}
