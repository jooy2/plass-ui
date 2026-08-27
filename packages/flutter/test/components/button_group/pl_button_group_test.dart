import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The corners of the box a button actually drew.
BorderRadius _cornersOf(WidgetTester tester, String label) {
  final decoration = decorationWhere(
    tester,
    find.ancestor(of: find.text(label), matching: find.byType(PlButton)),
    (BoxDecoration decoration) => decoration.borderRadius != null,
  );

  return decoration.borderRadius! as BorderRadius;
}

/// The edge it drew, or `null` when it drew none.
BoxBorder? _borderOf(WidgetTester tester, String label) {
  final decorations = decorationsOf(
    tester,
    find.ancestor(of: find.text(label), matching: find.byType(PlButton)),
  );

  for (final decoration in decorations) {
    if (decoration.border != null) {
      return decoration.border;
    }
  }

  return null;
}

void main() {
  group('PlButtonGroup', () {
    group('the run', () {
      testWidgets('lays its buttons out in order', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              children: <Widget>[
                PlButton(onPressed: () {}, child: const Text('Cut')),
                PlButton(onPressed: () {}, child: const Text('Copy')),
                PlButton(onPressed: () {}, child: const Text('Paste')),
              ],
            ),
            width: 480,
          ),
        );

        expect(
          tester.getTopLeft(find.text('Cut')).dx,
          lessThan(tester.getTopLeft(find.text('Copy')).dx),
        );
        expect(
          tester.getTopLeft(find.text('Copy')).dx,
          lessThan(tester.getTopLeft(find.text('Paste')).dx),
        );
      });

      testWidgets('stacks downward when vertical', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              orientation: PlassOrientation.vertical,
              children: <Widget>[
                PlButton(onPressed: () {}, child: const Text('Rename')),
                PlButton(onPressed: () {}, child: const Text('Delete')),
              ],
            ),
            width: 480,
          ),
        );

        expect(
          tester.getTopLeft(find.text('Rename')).dy,
          lessThan(tester.getTopLeft(find.text('Delete')).dy),
        );
        expect(
          tester.getTopLeft(find.text('Rename')).dx,
          equals(tester.getTopLeft(find.text('Delete')).dx),
        );
      });

      testWidgets('divides the width evenly when fullWidth', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              fullWidth: true,
              children: <Widget>[
                PlButton(onPressed: () {}, child: const Text('Deny')),
                PlButton(onPressed: () {}, child: const Text('A much longer label')),
              ],
            ),
            width: 480,
          ),
        );

        final Size deny = tester.getSize(
          find.ancestor(of: find.text('Deny'), matching: find.byType(PlButton)),
        );
        final Size other = tester.getSize(
          find.ancestor(of: find.text('A much longer label'), matching: find.byType(PlButton)),
        );

        expect(deny.width, equals(other.width));
      });
    });

    group('the corners', () {
      testWidgets('squares off the edges that face a neighbour', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              children: <Widget>[
                PlButton(onPressed: () {}, child: const Text('One')),
                PlButton(onPressed: () {}, child: const Text('Two')),
                PlButton(onPressed: () {}, child: const Text('Three')),
              ],
            ),
            width: 480,
          ),
        );

        final BorderRadius first = _cornersOf(tester, 'One');
        final BorderRadius middle = _cornersOf(tester, 'Two');
        final BorderRadius last = _cornersOf(tester, 'Three');

        expect(first.topLeft.x, greaterThan(0));
        expect(first.topRight, equals(Radius.zero));

        expect(middle.topLeft, equals(Radius.zero));
        expect(middle.topRight, equals(Radius.zero));

        expect(last.topLeft, equals(Radius.zero));
        expect(last.topRight.x, greaterThan(0));
      });

      testWidgets('follows the reading direction', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              children: <Widget>[
                PlButton(onPressed: () {}, child: const Text('One')),
                PlButton(onPressed: () {}, child: const Text('Two')),
              ],
            ),
            width: 480,
            textDirection: TextDirection.rtl,
          ),
        );

        // Under RTL the first button is on the right, so it is the *left* pair
        // of its corners that faces the neighbour.
        final BorderRadius first = _cornersOf(tester, 'One');

        expect(first.topRight.x, greaterThan(0));
        expect(first.topLeft, equals(Radius.zero));
      });

      testWidgets('leaves a run of one fully rounded', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              children: <Widget>[PlButton(onPressed: () {}, child: const Text('Only'))],
            ),
            width: 480,
          ),
        );

        final BorderRadius only = _cornersOf(tester, 'Only');

        expect(only.topLeft.x, greaterThan(0));
        expect(only.topRight.x, greaterThan(0));
      });

      testWidgets('squares top and bottom when the run is vertical', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              orientation: PlassOrientation.vertical,
              children: <Widget>[
                PlButton(onPressed: () {}, child: const Text('One')),
                PlButton(onPressed: () {}, child: const Text('Two')),
              ],
            ),
            width: 480,
          ),
        );

        final BorderRadius first = _cornersOf(tester, 'One');

        expect(first.topLeft.x, greaterThan(0));
        expect(first.bottomLeft, equals(Radius.zero));
        expect(first.bottomRight, equals(Radius.zero));
      });

      testWidgets('leaves a button that set its own corners alone', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlButtonGroup(
              children: <Widget>[
                PlIconButton(icon: SizedBox.shrink(), label: 'Like'),
                PlIconButton(icon: SizedBox.shrink(), label: 'Share'),
              ],
            ),
            width: 480,
          ),
        );

        // A PlIconButton is a disc, in a run as much as out of one.
        final decoration = decorationWhere(
          tester,
          find.byType(PlIconButton).first,
          (BoxDecoration decoration) => decoration.borderRadius != null,
        );
        final BorderRadius corners = decoration.borderRadius! as BorderRadius;

        expect(corners.topRight.x, greaterThan(0));
      });
    });

    group('the seam', () {
      testWidgets('drops the hairline that faces a neighbour', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              variant: PlassVariant.glass,
              children: <Widget>[
                PlButton(onPressed: () {}, child: const Text('One')),
                PlButton(onPressed: () {}, child: const Text('Two')),
              ],
            ),
            width: 480,
          ),
        );

        final Border first = _borderOf(tester, 'One')! as Border;
        final Border second = _borderOf(tester, 'Two')! as Border;

        // One line per seam: the first key keeps its right edge and the second
        // does not draw a left one on top of it.
        expect(first.left.style, equals(BorderStyle.solid));
        expect(first.right.style, equals(BorderStyle.solid));
        expect(second.left.style, equals(BorderStyle.none));
        expect(second.right.style, equals(BorderStyle.solid));
      });

      testWidgets('leaves a solid run with no edge at all', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              children: <Widget>[
                PlButton(onPressed: () {}, child: const Text('One')),
                PlButton(onPressed: () {}, child: const Text('Two')),
              ],
            ),
            width: 480,
          ),
        );

        expect(_borderOf(tester, 'Two'), isNull);
      });
    });

    group('inheritance', () {
      testWidgets('hands its size to every button', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              size: PlassSize.lg,
              children: <Widget>[PlButton(onPressed: () {}, child: const Text('Save'))],
            ),
            width: 480,
          ),
        );

        expect(
          tester
              .getSize(find.ancestor(of: find.text('Save'), matching: find.byType(PlButton)))
              .height,
          equals(48),
        );
      });

      testWidgets('lets a button override what the run said', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              size: PlassSize.lg,
              children: <Widget>[
                PlButton(onPressed: () {}, child: const Text('Inherited')),
                PlButton(size: PlassSize.sm, onPressed: () {}, child: const Text('Its own')),
              ],
            ),
            width: 480,
          ),
        );

        expect(
          tester
              .getSize(find.ancestor(of: find.text('Inherited'), matching: find.byType(PlButton)))
              .height,
          equals(48),
        );
        expect(
          tester
              .getSize(find.ancestor(of: find.text('Its own'), matching: find.byType(PlButton)))
              .height,
          equals(32),
        );
      });

      testWidgets('leaves a button on its own defaults when the run says nothing', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              children: <Widget>[PlButton(onPressed: () {}, child: const Text('Save'))],
            ),
            width: 480,
          ),
        );

        expect(
          tester
              .getSize(find.ancestor(of: find.text('Save'), matching: find.byType(PlButton)))
              .height,
          equals(40),
        );
      });

      testWidgets('hands its colour to every button', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              color: PlassColor.danger,
              children: <Widget>[PlButton(onPressed: () {}, child: const Text('Delete'))],
            ),
            width: 480,
          ),
        );

        final BoxDecoration filled = decorationWhere(
          tester,
          find.byType(PlButton),
          (BoxDecoration decoration) => decoration.gradient != null,
        );

        expect(
          filled.gradient,
          equals(PlassTheme.of(tester.element(find.text('Delete'))).family(PlassColor.danger).fill),
        );
      });

      testWidgets('disables every button at once', (WidgetTester tester) async {
        var taps = 0;

        await tester.pumpWidget(
          host(
            PlButtonGroup(
              disabled: true,
              children: <Widget>[
                PlButton(onPressed: () => taps += 1, child: const Text('Cut')),
                PlButton(onPressed: () => taps += 1, child: const Text('Copy')),
              ],
            ),
            width: 480,
          ),
        );

        await tester.tap(find.text('Cut'));
        await tester.tap(find.text('Copy'));
        await tester.pump();

        expect(taps, equals(0));
      });

      testWidgets('reaches a button that is not a direct child', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButtonGroup(
              size: PlassSize.xl,
              children: <Widget>[
                Builder(
                  builder: (BuildContext context) =>
                      PlButton(onPressed: () {}, child: const Text('Nested')),
                ),
              ],
            ),
            width: 480,
          ),
        );

        expect(
          tester
              .getSize(find.ancestor(of: find.text('Nested'), matching: find.byType(PlButton)))
              .height,
          equals(56),
        );
      });
    });
  });
}
