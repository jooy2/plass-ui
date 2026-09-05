import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/toggles.dart';

const List<(String, String, String)> _mailboxes = <(String, String, String)>[
  ('inbox', 'Inbox', 'Three unread'),
  ('drafts', 'Drafts', 'One saved'),
  ('archive', 'Archive', 'Everything else'),
];

class ListHero extends StatefulWidget {
  const ListHero({super.key});

  @override
  State<ListHero> createState() => _ListHeroState();
}

class _ListHeroState extends State<ListHero> {
  String _selected = 'inbox';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: <Widget>[
          PlList(
            children: <Widget>[
              for (final (String id, String label, String description) in _mailboxes)
                PlListItem(
                  description: Text(description),
                  selected: _selected == id,
                  onPressed: () => setState(() => _selected = id),
                  endIcon: id == 'inbox'
                      ? const PlBadge(size: PlassSize.xs, variant: PlassVariant.ghost, count: 3)
                      : null,
                  child: Text(label),
                ),
            ],
          ),
          Toggles(
            initial: const <String, bool>{'nadia': true},
            builder: (BuildContext context, ToggleState state) {
              return PlList(
                dividers: true,
                children: <Widget>[
                  PlListItem(
                    startIcon: const PlAvatar(
                      size: PlassSize.xs,
                      name: 'Nadia Rowan',
                      image: NetworkImage('/samples/avatars/nadia-rowan.webp'),
                    ),
                    description: const Text('nadia@example.com'),
                    action: PlSwitch(
                      size: PlassSize.sm,
                      value: state['nadia'],
                      onChanged: (bool next) => state.set('nadia', next),
                      semanticLabel: 'Notify Nadia',
                    ),
                    child: const Text('Nadia Rowan'),
                  ),
                  PlListItem(
                    startIcon: const PlAvatar(
                      size: PlassSize.xs,
                      name: 'Theo Quinn',
                      image: NetworkImage('/samples/avatars/theo-quinn.webp'),
                    ),
                    description: const Text('theo@example.com'),
                    action: PlSwitch(
                      size: PlassSize.sm,
                      value: state['theo'],
                      onChanged: (bool next) => state.set('theo', next),
                      semanticLabel: 'Notify Theo',
                    ),
                    child: const Text('Theo Quinn'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
