import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextFieldLabelPlacement extends StatelessWidget {
  const TextFieldLabelPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: <Widget>[
          PlTextField(fullWidth: true, label: Text('Email'), placeholder: 'you@example.com'),
          PlTextField(
            fullWidth: true,
            label: Text('Email'),
            labelPlacement: PlassFieldLabelPlacement.notch,
            placeholder: 'you@example.com',
          ),
          PlTextField(
            fullWidth: true,
            variant: PlassVariant.solid,
            label: Text('Password'),
            labelPlacement: PlassFieldLabelPlacement.notch,
            obscureText: true,
          ),
          PlTextField(
            fullWidth: true,
            multiline: true,
            rows: 3,
            label: Text('Note'),
            labelPlacement: PlassFieldLabelPlacement.notch,
            description: Text('A notch works the same on a multiline field.'),
          ),
        ],
      ),
    );
  }
}
