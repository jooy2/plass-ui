import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<({String value, String name, String team})> _people =
    <({String value, String name, String team})>[
      (value: 'mina', name: 'Mina Park', team: 'Design'),
      (value: 'jonas', name: 'Jonas Weber', team: 'Platform'),
      (value: 'amara', name: 'Amara Okafor', team: 'Research'),
      (value: 'leo', name: 'Leo Rossi', team: 'Support'),
    ];

class ComboboxContent extends StatefulWidget {
  const ComboboxContent({super.key});

  @override
  State<ComboboxContent> createState() => _ComboboxContentState();
}

class _ComboboxContentState extends State<ComboboxContent> {
  String? _assignee;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final List<PlComboboxOption<String>> assignees = <PlComboboxOption<String>>[
      for (final person in _people)
        PlComboboxOption<String>(
          value: person.value,
          label: person.name,
          content: Row(
            spacing: 8,
            children: <Widget>[
              // The name is said beside it, so the picture is not said again.
              ExcludeSemantics(
                child: PlAvatar(size: PlassSize.xs, name: person.name),
              ),
              Expanded(child: Text(person.name)),
              Text(person.team, style: TextStyle(color: tokens.mutedFg)),
            ],
          ),
        ),
    ];

    return SizedBox(
      width: 360,
      child: PlCombobox<String>(
        fullWidth: true,
        label: const Text('Assignee'),
        placeholder: 'Search people…',
        options: assignees,
        value: _assignee,
        onChanged: (String? next) => setState(() => _assignee = next),
      ),
    );
  }
}
