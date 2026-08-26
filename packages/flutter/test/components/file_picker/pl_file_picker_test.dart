import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/icons.dart';

import '../../support/host.dart';

const PlFile _photo = PlFile(name: 'aurora.png', size: 1_400_000, mimeType: 'image/png');
const PlFile _paper = PlFile(name: 'notes.pdf', size: 12_000, mimeType: 'application/pdf');
const PlFile _huge = PlFile(name: 'raw.tiff', size: 90_000_000, mimeType: 'image/tiff');

/// A picker wired to a variable, which is how every caller uses it.
class _Harness extends StatefulWidget {
  const _Harness({
    this.files = const <PlFile>[],
    this.found = const <PlFile>[],
    this.accept,
    this.multiple = false,
    this.maxSize,
    this.maxFiles,
    this.readOnly = false,
    this.disabled = false,
    this.onRejected,
  });

  final List<PlFile> files;
  final List<PlFile> found;
  final String? accept;
  final bool multiple;
  final int? maxSize;
  final int? maxFiles;
  final bool readOnly;
  final bool disabled;
  final ValueChanged<List<PlFileRejection>>? onRejected;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late List<PlFile> _files = widget.files;

  List<PlFile> get files => _files;

  @override
  Widget build(BuildContext context) {
    return PlFilePicker(
      value: _files,
      accept: widget.accept,
      multiple: widget.multiple,
      maxSize: widget.maxSize,
      maxFiles: widget.maxFiles,
      readOnly: widget.readOnly,
      disabled: widget.disabled,
      onRejected: widget.onRejected,
      onBrowse: () async => widget.found,
      onFilesChanged: (List<PlFile> next) => setState(() => _files = next),
    );
  }
}

Future<_HarnessState> _pump(WidgetTester tester, _Harness harness) async {
  await tester.pumpWidget(host(harness, width: 420));

  return tester.state<_HarnessState>(find.byType(_Harness));
}

