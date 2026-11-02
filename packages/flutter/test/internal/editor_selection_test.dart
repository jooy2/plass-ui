import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/editor_selection.dart';

import '../support/host.dart';

void main() {
  late TextEditingController controller;

  setUp(() {
    controller = TextEditingController(text: 'Seoul Lisbon');
    addTearDown(controller.dispose);
  });

  Future<void> longPress(WidgetTester tester, {bool overlay = true}) async {
    await tester.pumpWidget(
      host(PlTextField(fullWidth: true, controller: controller), width: 300, overlay: overlay),
    );
    await tester.longPressAt(tester.getTopLeft(find.byType(EditableText)) + const Offset(10, 8));
    await tester.pumpAndSettle();
  }

  bool handles(WidgetTester tester) {
    return tester.widget<EditableText>(find.byType(EditableText)).showSelectionHandles;
  }

  for (final TargetPlatform platform in <TargetPlatform>[
    TargetPlatform.iOS,
    TargetPlatform.android,
  ]) {
    testWidgets('takes a word and offers the menu on a long press on $platform', (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;

      await longPress(tester);

      expect(controller.selection, const TextSelection(baseOffset: 0, extentOffset: 5));
      expect(handles(tester), isTrue);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Cut'), findsOneWidget);

      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('brings the handles back for a word still selected from before', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await longPress(tester);

    final EditableTextState editor = tester.state<EditableTextState>(find.byType(EditableText));

    expect(editor.selectionOverlay?.handlesAreVisible, isTrue);

    editor.widget.focusNode.unfocus();
    await tester.pumpAndSettle();

    expect(controller.selection.isCollapsed, isFalse);

    await tester.longPressAt(tester.getTopLeft(find.byType(EditableText)) + const Offset(10, 8));
    await tester.pumpAndSettle();

    expect(controller.selection, const TextSelection(baseOffset: 0, extentOffset: 5));
    expect(editor.selectionOverlay?.handlesAreVisible, isTrue);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('gives the field of a colour picker its handles', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await tester.pumpWidget(
      host(
        const PlColorPicker(inline: true, value: '#1a58d1'),
        width: 400,
        height: 560,
        overlay: true,
      ),
    );
    await tester.longPressAt(tester.getTopLeft(find.byType(EditableText)) + const Offset(16, 8));
    await tester.pumpAndSettle();

    final selection = tester.widget<EditableText>(find.byType(EditableText)).controller.selection;

    expect(selection.isCollapsed, isFalse);
    expect(handles(tester), isTrue);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('gives the field of a command palette its handles', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await tester.pumpWidget(
      host(
        PlCommandPalette(
          open: true,
          items: const <PlCommandItem>[PlCommandItem(value: 'open', label: 'Open')],
          onOpenChanged: (bool _) {},
        ),
        width: 300,
        overlay: true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'open files');
    await tester.pump();

    expect(handles(tester), isFalse);

    await tester.longPressAt(tester.getTopLeft(find.byType(EditableText)) + const Offset(12, 8));
    await tester.pumpAndSettle();

    final selection = tester.widget<EditableText>(find.byType(EditableText)).controller.selection;

    expect(selection.isCollapsed, isFalse);
    expect(handles(tester), isTrue);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('draws no handles for a selection the code made', (WidgetTester tester) async {
    await tester.pumpWidget(
      host(PlTextField(fullWidth: true, controller: controller), width: 300, overlay: true),
    );

    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 5);
    await tester.pump();

    expect(handles(tester), isFalse);
  });

  testWidgets('keeps the handles off a desktop', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    await longPress(tester);

    expect(handles(tester), isFalse);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('still takes a word with no overlay above the field', (WidgetTester tester) async {
    await longPress(tester, overlay: false);

    expect(tester.takeException(), isNull);
    expect(controller.selection, const TextSelection(baseOffset: 0, extentOffset: 5));
    expect(find.text('Copy'), findsNothing);
  });

  test('controls of one colour are equal, so an editor keeps its overlay', () {
    const Color ink = Color(0xFF3F63F2);

    expect(PlassSelectionControls(ink), PlassSelectionControls(ink));
  });

  test('a handle is anchored to the line it marks', () {
    final controls = PlassSelectionControls(const Color(0xFF3F63F2));

    expect(controls.getHandleSize(20).height, greaterThan(20));
    expect(controls.getHandleAnchor(TextSelectionHandleType.right, 20).dy, 20);
    expect(
      controls.getHandleAnchor(TextSelectionHandleType.left, 20).dy,
      controls.getHandleSize(20).height,
    );
  });
}
