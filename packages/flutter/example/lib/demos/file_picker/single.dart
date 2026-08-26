import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui_example/demos/file_picker/fake.dart';

class FilePickerSingle extends StatefulWidget {
  const FilePickerSingle({super.key});

  @override
  State<FilePickerSingle> createState() => _FilePickerSingleState();
}

class _FilePickerSingleState extends State<FilePickerSingle> {
  List<PlFile> _files = const <PlFile>[];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlFilePicker(
        label: const Text('Avatar'),
        title: const Text('Choose a picture'),
        hint: const Text('Square works best'),
        description: const Text('Replacing it removes the one before.'),
        accept: 'image/png,image/jpeg',
        value: _files,
        onBrowse: () => pickFakeFiles(),
        onFilesChanged: (List<PlFile> next) => setState(() => _files = next),
      ),
    );
  }
}
