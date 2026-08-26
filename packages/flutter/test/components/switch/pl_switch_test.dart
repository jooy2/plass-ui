import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The track: the box with the pill radius on it.
BoxDecoration trackOf(WidgetTester tester) {
  return decorationsOf(
    tester,
    find.byType(PlSwitch),
  ).firstWhere((BoxDecoration decoration) => decoration.borderRadius != null);
}

void main() {
  group('PlSwitch', () {
    group('rendering', () {
      testWidgets('is a track of the size asked for', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSwitch(value: false, size: PlassSize.md), width: 200));

        expect(tester.getSize(find.byType(AnimatedContainer).first), const Size(36, 20));
      });

      testWidgets('renders its label and description', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlSwitch(
              value: false,
              label: Text('Email me'),
              description: Text('About releases'),
            ),
            width: 320,
          ),
        );

        expect(find.text('Email me'), findsOneWidget);
        expect(styleOf(tester, 'About releases').color, PlassTokens.light().mutedFg);
      });
    });

    group('the track', () {
      testWidgets('is the groove when it is off', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSwitch(value: false), width: 200));

        final track = trackOf(tester);

        expect(track.color, PlassTokens.light().track);
        expect(track.gradient, isNull);
        // No well, no gloss and no edge: a groove that is a tone needs no
        // hairline to say where it ends.
        expect(track.border, isNull);
      });

      testWidgets('is the family gradient when it is on', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSwitch(value: true), width: 200));
        await tester.pumpAndSettle();

        expect(trackOf(tester).gradient, isNotNull);
      });

      testWidgets('moves the thumb the whole way and no further', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSwitch(value: false), width: 200));
        await tester.pumpAndSettle();
        final off = tester.getRect(find.byType(DecoratedBox).last);

        await tester.pumpWidget(host(const PlSwitch(value: true), width: 200));
        await tester.pumpAndSettle();
        final on = tester.getRect(find.byType(DecoratedBox).last);

        final track = tester.getRect(find.byType(AnimatedContainer).first);

        // Two from the leading edge off, and two from the trailing edge on.
        expect(off.left - track.left, 2);
        expect(track.right - on.right, 2);
      });
    });

    group('toggling', () {
      testWidgets('reports what the value should become', (WidgetTester tester) async {
        bool? reported;
        await tester.pumpWidget(
          host(PlSwitch(value: false, onChanged: (bool next) => reported = next), width: 200),
        );

        await tester.tap(find.byType(PlSwitch));
        expect(reported, isTrue);
      });

      testWidgets('does not fire while read-only', (WidgetTester tester) async {
        bool? reported;
        await tester.pumpWidget(
          host(
            PlSwitch(value: false, readOnly: true, onChanged: (bool next) => reported = next),
            width: 200,
          ),
        );

        await tester.tap(find.byType(PlSwitch));
        expect(reported, isNull);
      });
    });

    group('labelPlacement', () {
      testWidgets('puts the label after the track by default', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSwitch(value: false, label: Text('Email me')), width: 320),
        );

        expect(
          tester.getRect(find.text('Email me')).left,
          greaterThan(tester.getRect(find.byType(AnimatedContainer).first).left),
        );
      });

      testWidgets('puts it before the track when asked, with the switch at the edge', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlSwitch(value: false, label: Text('Email me'), labelPlacement: PlassAlign.start),
            width: 320,
          ),
        );

        expect(
          tester.getRect(find.text('Email me')).left,
          lessThan(tester.getRect(find.byType(AnimatedContainer).first).left),
        );
      });
    });

    group('accessibility', () {
      testWidgets('reports what it is toggled to', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(PlSwitch(value: true, onChanged: (bool _) {}), width: 200));

        expect(
          semanticsOf(tester, find.byType(PlSwitch)),
          isSemantics(hasToggledState: true, isToggled: true),
        );

        handle.dispose();
      });

      testWidgets('takes a name for a switch with no visible label', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlSwitch(value: false, onChanged: (bool _) {}, semanticLabel: 'Notify Ada'),
            width: 200,
          ),
        );

        expect(find.bySemanticsLabel('Notify Ada'), findsOneWidget);
        handle.dispose();
      });
    });
  });
}
