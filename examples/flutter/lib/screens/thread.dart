import 'package:flutter/widgets.dart';
import 'package:plass_showcase/app/page.dart';
import 'package:plass_showcase/data/sample.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

/// One conversation, with a composer that stays above the keyboard.
class ThreadScreen extends StatefulWidget {
  /// Creates the screen.
  const ThreadScreen({required this.conversation, super.key});

  /// What is shown.
  final Conversation conversation;

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final TextEditingController _draft = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<String> _sent = <String>[];

  @override
  void dispose() {
    _draft.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _draft.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() => _sent.add(text));
    _draft.clear();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.conversation.person;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final safe = MediaQuery.paddingOf(context);
    final avatar = PlAvatar(
      size: PlassSize.sm,
      name: person.name,
      image: person.image == null ? null : AssetImage(person.image!),
    );

    return PushedScreen(
      title: person.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: <Widget>[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: contentWidth),
                    child: Column(
                      spacing: 16,
                      children: <Widget>[
                        PlChatBubble(
                          name: Text(person.name),
                          time: Text(widget.conversation.time),
                          avatar: avatar,
                          child: Text(widget.conversation.preview),
                        ),
                        const PlChatBubble(
                          side: PlChatBubbleSide.end,
                          variant: PlassVariant.solid,
                          time: Text('09:14'),
                          status: PlChatBubbleStatus.read,
                          child: Text('Already did. The vermilion one is much better.'),
                        ),
                        PlChatBubble(
                          avatar: avatar,
                          time: const Text('09:15'),
                          child: const Text('Good. I will ship it this afternoon.'),
                        ),
                        for (final String text in _sent)
                          PlChatBubble(
                            side: PlChatBubbleSide.end,
                            variant: PlassVariant.solid,
                            status: PlChatBubbleStatus.sent,
                            child: Text(text),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + (keyboard > 0 ? keyboard : safe.bottom)),
            child: Row(
              spacing: 8,
              children: <Widget>[
                Expanded(
                  child: PlTextField(
                    fullWidth: true,
                    controller: _draft,
                    placeholder: 'Write a reply',
                    semanticLabel: 'Reply',
                    onSubmitted: (String _) => _send(),
                  ),
                ),
                PlIconButton(label: 'Send', icon: const ShareGlyph(), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
