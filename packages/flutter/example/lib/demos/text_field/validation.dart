import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextFieldValidation extends StatefulWidget {
  const TextFieldValidation({super.key});

  @override
  State<TextFieldValidation> createState() => _TextFieldValidationState();
}

class _TextFieldValidationState extends State<TextFieldValidation> {
  final TextEditingController _workspace = TextEditingController(text: 'acme inc');
  String _value = 'acme inc';

  @override
  void dispose() {
    _workspace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invalid = _value.contains(' ');

    return SizedBox(
      width: 384,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 12,
        children: <Widget>[
          Expanded(
            child: PlTextField(
              fullWidth: true,
              controller: _workspace,
              label: const Text('Workspace'),
              onChanged: (String next) => setState(() => _value = next),
              error: invalid ? const Text('Spaces are not allowed.') : null,
              description: invalid ? null : const Text('Letters, numbers and dashes.'),
            ),
          ),
          PlButton(disabled: invalid, onPressed: () {}, child: const Text('Create')),
        ],
      ),
    );
  }
}
