import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextFieldStates extends StatefulWidget {
  const TextFieldStates({super.key});

  @override
  State<TextFieldStates> createState() => _TextFieldStatesState();
}

class _TextFieldStatesState extends State<TextFieldStates> {
  final List<TextEditingController> _filled = <TextEditingController>[
    TextEditingController(text: 'acme-inc'),
    TextEditingController(text: 'acme-inc'),
    TextEditingController(text: 'acme-inc'),
  ];

  @override
  void dispose() {
    for (final controller in _filled) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          const PlTextField(fullWidth: true, label: Text('Idle'), placeholder: 'Type here'),
          PlTextField(
            fullWidth: true,
            controller: _filled[0],
            label: const Text('Loading'),
            loading: true,
          ),
          PlTextField(
            fullWidth: true,
            controller: _filled[1],
            label: const Text('Read-only'),
            readOnly: true,
          ),
          PlTextField(
            fullWidth: true,
            controller: _filled[2],
            label: const Text('Disabled'),
            disabled: true,
          ),
        ],
      ),
    );
  }
}
