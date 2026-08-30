import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class FormErrors extends StatefulWidget {
  const FormErrors({super.key});

  @override
  State<FormErrors> createState() => _FormErrorsState();
}

class _FormErrorsState extends State<FormErrors> {
  final TextEditingController _username = TextEditingController(text: 'ada');
  final GlobalKey<PlFormState> _form = GlobalKey<PlFormState>();
  Map<String, String> _errors = const <String, String>{};

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: PlForm(
        key: _form,
        errors: _errors,
        onSubmit: () {},
        children: <Widget>[
          Builder(
            builder: (BuildContext context) {
              final String? external = PlFormScope.maybeOf(context)?.errorFor('username');

              return FormField<String>(
                validator: (String? _) => external,
                builder: (FormFieldState<String> state) => PlTextField(
                  controller: _username,
                  label: const Text('Username'),
                  description: const Text('Try “ada”, which the server will refuse.'),
                  fullWidth: true,
                  error: state.errorText == null ? null : Text(state.errorText!),
                ),
              );
            },
          ),
          PlButton(
            onPressed: () {
              // What a server would have answered.
              setState(() {
                _errors = _username.text == 'ada'
                    ? const <String, String>{'username': 'That name is already taken'}
                    : const <String, String>{};
              });
              WidgetsBinding.instance.addPostFrameCallback((_) => _form.currentState?.submit());
            },
            child: const Text('Create account'),
          ),
        ],
      ),
    );
  }
}
