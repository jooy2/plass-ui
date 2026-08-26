import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui_example/demos/file_picker/fake.dart';

class FilePickerHero extends StatefulWidget {
  const FilePickerHero({super.key});

  @override
  State<FilePickerHero> createState() => _FilePickerHeroState();
}

class _FilePickerHeroState extends State<FilePickerHero> {
  List<PlFile> _files = const <PlFile>[];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlFilePicker(
        label: const Text('Attachments'),
        hint: const Text('Up to four files, 5 MB each'),
        multiple: true,
        maxFiles: 4,
        maxSize: 5000000,
        value: _files,
        onBrowse: () => pickFakeFiles(count: 2),
        onFilesChanged: (List<PlFile> next) => setState(() => _files = next),
      ),
    );
  }
}
