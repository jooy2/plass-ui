import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextFieldControlled extends StatefulWidget {
  const TextFieldControlled({super.key});

  @override
  State<TextFieldControlled> createState() => _TextFieldControlledState();
}

class _TextFieldControlledState extends State<TextFieldControlled> {
  final TextEditingController _name = TextEditingController();
  int _length = 0;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: <Widget>[
          PlTextField(
            fullWidth: true,
            controller: _name,
            label: const Text('Display name'),
            placeholder: 'Ada Lovelace',
            maxLength: 24,
            // Counted the way `maxLength` counts, so an emoji is one character
            // rather than two or more.
            onChanged: (String next) => setState(() => _length = next.characters.length),
          ),
          PlTypography('$_length/24', level: PlTypographyLevel.caption),
        ],
      ),
    );
  }
}
