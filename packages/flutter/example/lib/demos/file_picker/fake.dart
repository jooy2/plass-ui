import 'package:plass_ui/plass_ui.dart';

/// A stand-in for the app's own picker.
///
/// The library reaches no file system — that is a plugin's job in every Flutter
/// app that does it, and this package has no dependencies. `onBrowse` is where a
/// real app calls whichever plugin it chose; the gallery hands back invented
/// files so the previews have something to list.
Future<List<PlFile>> pickFakeFiles({int count = 1}) async {
  const List<PlFile> invented = <PlFile>[
    PlFile(name: 'aurora.png', size: 1400000, mimeType: 'image/png'),
    PlFile(name: 'notes.pdf', size: 82000, mimeType: 'application/pdf'),
    PlFile(name: 'field-recording.wav', size: 24000000, mimeType: 'audio/wav'),
    PlFile(name: 'contract.docx', size: 310000),
  ];

  return invented.take(count).toList();
}
