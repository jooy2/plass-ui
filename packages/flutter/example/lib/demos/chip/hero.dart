import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ChipHero extends StatefulWidget {
  const ChipHero({super.key});

  @override
  State<ChipHero> createState() => _ChipHeroState();
}

class _ChipHeroState extends State<ChipHero> {
  List<String> _tags = <String>['design', 'research', 'infra'];
  String _filter = 'open';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              for (final value in const <String>['open', 'closed'])
                PlChip(
                  selected: _filter == value,
                  onPressed: () => setState(() => _filter = value),
                  count: Text(value == 'open' ? '12' : '148'),
                  child: Text(value),
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              for (final tag in _tags)
                PlChip(
                  variant: PlassVariant.ghost,
                  color: PlassColor.secondary,
                  onDeleted: () => setState(() {
                    _tags = _tags.where((String one) => one != tag).toList();
                  }),
                  child: Text(tag),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
