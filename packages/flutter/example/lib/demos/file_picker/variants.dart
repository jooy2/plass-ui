import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class FilePickerVariants extends StatelessWidget {
  const FilePickerVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: <Widget>[
          for (final variant in PlassVariant.values)
            SizedBox(
              width: 144,
              child: PlFilePicker(
                variant: variant,
                size: PlassSize.sm,
                showIcon: false,
                title: Text(variant.name),
                value: const <PlFile>[],
                onBrowse: () async => const <PlFile>[],
                onFilesChanged: (List<PlFile> next) {},
              ),
            ),
        ],
      ),
    );
  }
}
