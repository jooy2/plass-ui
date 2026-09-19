import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/notch.dart';
import 'package:plass_ui/src/internal/surface.dart';

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
    this.showRejections = true,
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
  final bool showRejections;
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
      showRejections: widget.showRejections,
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

    group('a file over the box', () {
      /// The zone's own surface, which is the first one the picker builds.
      PlassSurface surface(WidgetTester tester) {
        return tester.widgetList<PlassSurfaceBox>(find.byType(PlassSurfaceBox)).first.surface;
      }

      testWidgets('spreads a halo of the family outside it', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlFilePicker(value: <PlFile>[]), width: 420));
        final int resting = surface(tester).shadows.length;

        await tester.pumpWidget(
          host(const PlFilePicker(value: <PlFile>[], dragging: true), width: 420),
        );
        final List<BoxShadow> lit = surface(tester).shadows;

        expect(lit.length, resting + 1);
        expect(lit.last.spreadRadius, 4);
        expect(lit.last.blurRadius, 0);
      });

      testWidgets('and washes the sheet in the family', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlFilePicker(value: <PlFile>[]), width: 420));
        final Color? resting = surface(tester).fill;

        await tester.pumpWidget(
          host(const PlFilePicker(value: <PlFile>[], dragging: true), width: 420),
        );

        expect(surface(tester).fill, isNot(resting));
      });

      testWidgets('but answers nothing while it is inert', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlFilePicker(value: <PlFile>[], readOnly: true), width: 420),
        );
        final int resting = surface(tester).shadows.length;

        await tester.pumpWidget(
          host(const PlFilePicker(value: <PlFile>[], readOnly: true, dragging: true), width: 420),
        );

        expect(surface(tester).shadows.length, resting);
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

    group('saying what was turned away', () {
      testWidgets('says why, grouped by reason and counted', (WidgetTester tester) async {
        await _pump(
          tester,
          const _Harness(
            multiple: true,
            accept: 'application/pdf',
            maxSize: 2000,
            found: <PlFile>[_photo, _huge, _paper],
          ),
        );

        await tester.tap(find.text('Choose files'));
        await tester.pumpAndSettle();

        // One line per reason rather than one per file: a folder handed to a
        // picker with a `maxFiles` of five is ninety-five lines of the same
        // sentence.
        // The two pictures are the wrong kind; the PDF is the right kind and
        // over the size. Each reason gets one line, whatever it cost.
        expect(find.text('2 files are not an accepted type'), findsOneWidget);
        expect(find.text('1 file is too large'), findsOneWidget);
      });

      testWidgets('says so about the count as well', (WidgetTester tester) async {
        await _pump(
          tester,
          const _Harness(multiple: true, maxFiles: 1, found: <PlFile>[_photo, _paper, _huge]),
        );

        await tester.tap(find.text('Choose files'));
        await tester.pumpAndSettle();

        expect(find.text('2 files did not fit'), findsOneWidget);
      });

      testWidgets('announces it politely rather than interrupting', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const _Harness(accept: 'application/pdf', found: <PlFile>[_photo]));

        await tester.tap(find.text('Choose files'));
        await tester.pumpAndSettle();

        expect(find.semantics.byFlag(SemanticsFlag.isLiveRegion), findsOneWidget);
        handle.dispose();
      });

      testWidgets('drops the message once the reader does something else', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const _Harness(
            multiple: true,
            accept: 'application/pdf',
            found: <PlFile>[_photo, _paper],
          ),
        );

        await tester.tap(find.text('Choose files'));
        await tester.pumpAndSettle();
        expect(find.text('1 file is not an accepted type'), findsOneWidget);

        await tester.tap(find.bySemanticsLabel('Remove notes.pdf'));
        await tester.pumpAndSettle();

        expect(find.text('1 file is not an accepted type'), findsNothing);
      });

      testWidgets('says nothing when the batch was taken whole', (WidgetTester tester) async {
        await _pump(tester, const _Harness(found: <PlFile>[_paper]));

        await tester.tap(find.text('Choose files'));
        await tester.pumpAndSettle();

        expect(find.textContaining('not an accepted type'), findsNothing);
        expect(find.textContaining('did not fit'), findsNothing);
      });

      testWidgets('can be told to leave it to `onRejected`', (WidgetTester tester) async {
        final turned = <PlFileRejection>[];

        await _pump(
          tester,
          _Harness(
            accept: 'application/pdf',
            showRejections: false,
            found: const <PlFile>[_photo],
            onRejected: turned.addAll,
          ),
        );

        await tester.tap(find.text('Choose files'));
        await tester.pumpAndSettle();

        expect(turned, hasLength(1));
        expect(find.textContaining('not an accepted type'), findsNothing);
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

      testWidgets('the box is named by the field label, then by its own words', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PlFilePicker(value: <PlFile>[], label: Text('Resume')),
                PlFilePicker(value: <PlFile>[], label: Text('Cover letter')),
              ],
            ),
            width: 420,
          ),
        );

        // Two pickers on one screen would otherwise be read out the same.
        final resume = tester.getSemantics(find.text('Resume'));
        final letter = tester.getSemantics(find.text('Cover letter'));

        expect(resume, isSemantics(isButton: true, label: 'Resume\nChoose files'));
        expect(letter, isSemantics(isButton: true, label: 'Cover letter\nChoose files'));

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

    group('labelPlacement', () {
      testWidgets('cuts the label into the drop zone\'s dashed edge', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlFilePicker(
              value: <PlFile>[],
              label: Text('Attachments'),
              labelPlacement: PlassFieldLabelPlacement.notch,
            ),
            width: 360,
          ),
        );

        // The zone's own edge is dashed, and the notch cuts it with the same
        // clip a field's hairline gets.
        expect(find.byType(PlassFieldNotch), findsOneWidget);
        expect(
          find.descendant(of: find.byType(PlassFieldNotch), matching: find.byType(ClipPath)),
          findsOneWidget,
        );
      });
    });
  });
}
