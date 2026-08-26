import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlassColor> _severities = <PlassColor>[
  PlassColor.success,
  PlassColor.warning,
  PlassColor.danger,
  PlassColor.info,
];

class ToastColors extends StatelessWidget {
  const ToastColors({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: PlToastProvider(
        timeout: const Duration(seconds: 4),
        child: Builder(
          builder: (BuildContext context) {
            final toasts = PlToastProvider.of(context);

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final color in _severities)
                  PlButton(
                    size: PlassSize.sm,
                    variant: PlassVariant.glass,
                    color: color,
                    onPressed: () => toasts.show(
                      PlToast(
                        color: color,
                        title: Text(color.name),
                        description: const Text(
                          'Each family draws its own shape as well as its own colour.',
                        ),
                        priority: color == PlassColor.danger
                            ? PlToastPriority.high
                            : PlToastPriority.low,
                      ),
                    ),
                    child: Text(color.name),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
