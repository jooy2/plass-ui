import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<String> _scopes = <String>['Read', 'Write', 'Delete'];

class CheckboxIndeterminate extends StatefulWidget {
  const CheckboxIndeterminate({super.key});

  @override
  State<CheckboxIndeterminate> createState() => _CheckboxIndeterminateState();
}

class _CheckboxIndeterminateState extends State<CheckboxIndeterminate> {
  Set<String> _granted = <String>{'Read'};

  @override
  Widget build(BuildContext context) {
    final all = _granted.length == _scopes.length;
    final some = _granted.isNotEmpty && !all;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        PlCheckbox(
          value: all,
          indeterminate: some,
          onChanged: (bool next) => setState(() => _granted = next ? _scopes.toSet() : <String>{}),
          label: const Text('All scopes'),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: <Widget>[
              for (final scope in _scopes)
                PlCheckbox(
                  value: _granted.contains(scope),
                  onChanged: (bool next) => setState(() {
                    _granted = <String>{..._granted, if (next) scope}
                      ..removeWhere((String value) => !next && value == scope);
                  }),
                  label: Text(scope),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
