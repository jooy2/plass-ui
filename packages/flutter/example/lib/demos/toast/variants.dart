import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ToastVariants extends StatelessWidget {
  const ToastVariants({super.key});

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
                for (final variant in PlassVariant.values)
                  PlButton(
                    size: PlassSize.sm,
                    variant: PlassVariant.glass,
                    color: PlassColor.secondary,
                    onPressed: () => toasts.show(
                      PlToast(
                        variant: variant,
                        title: Text(variant.name),
                        description: const Text('One of three.'),
                      ),
                    ),
                    child: Text(variant.name),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
