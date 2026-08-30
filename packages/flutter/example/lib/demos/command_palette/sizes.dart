import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CommandPaletteSizes extends StatefulWidget {
  const CommandPaletteSizes({super.key});

  @override
  State<CommandPaletteSizes> createState() => _CommandPaletteSizesState();
}

class _CommandPaletteSizesState extends State<CommandPaletteSizes> {
  PlassSize? _size;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final PlassSize size in PlassSize.values)
          PlButton(
            size: PlassSize.sm,
            variant: PlassVariant.glass,
            color: PlassColor.secondary,
            onPressed: () => setState(() => _size = size),
            child: Text(size.name),
          ),
        PlCommandPalette(
          open: _size != null,
          shortcut: null,
          size: _size ?? PlassSize.md,
          onOpenChanged: (bool next) => setState(() => _size = next ? _size : null),
          items: const <PlCommandItem>[
            PlCommandItem(value: 'new', label: 'New document'),
            PlCommandItem(value: 'open', label: 'Open…'),
            PlCommandItem(value: 'copy', label: 'Copy'),
          ],
        ),
      ],
    );
  }
}
