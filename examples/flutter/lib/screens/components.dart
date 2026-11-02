import 'package:flutter/widgets.dart';
import 'package:plass_showcase/app/page.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/canvas.dart';
import 'package:plass_ui_example/demos/registry.dart';

/// Every demo, grouped by the component it belongs to.
final Map<String, List<String>> _byComponent = () {
  final groups = <String, List<String>>{};

  for (final name in demos.keys) {
    groups.putIfAbsent(name.split('/').first, () => <String>[]).add(name);
  }

  return Map<String, List<String>>.fromEntries(
    groups.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}();

/// The list of components, and the way to each one's demos.
class ComponentsScreen extends StatefulWidget {
  /// Creates the screen.
  const ComponentsScreen({super.key});

  @override
  State<ComponentsScreen> createState() => _ComponentsScreenState();
}

class _ComponentsScreenState extends State<ComponentsScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final found = _byComponent.entries
        .where((MapEntry<String, List<String>> one) => one.key.contains(query))
        .toList();

    return PushedScreen(
      title: 'Components',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PlTextField(
              fullWidth: true,
              controller: _search,
              placeholder: 'Search ${_byComponent.length} components',
              semanticLabel: 'Search components',
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.paddingOf(context).bottom + 24),
              children: <Widget>[
                PlList(
                  children: <Widget>[
                    for (final MapEntry(key: name, value: names) in found)
                      PlListItem(
                        description: Text('${names.length} demos'),
                        onPressed: () => Navigator.of(context).push(
                          ShowcaseRoute<void>(
                            builder: (BuildContext context) =>
                                ComponentScreen(name: name, demos: names),
                          ),
                        ),
                        child: Text(name),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One component's demos, one screen each.
class ComponentScreen extends StatefulWidget {
  /// Creates the screen.
  const ComponentScreen({required this.name, required this.demos, super.key});

  /// The folder name of the component.
  final String name;

  /// The registry keys of its demos.
  final List<String> demos;

  @override
  State<ComponentScreen> createState() => _ComponentScreenState();
}

class _ComponentScreenState extends State<ComponentScreen> {
  late String _demo = widget.demos.first;

  @override
  Widget build(BuildContext context) {
    return PushedScreen(
      title: widget.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: PlScrollZone(
              label: 'Demos',
              children: <Widget>[
                for (final String name in widget.demos)
                  PlChip(
                    selected: _demo == name,
                    onPressed: () => setState(() => _demo = name),
                    child: Text(name.split('/').last),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Overlay.wrap(
              child: PlassCanvas(
                key: ValueKey<String>(_demo),
                child: Builder(builder: demos[_demo]!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
