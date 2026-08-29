import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateGrowPanel extends StatefulWidget {
  const AnimateGrowPanel({super.key});

  @override
  State<AnimateGrowPanel> createState() => _AnimateGrowPanelState();
}

class _AnimateGrowPanelState extends State<AnimateGrowPanel> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          PlButton(
            size: PlassSize.sm,
            variant: PlassVariant.glass,
            color: PlassColor.secondary,
            onPressed: () => setState(() => _open = !_open),
            child: Text(_open ? 'Hide options' : 'Show options'),
          ),
          if (_open)
            const PlAnimateGrow(
              origin: Alignment.topCenter,
              from: 0.92,
              duration: Duration(milliseconds: 260),
              child: PlBox(size: PlassSize.sm, child: Text('Sort, group and column visibility.')),
            ),
        ],
      ),
    );
  }
}
