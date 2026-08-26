import 'package:flutter/widgets.dart';

/// Somewhere for a demo's switches and checkboxes to live.
///
/// Every control in the Flutter package is controlled — it is handed a value and
/// reports what the value should become — so a demo that shows three of them
/// needs three pieces of state. React's `defaultChecked` does this for free; the
/// price of not having it is this file, once, rather than a `StatefulWidget` in
/// every demo that has a tick in it.
class Toggles extends StatefulWidget {
  /// Creates a holder. [initial] is what each key starts as.
  const Toggles({required this.builder, this.initial = const <String, bool>{}, super.key});

  /// Draws the demo, given the current values and a way to change one.
  final Widget Function(BuildContext context, ToggleState state) builder;

  /// What each key starts as. A key with no entry starts off.
  final Map<String, bool> initial;

  @override
  State<Toggles> createState() => _TogglesState();
}

/// Reading and writing one demo's toggles.
class ToggleState {
  ToggleState._(this._values, this._set);

  final Map<String, bool> _values;
  final void Function(String key, bool value) _set;

  /// Whether [key] is on.
  bool operator [](String key) => _values[key] ?? false;

  /// Turns [key] on or off.
  void set(String key, bool value) => _set(key, value);
}

class _TogglesState extends State<Toggles> {
  late Map<String, bool> _values = Map<String, bool>.of(widget.initial);

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      ToggleState._(_values, (String key, bool value) {
        setState(() => _values = <String, bool>{..._values, key: value});
      }),
    );
  }
}
