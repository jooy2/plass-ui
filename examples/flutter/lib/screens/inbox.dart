import 'package:flutter/widgets.dart';
import 'package:plass_showcase/app/page.dart';
import 'package:plass_showcase/data/sample.dart';
import 'package:plass_showcase/screens/thread.dart';
import 'package:plass_ui/plass_ui.dart';

/// The conversations, with a search and a filter.
class InboxScreen extends StatefulWidget {
  /// Creates the screen.
  const InboxScreen({required this.bottomInset, super.key});

  /// Room held under the content for the bottom bar.
  final double bottomInset;

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final TextEditingController _search = TextEditingController();
  bool _unreadOnly = false;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final found = conversations.where((Conversation one) {
      final matches =
          query.isEmpty ||
          one.person.name.toLowerCase().contains(query) ||
          one.subject.toLowerCase().contains(query);

      return matches && (!_unreadOnly || one.unread > 0);
    }).toList();

    return ScreenScroll(
      title: 'Inbox',
      subtitle: '${conversations.length} conversations',
      bottomInset: widget.bottomInset,
      children: <Widget>[
        PlTextField(
          fullWidth: true,
          controller: _search,
          placeholder: 'Search people and subjects',
          semanticLabel: 'Search',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            PlChip(
              selected: !_unreadOnly,
              onPressed: () => setState(() => _unreadOnly = false),
              child: const Text('All'),
            ),
            PlChip(
              selected: _unreadOnly,
              onPressed: () => setState(() => _unreadOnly = true),
              count: const Text('2'),
              child: const Text('Unread'),
            ),
          ],
        ),
        if (found.isEmpty)
          PlCard(
            child: PlEmpty(
              title: const Text('Nothing found'),
              description: const Text('Try another name or subject.'),
              actions: <Widget>[
                PlButton(
                  variant: PlassVariant.glass,
                  onPressed: () {
                    _search.clear();
                    setState(() => _unreadOnly = false);
                  },
                  child: const Text('Clear the search'),
                ),
              ],
            ),
          )
        else
          PlCard(
            child: PlList(
              dividers: true,
              children: <Widget>[
                for (final Conversation one in found)
                  PlListItem(
                    startIcon: PlAvatar(
                      size: PlassSize.sm,
                      name: one.person.name,
                      image: one.person.image == null ? null : AssetImage(one.person.image!),
                    ),
                    description: Text(one.subject, maxLines: 1, overflow: TextOverflow.ellipsis),
                    endIcon: one.unread > 0
                        ? PlBadge(size: PlassSize.xs, count: one.unread)
                        : Text(one.time),
                    onPressed: () => Navigator.of(context).push(
                      ShowcaseRoute<void>(
                        builder: (BuildContext context) => ThreadScreen(conversation: one),
                      ),
                    ),
                    child: Text(one.person.name),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
