import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/panes/filled.dart';

class PanesConstraints extends StatefulWidget {
  const PanesConstraints({super.key});

  @override
  State<PanesConstraints> createState() => _PanesConstraintsState();
}

class _PanesConstraintsState extends State<PanesConstraints> {
  List<double> _shares = const <double>[];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: <Widget>[
          SizedBox(
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.lg]!),
              child: PlPanes(
                onResize: (List<double> shares) => setState(() => _shares = shares),
                panes: const <PlPane>[
                  PlPane(
                    defaultSize: PlPaneSize.percent(30),
                    minSize: PlPaneSize.percent(20),
                    maxSize: PlPaneSize.percent(50),
                    child: Filled('20% – 50%'),
                  ),
                  PlPane(child: Filled('Whatever is left')),
                ],
              ),
            ),
          ),
          PlTypography(
            _shares.isEmpty
                ? 'Drag the handle to see the shares'
                : _shares.map((double share) => '${share.round()}%').join(' · '),
            level: PlTypographyLevel.caption,
          ),
        ],
      ),
    );
  }
}
