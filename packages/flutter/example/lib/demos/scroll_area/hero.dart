import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ScrollAreaHero extends StatelessWidget {
  const ScrollAreaHero({super.key});

  static const List<String> _notes = <String>[
    'Tags can be renamed from the sidebar.',
    'The export dialog remembers the last format you used.',
    'Keyboard shortcuts work while a dialog is open.',
    'A saved filter can be shared with a link.',
    'Bulk actions ask before they delete anything.',
    'The table remembers its column widths per project.',
    'Comments can be resolved without deleting them.',
    'Search matches inside attachments as well as titles.',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 360,
      child: PlCard(
        child: PlScrollArea(
          height: 200,
          label: 'Release notes',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final String note in _notes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, right: 12),
                  child: Text(note, style: TextStyle(color: tokens.fg, fontSize: 14)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
