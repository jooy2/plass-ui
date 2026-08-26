import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AlertDismiss extends StatefulWidget {
  const AlertDismiss({super.key});

  @override
  State<AlertDismiss> createState() => _AlertDismissState();
}

class _AlertDismissState extends State<AlertDismiss> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: _open
            ? PlAlert(
                color: PlassColor.warning,
                title: const Text('Storage is nearly full'),
                onClose: () => setState(() => _open = false),
                child: const Text('92% of your quota is in use.'),
              )
            : PlButton(
                size: PlassSize.sm,
                variant: PlassVariant.glass,
                onPressed: () => setState(() => _open = true),
                child: const Text('Bring it back'),
              ),
      ),
    );
  }
}