void main() {
  group('PlFile', () {
    test('writes a size the way a file browser does', () {
      expect(const PlFile(name: 'a', size: 800).readableSize, '800 B');
      expect(const PlFile(name: 'a', size: 12_000).readableSize, '12 kB');
      expect(const PlFile(name: 'a', size: 1_400_000).readableSize, '1.4 MB');
      expect(const PlFile(name: 'a', size: 2_500_000_000).readableSize, '2.5 GB');
    });

    test('matches all three forms of accept', () {
      expect(_photo.matches('image/*'), isTrue);
      expect(_photo.matches('image/png'), isTrue);
      expect(_photo.matches('.png'), isTrue);
      expect(_photo.matches('application/pdf,.txt'), isFalse);
      expect(_paper.matches('image/*,.pdf'), isTrue);
    });
  });

  group('PlFilePicker', () {
    group('shapes', () {
      testWidgets('draws the box, the glyph and a line to press', (WidgetTester tester) async {
        await _pump(tester, const _Harness());

        expect(find.text('Choose files'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.upload,
          ),
          findsOneWidget,
        );
      });

      testWidgets('lists what has been chosen, with its size', (WidgetTester tester) async {
        await _pump(tester, const _Harness(files: <PlFile>[_photo]));

        expect(find.text('aurora.png'), findsOneWidget);
        expect(find.text('1.4 MB'), findsOneWidget);
      });

      testWidgets('and can be told not to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlFilePicker(value: <PlFile>[_photo], showList: false), width: 420),
        );

        expect(find.text('aurora.png'), findsNothing);
      });
    });

    group('choosing', () {
      testWidgets('a press runs the app’s picker and keeps what it found', (
        WidgetTester tester,
      ) async {
        final state = await _pump(tester, const _Harness(found: <PlFile>[_photo]));

        await tester.tap(find.text('Choose files'));
        await tester.pumpAndSettle();

        expect(state.files.map((PlFile file) => file.name), <String>['aurora.png']);
      });

      testWidgets('a second file replaces the first unless more than one is allowed', (
        WidgetTester tester,
      ) async {
        final state = await _pump(
          tester,
          const _Harness(files: <PlFile>[_photo], found: <PlFile>[_paper]),
        );

        await tester.tap(find.text('Choose files'));
        await tester.pumpAndSettle();

        expect(state.files.map((PlFile file) => file.name), <String>['notes.pdf']);
      });

      testWidgets('and joins it when it is', (WidgetTester tester) async {
        final state = await _pump(
          tester,
          const _Harness(multiple: true, files: <PlFile>[_photo], found: <PlFile>[_paper]),
        );

        await tester.tap(find.text('Choose files'));
        await tester.pumpAndSettle();

        expect(state.files.map((PlFile file) => file.name), <String>['aurora.png', 'notes.pdf']);
      });

      testWidgets('a read-only picker does not open', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(readOnly: true, found: <PlFile>[_photo]));

        await tester.tap(find.text('Choose files'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(state.files, isEmpty);
      });

      testWidgets('nor does a disabled one', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(disabled: true, found: <PlFile>[_photo]));

        await tester.tap(find.text('Choose files'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(state.files, isEmpty);
      });
    });

    group('rules', () {
      testWidgets('turns away the wrong kind, and says why', (WidgetTester tester) async {
        final turned = <PlFileRejection>[];
        final state = await _pump(
          tester,
          _Harness(
            accept: 'application/pdf',
            found: const <PlFile>[_photo],
            onRejected: turned.addAll,
          ),
        );

        await tester.tap(find.text('Choose files'));
        await tester.pumpAndSettle();

        expect(state.files, isEmpty);
        expect(turned.single.reason, PlFileRejectionReason.type);
      });

      testWidgets('and the too large', (WidgetTester tester) async {
        final turned = <PlFileRejection>[];
        final state = await _pump(
          tester,
          _Harness(maxSize: 1_000_000, found: const <PlFile>[_huge], onRejected: turned.addAll),
        );

        await tester.tap(find.text('Choose files'));
        await tester.pumpAndSettle();

        expect(state.files, isEmpty);
        expect(turned.single.reason, PlFileRejectionReason.size);
      });

      testWidgets('counts against what is already held, not against the batch', (
        WidgetTester tester,
      ) async {
        final turned = <PlFileRejection>[];
        final state = await _pump(
          tester,
          _Harness(
            multiple: true,
            maxFiles: 2,
            files: const <PlFile>[_photo],
            found: const <PlFile>[_paper, _huge],
            onRejected: turned.addAll,
          ),
        );

        await tester.tap(find.text('Choose files'));
        await tester.pumpAndSettle();

        expect(state.files.length, 2);
        expect(turned.single.reason, PlFileRejectionReason.count);
      });
    });

    group('removing', () {
      testWidgets('the × takes one file off the list', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        final state = await _pump(
          tester,
          const _Harness(multiple: true, files: <PlFile>[_photo, _paper]),
        );

        await tester.tap(find.bySemanticsLabel('Remove aurora.png'));
        await tester.pumpAndSettle();

        expect(state.files.map((PlFile file) => file.name), <String>['notes.pdf']);
        handle.dispose();
      });

      testWidgets('and there is none to press when the picker is inert', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, const _Harness(readOnly: true, files: <PlFile>[_photo]));

        expect(find.bySemanticsLabel('Remove aurora.png'), findsNothing);
        handle.dispose();
      });
    });

    group('accessibility', () {
      testWidgets('the box is announced as a button', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, const _Harness());

        expect(
          tester.getSemantics(find.text('Choose files')),
          isSemantics(isButton: true, isEnabled: true),
        );

        handle.dispose();
      });

      testWidgets('an error re-points the family at danger', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlFilePicker(value: <PlFile>[], error: Text('Pick a file.')), width: 420),
        );

        expect(
          styleOf(tester, 'Pick a file.').color,
          PlassTokens.light().family(PlassColor.danger).accent,
        );
      });
    });
  });
}
