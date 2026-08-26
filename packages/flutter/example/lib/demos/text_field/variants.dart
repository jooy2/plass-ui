import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextFieldVariants extends StatelessWidget {
  const TextFieldVariants({super.key});

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
            label: Text('glass'),
            placeholder: 'A sheet with a hairline',
          ),
          PlTextField(
            fullWidth: true,
            variant: PlassVariant.solid,
            label: Text('solid'),
            placeholder: 'A well cut into the sheet',
          ),
          PlTextField(
            fullWidth: true,
            variant: PlassVariant.ghost,
            label: Text('ghost'),
            placeholder: 'No surface until you go near it',
          ),
        ],
      ),
    );
  }
}
