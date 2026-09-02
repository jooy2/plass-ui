import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ShowHero extends StatelessWidget {
  const ShowHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: const <Widget>[
        PlShow(
          until: PlassBreakpointFloor.md,
          child: PlChip(
            variant: PlassVariant.solid,
            color: PlassColor.warning,
            child: Text('Narrow — under 768'),
          ),
        ),
        PlShow(
          from: PlassBreakpointFloor.md,
          child: PlChip(
            variant: PlassVariant.solid,
            color: PlassColor.success,
            child: Text('Wide — 768 and up'),
          ),
        ),
        PlShow(
          from: PlassBreakpointFloor.sm,
          until: PlassBreakpointFloor.lg,
          child: PlChip(
            variant: PlassVariant.glass,
            color: PlassColor.secondary,
            child: Text('A band: 640 to 1024'),
          ),
        ),
      ],
    );
  }
}
