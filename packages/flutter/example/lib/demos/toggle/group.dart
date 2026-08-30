import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ToggleGroupDemo extends StatefulWidget {
  const ToggleGroupDemo({super.key});

  @override
  State<ToggleGroupDemo> createState() => _ToggleGroupDemoState();
}

class _ToggleGroupDemoState extends State<ToggleGroupDemo> {
  List<String> _align = <String>['left'];
  List<String> _marks = <String>['bold'];

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final TextStyle caption = TextStyle(fontSize: 12, color: tokens.mutedFg);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            Text('One of a set — ${_align.isEmpty ? 'none' : _align.join(', ')}', style: caption),
            PlToggleGroup(
              value: _align,
              onValueChanged: (List<String> next) => setState(() => _align = next),
              children: const <Widget>[
                PlToggle(value: 'left', child: Text('Left')),
                PlToggle(value: 'center', child: Text('Center')),
                PlToggle(value: 'right', child: Text('Right')),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            Text('multiple — ${_marks.isEmpty ? 'none' : _marks.join(', ')}', style: caption),
            PlToggleGroup(
              multiple: true,
              value: _marks,
              onValueChanged: (List<String> next) => setState(() => _marks = next),
              children: const <Widget>[
                PlToggle(value: 'bold', child: Text('Bold')),
                PlToggle(value: 'italic', child: Text('Italic')),
                PlToggle(value: 'underline', child: Text('Underline')),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
