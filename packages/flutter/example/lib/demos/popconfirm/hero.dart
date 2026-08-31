import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PopconfirmHero extends StatefulWidget {
  const PopconfirmHero({super.key});

  @override
  State<PopconfirmHero> createState() => _PopconfirmHeroState();
}

class _PopconfirmHeroState extends State<PopconfirmHero> {
  List<String> _rows = <String>['Q3 report', 'Onboarding notes', 'Pricing draft'];
  String? _asking;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final String row in _rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(row)),
                  PlPopconfirm(
                    open: _asking == row,
                    onOpenChanged: (bool next) => setState(() => _asking = next ? row : null),
                    title: const Text('Delete this file?'),
                    description: const Text('It cannot be undone.'),
                    confirmLabel: const Text('Delete'),
                    onConfirm: () => setState(() {
                      _rows = _rows.where((String entry) => entry != row).toList();
                      _asking = null;
                    }),
                    trigger: PlButton(
                      size: PlassSize.sm,
                      variant: PlassVariant.ghost,
                      color: PlassColor.danger,
                      onPressed: () => setState(() => _asking = row),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ),
          if (_rows.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: PlButton(
                size: PlassSize.sm,
                variant: PlassVariant.glass,
                onPressed: () => setState(() {
                  _rows = <String>['Q3 report', 'Onboarding notes', 'Pricing draft'];
                }),
                child: const Text('Put them back'),
              ),
            ),
        ],
      ),
    );
  }
}
