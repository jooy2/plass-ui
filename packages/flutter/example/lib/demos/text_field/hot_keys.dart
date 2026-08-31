import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextFieldHotKeys extends StatefulWidget {
  const TextFieldHotKeys({super.key});

  @override
  State<TextFieldHotKeys> createState() => _TextFieldHotKeysState();
}

class _TextFieldHotKeysState extends State<TextFieldHotKeys> {
  final TextEditingController _note = TextEditingController();
  String? _saved;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          PlTextField(
            fullWidth: true,
            multiline: true,
            rows: 3,
            controller: _note,
            label: const Text('Note'),
            placeholder: 'Write something, then press the shortcut',
            description: const Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: <Widget>[
                PlHotKeys(keys: 'Mod+Enter', size: PlassSize.xs),
                Text('to save,'),
                PlHotKeys(keys: 'Escape', size: PlassSize.xs),
                Text('to clear'),
              ],
            ),
            hotKeys: <String, VoidCallback>{
              'Mod+Enter': () => setState(() => _saved = _note.text),
              'Escape': () => setState(() {
                _note.clear();
                _saved = null;
              }),
            },
          ),
          PlTypography(
            _saved == null ? 'Nothing saved yet.' : 'Saved: $_saved',
            level: PlTypographyLevel.caption,
          ),
        ],
      ),
    );
  }
}
