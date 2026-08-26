import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const String _text =
    'A Plass surface is a key of tinted glass resting on a clear sheet. A thing that is '
    'pressed is tinted glass; a thing that holds something is clear glass.';

class HighlightHero extends StatefulWidget {
  const HighlightHero({super.key});

  @override
  State<HighlightHero> createState() => _HighlightHeroState();
}

class _HighlightHeroState extends State<HighlightHero> {
  final TextEditingController _search = TextEditingController(text: 'glass');
  String _query = 'glass';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          PlTextField(
            fullWidth: true,
            size: PlassSize.sm,
            controller: _search,
            label: const Text('Search'),
            onChanged: (String next) => setState(() => _query = next),
          ),
          PlHighlight(_text, query: _query),
        ],
      ),
    );
  }
}
