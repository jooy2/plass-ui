import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ConfirmFocus extends StatelessWidget {
  const ConfirmFocus({super.key});

  @override
  Widget build(BuildContext context) {
    return PlConfirmProvider(
      child: Builder(
        builder: (BuildContext context) {
          return Wrap(
            spacing: 12,
            alignment: WrapAlignment.center,
            children: <Widget>[
              PlButton(
                color: PlassColor.danger,
                onPressed: () => PlConfirmProvider.of(context).confirm(
                  const PlConfirmOptions(
                    title: Text('Delete this project?'),
                    description: Text('Enter lands on Cancel.'),
                    confirmLabel: Text('Delete'),
                    color: PlassColor.danger,
                  ),
                ),
                child: const Text('Destructive'),
              ),
              PlButton(
                variant: PlassVariant.glass,
                onPressed: () => PlConfirmProvider.of(context).confirm(
                  const PlConfirmOptions(
                    title: Text('Save before closing?'),
                    description: Text('Enter lands on Save.'),
                    confirmLabel: Text('Save'),
                    initialFocus: PlConfirmFocus.confirm,
                  ),
                ),
                child: const Text('Harmless'),
              ),
            ],
          );
        },
      ),
    );
  }
}
