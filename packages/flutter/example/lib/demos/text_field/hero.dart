import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextFieldHero extends StatefulWidget {
  const TextFieldHero({super.key});

  @override
  State<TextFieldHero> createState() => _TextFieldHeroState();
}

class _TextFieldHeroState extends State<TextFieldHero> {
  final TextEditingController _email = TextEditingController(text: 'not-an-email');

  @override
  void dispose() {
    _email.dispose();
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
          const PlTextField(
            fullWidth: true,
            label: Text('Workspace'),
            placeholder: 'acme-inc',
            description: Text('Used in your URL.'),
          ),
          PlTextField(
            fullWidth: true,
            controller: _email,
            label: const Text('Email'),
            keyboardType: TextInputType.emailAddress,
            error: const Text('Enter a valid address.'),
          ),
        ],
      ),
    );
  }
}
