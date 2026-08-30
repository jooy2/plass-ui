import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CommandPaletteGroups extends StatefulWidget {
  const CommandPaletteGroups({super.key});

  @override
  State<CommandPaletteGroups> createState() => _CommandPaletteGroupsState();
}

class _CommandPaletteGroupsState extends State<CommandPaletteGroups> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: <Widget>[
        PlButton(
          variant: PlassVariant.glass,
          color: PlassColor.secondary,
          onPressed: () => setState(() => _open = true),
          child: const Text('Try “load”, or “distraction”'),
        ),
        PlCommandPalette(
          open: _open,
          shortcut: null,
          onOpenChanged: (bool next) => setState(() => _open = next),
          items: const <PlCommandItem>[
            PlCommandItem(value: 'new', label: 'New document', group: 'File'),
            PlCommandItem(
              value: 'open',
              label: 'Open…',
              group: 'File',
              keywords: <String>['load', 'import'],
            ),
            PlCommandItem(
              value: 'copy',
              label: 'Copy',
              group: 'Edit',
              description: 'Put it on the clipboard',
            ),
            PlCommandItem(value: 'paste', label: 'Paste', group: 'Edit', disabled: true),
            PlCommandItem(
              value: 'zen',
              label: 'Zen mode',
              group: 'View',
              keywords: <String>['focus', 'distraction free'],
            ),
          ],
        ),
      ],
    );
  }
}
