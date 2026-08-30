import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CommandPaletteHero extends StatefulWidget {
  const CommandPaletteHero({super.key});

  @override
  State<CommandPaletteHero> createState() => _CommandPaletteHeroState();
}

class _CommandPaletteHeroState extends State<CommandPaletteHero> {
  bool _open = false;
  String? _ran;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        PlButton(
          onPressed: () => setState(() => _open = true),
          child: const Text('Open the palette'),
        ),
        Text('…or press ⌘K / Ctrl+K.', style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
        if (_ran != null) PlAlert(color: PlassColor.success, child: Text('Ran $_ran')),
        PlCommandPalette(
          open: _open,
          onOpenChanged: (bool next) => setState(() => _open = next),
          onSelect: (PlCommandItem item) => setState(() => _ran = item.label),
          items: const <PlCommandItem>[
            PlCommandItem(value: 'new', label: 'New document', group: 'File', shortcut: 'Mod+N'),
            PlCommandItem(
              value: 'open',
              label: 'Open…',
              group: 'File',
              shortcut: 'Mod+O',
              keywords: <String>['load'],
            ),
            PlCommandItem(
              value: 'export',
              label: 'Export as PDF',
              group: 'File',
              description: 'The whole document',
            ),
            PlCommandItem(value: 'copy', label: 'Copy', group: 'Edit', shortcut: 'Mod+C'),
            PlCommandItem(value: 'find', label: 'Find in page', group: 'Edit', shortcut: 'Mod+F'),
            PlCommandItem(value: 'theme', label: 'Toggle dark mode', group: 'View'),
          ],
        ),
      ],
    );
  }
}
