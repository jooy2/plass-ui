import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A glyph with no drawing in it: the box is what these tests are about.
const Widget glyph = SizedBox.shrink();

void main() {
  group('PlIcon', () {
    group('rendering', () {
      testWidgets('lays the glyph into a box of the size asked for', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlIcon(icon: glyph, size: PlassSize.lg)));

        expect(tester.getSize(find.byType(PlIcon)), const Size(24, 24));
      });

      testWidgets('defaults to md, which is 20px', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlIcon(icon: glyph)));

        expect(tester.getSize(find.byType(PlIcon)), const Size(20, 20));
      });

      testWidgets('walks its own ladder rather than the control heights', (
        WidgetTester tester,
      ) async {
        for (final entry in const <PlassSize, double>{
          PlassSize.xs: 14,
          PlassSize.sm: 16,
          PlassSize.md: 20,
          PlassSize.lg: 24,
          PlassSize.xl: 28,
        }.entries) {
          await tester.pumpWidget(host(PlIcon(icon: glyph, size: entry.key)));

          expect(tester.getSize(find.byType(PlIcon)), Size.square(entry.value));
        }
      });
    });

    group('sizing the glyph', () {
      testWidgets('tells an Icon how big it is', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlIcon(icon: Icon(IconData(0x2b)), size: PlassSize.xl)));

        expect(tester.widget<Icon>(find.byType(Icon)).icon, const IconData(0x2b));
        expect(IconTheme.of(tester.element(find.byType(Icon))).size, 28);
      });

      testWidgets('makes the box its own font size, so an em-sized glyph fits', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlIcon(icon: Text('A'), size: PlassSize.lg)));

        expect(styleOf(tester, 'A').fontSize, 24);
      });
    });

    group('colour', () {
      testWidgets('inherits by default rather than arriving pre-dyed', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const IconTheme(
              data: IconThemeData(color: Color(0xFF00FF00)),
              child: PlIcon(icon: Icon(IconData(0x2b))),
            ),
          ),
        );

        expect(IconTheme.of(tester.element(find.byType(Icon))).color, const Color(0xFF00FF00));
      });

      testWidgets('wears a family accent when one is asked for', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlIcon(icon: Icon(IconData(0x2b)), color: PlassColor.danger)),
        );

        expect(
          IconTheme.of(tester.element(find.byType(Icon))).color,
          PlassTokens.light().family(PlassColor.danger).accent,
        );
      });
    });

    group('accessibility', () {
      testWidgets('is furniture without a label', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlIcon(icon: Text('A'))));

        expect(find.bySemanticsLabel('A'), findsNothing);
        handle.dispose();
      });

      testWidgets('is an image with a name when it has something to say', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlIcon(icon: glyph, label: 'Search')));

        expect(
          tester.getSemantics(find.byType(PlIcon)),
          matchesSemantics(label: 'Search', isImage: true),
        );

        handle.dispose();
      });
    });
  });
}
