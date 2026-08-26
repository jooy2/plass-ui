import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextFieldSizes extends StatelessWidget {
  const TextFieldSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final size in PlassSize.values)
            PlTextField(fullWidth: true, size: size, placeholder: size.name),
        ],
      ),
    );
  }
}
