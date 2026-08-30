/// A form that knows which of its fields is wrong.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/types.dart';

/// When a field decides whether it is valid.
///
/// The React package's own three, kept under the same names so a reader who has
/// learned one build has learned the other. Each maps onto a Flutter
/// [AutovalidateMode].
enum PlFormValidationMode {
  /// On submit, and on every change afterwards.
  ///
  /// The default, and the only one of the three that does not tell somebody
  /// their email is wrong while they are still typing it.
  onSubmit,

  /// When a field loses focus.
  onBlur,

  /// On every change.
  onChange,
}

/// What a field and a submit button read off the [PlForm] around them.
///
/// Exported rather than internal, which is the one thing this package does
/// differently from the React build and the reason is in [PlForm]'s own
/// documentation: a field here is not part of a native form, so the wiring that
/// is automatic on the web has to be something a caller can reach.
class PlFormScope extends InheritedWidget {
  /// Wraps a form's children.
  const PlFormScope({required this.errors, required this.submit, required super.child, super.key});

  /// Errors from outside — a server, a schema — keyed by a field's name.
  final Map<String, String> errors;

  /// Validates every [FormField] in the form and, if they all pass, calls the
  /// form's `onSubmit`. Returns whether it did.
  final bool Function() submit;

  /// The message for the field called [name], or `null` when there is none.
  String? errorFor(String name) => errors[name];

  /// The form above [context], or `null` when there is not one.
  static PlFormScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlFormScope>();
  }

  @override
  bool updateShouldNotify(PlFormScope oldWidget) => errors != oldWidget.errors;
}

/// A form that knows which of its fields is wrong.
///
/// ```dart
/// PlForm(
///   errors: errors,
///   onSubmit: save,
///   children: <Widget>[
///     PlTextField(controller: email, label: const Text('Email')),
///     PlButton(onPressed: () => PlFormScope.maybeOf(context)?.submit(), child: const Text('Sign in')),
///   ],
/// )
/// ```
///
/// What it owns is the part that cannot live on a single field: a submit that
/// collects every [FormField]'s validity at once, and `errors` — an answer from
/// outside the app's own validation, keyed by the name of the field it belongs
/// to.
///
/// It is **not a form library**. There is no schema, no resolver and no field
/// array here; a project that has those hands the result to [errors], which is
/// the seam this is built around. It draws no surface either — a form is a
/// stack of controls, and the sheet is a [PlCard] when one is wanted.
///
/// **Two things are said differently from the React build**, and both are the
/// same fact: there is no native form here. On the web a field's `name` puts it
/// in the submission and its constraint validation is the browser's, so the
/// form can collect values and route messages on its own. Here a field is a
/// widget holding a controller the caller already has, so `onSubmit` reports
/// *that the form is valid* rather than a map of values, and a field is given
/// its message by the caller reading [PlFormScope.errorFor].
class PlForm extends StatefulWidget {
  /// Creates a form.
  const PlForm({
    required this.children,
    this.errors = const <String, String>{},
    this.onSubmit,
    this.validationMode = PlFormValidationMode.onSubmit,
    this.size = PlassSize.md,
    super.key,
  });

  /// The fields, and the button that submits them.
  final List<Widget> children;

  /// Errors from outside the app's own validation — a server, a schema — keyed
  /// by the name of the field each belongs to.
  ///
  /// Read with [PlFormScope.errorFor] and handed to a field's `error`.
  final Map<String, String> errors;

  /// Called on a valid submit.
  ///
  /// With no values, and that is the difference from the React build: a field
  /// here holds a controller the caller made, so the caller already has them.
  final VoidCallback? onSubmit;

  /// When a [FormField] inside decides whether it is valid.
  final PlFormValidationMode validationMode;

  /// The gap between the form's children. A form is a stack, and this is which
  /// rung of the ladder it stacks on.
  final PlassSize size;

  @override
  State<PlForm> createState() => PlFormState();
}

/// The state of a [PlForm], for a caller holding a `GlobalKey<PlFormState>`.
class PlFormState extends State<PlForm> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  /// Validates every [FormField] in the form and, if they all pass, calls
  /// [PlForm.onSubmit]. Returns whether it did.
  bool submit() {
    final bool valid = _form.currentState?.validate() ?? true;

    if (valid) {
      widget.onSubmit?.call();
    }

    return valid;
  }

  AutovalidateMode get _mode {
    switch (widget.validationMode) {
      case PlFormValidationMode.onSubmit:
        return AutovalidateMode.disabled;
      case PlFormValidationMode.onBlur:
        return AutovalidateMode.onUnfocus;
      case PlFormValidationMode.onChange:
        return AutovalidateMode.onUserInteraction;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlFormScope(
      errors: widget.errors,
      submit: submit,
      child: Form(
        key: _form,
        autovalidateMode: _mode,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: sheetSectionGap[widget.size]!,
          children: widget.children,
        ),
      ),
    );
  }
}
