import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextFieldMultiline extends StatelessWidget {
  const TextFieldMultiline({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          PlTextField(
            fullWidth: true,
            multiline: true,
            rows: 1,
            label: Text('One row'),
            placeholder: 'Exactly a single-line field',
          ),
          PlTextField(
            fullWidth: true,
            multiline: true,
            rows: 4,
            label: Text('Release note'),
            description: Text('Markdown is not rendered here.'),
          ),
        ],
      ),
    );
  }
}
