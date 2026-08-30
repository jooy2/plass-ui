import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<String> people = <String>[
  'Ada Lovelace',
  'Grace Hopper',
  'Katherine Johnson',
  'Alan Turing',
  'Jane Doe',
];

List<PlAvatar> faces([int count = 3]) {
  return <PlAvatar>[for (final String name in people.take(count)) PlAvatar(name: name)];
}

/// Lets the stack be exactly as wide and as tall as it wants to be.
Widget loose(Widget child) {
  return Align(alignment: Alignment.topLeft, widthFactor: 1, heightFactor: 1, child: child);
}

void main() {
  group('PlAvatarGroup', () {
    testWidgets('draws every avatar it was given', (WidgetTester tester) async {
      await tester.pumpWidget(host(PlAvatarGroup(avatars: faces()), width: 400, height: 200));

      expect(find.text('AL'), findsOneWidget);
      expect(find.text('GH'), findsOneWidget);
      expect(find.text('KJ'), findsOneWidget);
    });

    testWidgets('lays them one step apart and measures as wide as it draws', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(loose(PlAvatarGroup(avatars: faces())), width: 400, height: 200),
      );

      // `md` is a 40px box, plus the 2px ring on each side, less the 14px overlap.
      const double box = 44;
      const double step = box - 14;

      final Size size = tester.getSize(find.byType(PlAvatarGroup));

      expect(size.height, box);
      expect(size.width, box + step * 2);

      final double first = tester.getTopLeft(find.byType(PlAvatarGroup)).dx;

      expect(tester.getTopLeft(find.text('GH')).dx - first, greaterThan(0));
      expect(
        tester.getTopLeft(find.text('KJ')).dx - tester.getTopLeft(find.text('GH')).dx,
        closeTo(step, 0.01),
      );
    });

    testWidgets('takes an overlap of its own', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(loose(PlAvatarGroup(overlap: 0, avatars: faces(2))), width: 400, height: 200),
      );

      expect(tester.getSize(find.byType(PlAvatarGroup)).width, 88);
    });

    testWidgets('walks the overlap up the size ladder', (WidgetTester tester) async {
      for (final MapEntry<PlassSize, double> entry in <PlassSize, double>{
        PlassSize.xs: 24 + 4,
        PlassSize.sm: 32 + 4,
        PlassSize.md: 40 + 4,
        PlassSize.lg: 48 + 4,
        PlassSize.xl: 56 + 4,
      }.entries) {
        await tester.pumpWidget(
          host(loose(PlAvatarGroup(size: entry.key, avatars: faces(1))), width: 400, height: 200),
        );

        expect(tester.getSize(find.byType(PlAvatarGroup)).height, entry.value);
      }
    });

    group('the count', () {
      testWidgets('draws the ones that did not fit as a count', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlAvatarGroup(max: 2, avatars: faces(5)), width: 400, height: 200),
        );

        expect(find.text('GH'), findsOneWidget);
        expect(find.text('KJ'), findsNothing);
        expect(find.text('+3'), findsOneWidget);
      });

      testWidgets('counts against total when it was handed only the first few', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(PlAvatarGroup(max: 2, total: 40, avatars: faces(2)), width: 400, height: 200),
        );

        expect(find.text('+38'), findsOneWidget);
      });

      testWidgets('draws no count when everything fits', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlAvatarGroup(max: 4, avatars: faces(2)), width: 400, height: 200),
        );

        expect(find.text('+0'), findsNothing);
      });
    });

    group('inheritance', () {
      testWidgets('hands its size and shape to every avatar', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            loose(
              PlAvatarGroup(size: PlassSize.lg, shape: PlAvatarShape.square, avatars: faces(1)),
            ),
            width: 400,
            height: 200,
          ),
        );

        expect(tester.getSize(find.byType(PlAvatar)).height, 48);

        final BoxDecoration face = decorationWhere(
          tester,
          find.byType(PlAvatar),
          (BoxDecoration decoration) => decoration.borderRadius != null,
        );

        expect(face.borderRadius, BorderRadius.circular(PlassTokens.radius[PlassSize.lg]!));
      });

      testWidgets('hands its colour and variant to every avatar', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlAvatarGroup(variant: PlassVariant.solid, color: PlassColor.danger, avatars: faces(1)),
            width: 400,
            height: 200,
          ),
        );

        final PlassColorFamily family = PlassTokens.light().family(PlassColor.danger);

        expect(
          decorationsOf(tester, find.byType(PlAvatar))
              .map((BoxDecoration decoration) => decoration.gradient)
              .whereType<LinearGradient>()
              .map((LinearGradient gradient) => gradient.colors.first),
          contains(family.solid),
        );
      });

      testWidgets('lets an avatar override what the group said', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlAvatarGroup(
              size: PlassSize.lg,
              avatars: <PlAvatar>[
                PlAvatar(name: 'Ada Lovelace'),
                PlAvatar(name: 'Grace Hopper', size: PlassSize.sm),
              ],
            ),
            width: 400,
            height: 200,
          ),
        );

        final Iterable<double> heights = tester
            .widgetList<PlAvatar>(find.byType(PlAvatar))
            .map((PlAvatar avatar) => tester.getSize(find.byWidget(avatar)).height);

        expect(heights, containsAll(<double>[48, 32]));
      });

      testWidgets('leaves an avatar on its own defaults when the group says nothing', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(loose(const PlAvatar(name: 'Ada Lovelace')), width: 400, height: 200),
        );

        expect(tester.getSize(find.byType(PlAvatar)).height, 40);
      });
    });

    testWidgets('is named when it is the only thing saying what the set is', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          PlAvatarGroup(semanticLabel: 'Twelve members', max: 2, total: 12, avatars: faces(2)),
          width: 400,
          height: 200,
        ),
      );

      expect(find.bySemanticsLabel('Twelve members'), findsOneWidget);

      handle.dispose();
    });
  });
}
