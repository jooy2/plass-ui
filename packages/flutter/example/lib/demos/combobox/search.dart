import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<({String value, String label, List<String> names})> _cities =
    <({String value, String label, List<String> names})>[
      (value: 'munich', label: 'München', names: <String>['munich']),
      (value: 'vienna', label: 'Wien', names: <String>['vienna']),
      (value: 'lisbon', label: 'Lisboa', names: <String>['lisbon']),
      (value: 'cologne', label: 'Köln', names: <String>['cologne']),
      (value: 'prague', label: 'Praha', names: <String>['prague']),
      (value: 'warsaw', label: 'Warszawa', names: <String>['warsaw']),
      (value: 'florence', label: 'Firenze', names: <String>['florence']),
    ];

/// Stands in for a server, which also knows each city by its English name.
List<PlComboboxOption<String>> _search(String query) {
  final String needle = query.trim().toLowerCase();

  return <PlComboboxOption<String>>[
    for (final city in _cities)
      if (<String>[city.label.toLowerCase(), ...city.names].any((name) => name.contains(needle)))
        PlComboboxOption<String>(value: city.value, label: city.label),
  ];
}

class ComboboxSearch extends StatefulWidget {
  const ComboboxSearch({super.key});

  @override
  State<ComboboxSearch> createState() => _ComboboxSearchState();
}

class _ComboboxSearchState extends State<ComboboxSearch> {
  List<String> _values = <String>[];
  String _query = '';
  String _answered = '';
  List<PlComboboxOption<String>> _options = _search('');
  Timer? _timer;

  /// Asks once the reader has stopped typing for a moment.
  void _onQueryChanged(String query) {
    _timer?.cancel();
    setState(() => _query = query);
    _timer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _answered = query;
        _options = _search(query);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool answered = _answered == _query;

    return SizedBox(
      width: 360,
      child: PlCombobox<String>.multiple(
        fullWidth: true,
        label: const Text('Cities'),
        description: const Text('Try munich, vienna or prague.'),
        placeholder: 'Search in any language…',
        options: answered ? _options : const <PlComboboxOption<String>>[],
        values: _values,
        onChanged: (List<String> next) => setState(() => _values = next),
        onQueryChanged: _onQueryChanged,
        filter: (_, _) => true,
        autoHighlight: PlComboboxHighlight.always,
        emptyMessage: answered ? 'No city goes by that name' : 'Searching…',
      ),
    );
  }
}
