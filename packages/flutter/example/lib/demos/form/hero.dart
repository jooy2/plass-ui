import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class FormHero extends StatefulWidget {
  const FormHero({super.key});

  @override
  State<FormHero> createState() => _FormHeroState();
}

class _FormHeroState extends State<FormHero> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<PlFormState> _form = GlobalKey<PlFormState>();
  String? _submitted;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: PlForm(
        key: _form,
        onSubmit: () => setState(() => _submitted = _email.text),
        children: <Widget>[
          _Required(
            name: 'email',
            controller: _email,
            label: 'Email',
            placeholder: 'ada@example.com',
          ),
          _Required(name: 'password', controller: _password, label: 'Password', obscure: true),
          PlButton(
            fullWidth: true,
            onPressed: () => _form.currentState?.submit(),
            child: const Text('Sign in'),
          ),
          if (_submitted != null)
            PlAlert(color: PlassColor.success, child: Text('Signed in as $_submitted')),
        ],
      ),
    );
  }
}

/// A Plass field wired into the form's validity.
///
/// A `PlTextField` holds a controller rather than being a `FormField`, so the
/// two are put together here — which is the seam `PlForm` documents.
class _Required extends StatelessWidget {
  const _Required({
    required this.name,
    required this.controller,
    required this.label,
    this.placeholder,
    this.obscure = false,
  });

  final String name;
  final TextEditingController controller;
  final String label;
  final String? placeholder;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final String? external = PlFormScope.maybeOf(context)?.errorFor(name);

    return FormField<String>(
      initialValue: controller.text,
      validator: (String? _) {
        if (external != null) return external;
        return controller.text.isEmpty ? '$label is required' : null;
      },
      builder: (FormFieldState<String> state) {
        return PlTextField(
          controller: controller,
          label: Text(label),
          placeholder: placeholder,
          obscureText: obscure,
          fullWidth: true,
          error: state.errorText == null ? null : Text(state.errorText!),
          onChanged: state.didChange,
        );
      },
    );
  }
}
