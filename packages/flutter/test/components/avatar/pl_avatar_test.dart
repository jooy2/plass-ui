import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlAvatar', () {
    group('initials', () {
      test('takes the first character of the first word and of the last', () {
        expect(PlAvatar.initialsOf('Jane Doe'), 'JD');
        expect(PlAvatar.initialsOf('Ada Byron Lovelace'), 'AL');
      });

      test('gives one character to a one-word name', () {
        expect(PlAvatar.initialsOf('홍길동'), '홍');
        expect(PlAvatar.initialsOf('Prince'), 'P');
      });

      test('does not cut a character outside the basic plane in half', () {
        expect(PlAvatar.initialsOf('🙂 Smith'), '🙂S');
      });

      test('is empty for a name with nothing in it', () {
        expect(PlAvatar.initialsOf('   '), '');
      });

      testWidgets('draws them', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAvatar(name: 'Ada Lovelace')));

        expect(find.text('AL'), findsOneWidget);
      });

      testWidgets('takes written-out initials over the derived ones', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAvatar(name: 'Ada Lovelace', initials: 'A')));

        expect(find.text('A'), findsOneWidget);
        expect(find.text('AL'), findsNothing);
      });
    });

    group('rendering', () {
      testWidgets('is a control-height square', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAvatar(size: PlassSize.lg)));

        expect(tester.getSize(find.byType(PlAvatar)), const Size(48, 48));
      });

      testWidgets('is never an empty box', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAvatar()));

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('draws a glyph over the initials when given one', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAvatar(name: 'Ada Lovelace', child: Text('★'))));

        expect(find.text('★'), findsOneWidget);
        expect(find.text('AL'), findsNothing);
      });
    });

    group('shape', () {
      testWidgets('is a circle by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAvatar(size: PlassSize.md)));

        final crop = decorationWhere(
          tester,
          find.byType(PlAvatar),
          (BoxDecoration decoration) => decoration.borderRadius != null,
        );

        expect(crop.borderRadius, BorderRadius.circular(40));
      });

      testWidgets('takes the library fillet when square', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAvatar(shape: PlAvatarShape.square, size: PlassSize.md)),
        );

        final crop = decorationWhere(
          tester,
          find.byType(PlAvatar),
          (BoxDecoration decoration) => decoration.borderRadius != null,
        );

        expect(crop.borderRadius, BorderRadius.circular(PlassTokens.radius[PlassSize.md]!));
      });
    });

    group('variant', () {
      testWidgets('is ghost by default — a page of avatars is not a page of keys', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlAvatar(name: 'Ada')));

        final tokens = PlassTokens.light();
        final surface = decorationWhere(
          tester,
          find.byType(PlAvatar),
          (BoxDecoration decoration) => decoration.color != null,
        );

        expect(surface.color, tokens.family(PlassColor.primary).softPress);
        expect(surface.gradient, isNull);
      });

      testWidgets('a solid avatar takes the family gradient', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAvatar(name: 'Ada', variant: PlassVariant.solid)));

        final surface = decorationWhere(
          tester,
          find.byType(PlAvatar),
          (BoxDecoration decoration) => decoration.gradient != null,
        );

        expect(
          (surface.gradient! as LinearGradient).colors.first,
          PlassTokens.light().family(PlassColor.primary).solid,
        );
      });
    });

    group('accessibility', () {
      testWidgets('is named by the name', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlAvatar(name: 'Ada Lovelace')));

        expect(find.bySemanticsLabel('Ada Lovelace'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('does not read the initials out as letters', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlAvatar(name: 'Ada Lovelace')));

        expect(find.bySemanticsLabel('AL'), findsNothing);
        handle.dispose();
      });

      testWidgets('falls back to reading the initials when there is no name', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlAvatar(initials: 'AL')));

        // Not ideal, and deliberately not silence: an avatar with initials and
        // nothing else is all there is to go on.
        expect(find.bySemanticsLabel('AL'), findsOneWidget);
        handle.dispose();
      });
    });
  });
}
