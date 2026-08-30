import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A field the form can actually validate.
///
/// A `PlTextField` holds a controller the caller made rather than being a
/// `FormField`, which is the whole point of the difference this component
/// documents — so a test of the *form* uses the framework's own field.
class _Field extends StatelessWidget {
  const _Field({required this.name, this.required = true});

  final String name;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final String? external = PlFormScope.maybeOf(context)?.errorFor(name);

    return FormField<String>(
      initialValue: '',
      validator: (String? value) {
        if (external != null) return external;
        if (required && (value == null || value.isEmpty)) return '$name is required';
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[Text(name), if (state.errorText != null) Text(state.errorText!)],
        );
      },
    );
  }
}

void main() {
  group('PlForm', () {
    testWidgets('stacks its children on the sheet ladder', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlForm(children: <Widget>[Text('One'), Text('Two')]), width: 400, height: 300),
      );

      final Column column = tester.widget<Column>(
        find.descendant(of: find.byType(PlForm), matching: find.byType(Column)).first,
      );

      expect(column.spacing, 12);
    });

    testWidgets('walks that gap up the size ladder', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlForm(size: PlassSize.xl, children: <Widget>[Text('One')]),
          width: 400,
          height: 300,
        ),
      );

      final Column column = tester.widget<Column>(
        find.descendant(of: find.byType(PlForm), matching: find.byType(Column)).first,
      );

      expect(column.spacing, 16);
    });

    testWidgets('draws no surface of its own', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlForm(children: <Widget>[Text('One')]), width: 400, height: 300),
      );

      expect(decorationsOf(tester, find.byType(PlForm)), isEmpty);
    });

    group('submitting', () {
      testWidgets('reports a valid form and nothing else', (WidgetTester tester) async {
        int submitted = 0;
        final GlobalKey<PlFormState> key = GlobalKey<PlFormState>();

        await tester.pumpWidget(
          host(
            PlForm(
              key: key,
              onSubmit: () => submitted += 1,
              children: const <Widget>[_Field(name: 'email', required: false)],
            ),
            width: 400,
            height: 300,
          ),
        );

        expect(key.currentState!.submit(), isTrue);
        expect(submitted, 1);
      });

      testWidgets('does not submit while a field is invalid', (WidgetTester tester) async {
        int submitted = 0;
        final GlobalKey<PlFormState> key = GlobalKey<PlFormState>();

        await tester.pumpWidget(
          host(
            PlForm(
              key: key,
              onSubmit: () => submitted += 1,
              children: const <Widget>[_Field(name: 'email')],
            ),
            width: 400,
            height: 300,
          ),
        );

        expect(key.currentState!.submit(), isFalse);
        expect(submitted, 0);

        await tester.pump();
        expect(find.text('email is required'), findsOneWidget);
      });

      testWidgets('is reachable from a button inside it', (WidgetTester tester) async {
        int submitted = 0;

        await tester.pumpWidget(
          host(
            PlForm(
              onSubmit: () => submitted += 1,
              children: <Widget>[
                const _Field(name: 'email', required: false),
                Builder(
                  builder: (BuildContext context) => PlButton(
                    onPressed: () => PlFormScope.maybeOf(context)?.submit(),
                    child: const Text('Sign in'),
                  ),
                ),
              ],
            ),
            width: 400,
            height: 300,
          ),
        );

        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle();

        expect(submitted, 1);
      });
    });

    group('errors from somewhere else', () {
      testWidgets('hands a field the message that belongs to it', (WidgetTester tester) async {
        final GlobalKey<PlFormState> key = GlobalKey<PlFormState>();

        await tester.pumpWidget(
          host(
            PlForm(
              key: key,
              errors: const <String, String>{'email': 'That address is already registered'},
              children: const <Widget>[_Field(name: 'email', required: false)],
            ),
            width: 400,
            height: 300,
          ),
        );

        key.currentState!.submit();
        await tester.pump();

        expect(find.text('That address is already registered'), findsOneWidget);
      });

      testWidgets('leaves the other fields alone', (WidgetTester tester) async {
        final GlobalKey<PlFormState> key = GlobalKey<PlFormState>();

        await tester.pumpWidget(
          host(
            PlForm(
              key: key,
              errors: const <String, String>{'email': 'Taken'},
              children: const <Widget>[
                _Field(name: 'name', required: false),
                _Field(name: 'email', required: false),
              ],
            ),
            width: 400,
            height: 300,
          ),
        );

        key.currentState!.submit();
        await tester.pump();

        expect(find.text('Taken'), findsOneWidget);
      });

      testWidgets('is readable by anything inside the form', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlForm(
              errors: const <String, String>{'email': 'Taken'},
              children: <Widget>[
                Builder(
                  builder: (BuildContext context) =>
                      Text(PlFormScope.maybeOf(context)?.errorFor('email') ?? 'none'),
                ),
              ],
            ),
            width: 400,
            height: 300,
          ),
        );

        expect(find.text('Taken'), findsOneWidget);
      });
    });

    group('validationMode', () {
      testWidgets('waits for a submit by default', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlForm(children: <Widget>[_Field(name: 'email')]), width: 400, height: 300),
        );

        expect(find.text('email is required'), findsNothing);
      });

      testWidgets('checks as the reader goes when it is told to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlForm(
              validationMode: PlFormValidationMode.onChange,
              children: <Widget>[_Field(name: 'email')],
            ),
            width: 400,
            height: 300,
          ),
        );

        final Form form = tester.widget<Form>(find.byType(Form));

        expect(form.autovalidateMode, AutovalidateMode.onUserInteraction);
      });

      testWidgets('or when a field loses focus', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlForm(
              validationMode: PlFormValidationMode.onBlur,
              children: <Widget>[_Field(name: 'email')],
            ),
            width: 400,
            height: 300,
          ),
        );

        expect(tester.widget<Form>(find.byType(Form)).autovalidateMode, AutovalidateMode.onUnfocus);
      });
    });
  });
}
