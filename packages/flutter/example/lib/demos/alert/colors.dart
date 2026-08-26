import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const Map<PlassColor, String> _lines = <PlassColor, String>{
  PlassColor.info: 'Maintenance is scheduled for Sunday.',
  PlassColor.success: 'The invoice was paid.',
  PlassColor.warning: 'Your card expires next month.',
  PlassColor.danger: 'The webhook has failed 12 times.',
};

class AlertColors extends StatelessWidget {
  const AlertColors({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final entry in _lines.entries) PlAlert(color: entry.key, child: Text(entry.value)),
        ],
      ),
    );
  }
}
