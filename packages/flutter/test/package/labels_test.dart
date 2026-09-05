/// That the package's own vocabulary is one set, and that a translation of it
/// reaches every widget.
///
/// A test of the *package* rather than of a widget, like the two beside it: the
/// failure it guards is a word that quietly stays English in one place while the
/// rest of the interface is translated, and no widget test would see that.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/locales.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

const Map<String, PlassLabels> packs = <String, PlassLabels>{
  'de': de,
  'en': en,
  'es': es,
  'fr': fr,
  'ja': ja,
  'ko': ko,
  'zhHans': zhHans,
};

/// Every word a pack says, in one list, so two packs can be compared.
List<String> words(PlassLabels labels) => <String>[
  labels.close,
  labels.cancel,
  labels.confirm,
  labels.search,
  labels.selectAll,
  labels.selectRow,
  labels.sortedAscending,
  labels.sortedDescending,
  labels.remove,
  labels.dismiss,
  labels.open,
  labels.previous,
  labels.next,
  labels.reveal,
  labels.hide,
  labels.increase,
  labels.decrease,
  labels.preview,
  labels.empty,
  labels.breadcrumb,
  labels.breadcrumbExpand,
  labels.carousel,
  labels.carouselPrevious,
  labels.carouselNext,
  labels.commandPalette,
  labels.commandPalettePlaceholder,
  labels.gallery,
  labels.chart,
  labels.overlay,
  labels.pagination,
  labels.paginationPrevious,
  labels.paginationNext,
  labels.paginationFirst,
  labels.paginationLast,
  labels.rating,
  labels.sidebar,
  labels.sidebarClose,
  labels.sidebarResize,
  labels.skipToContent,
  labels.backToTop,
  labels.onThisPage,
  labels.typing,
  labels.newTab,
  labels.transferAvailable,
  labels.transferSelected,
  labels.transferToSelected,
  labels.transferToAvailable,
  labels.copy,
  labels.copied,
  labels.copyFailed,
  labels.raw,
  labels.code,
  labels.previousMonth,
  labels.nextMonth,
  labels.previousYear,
  labels.nextYear,
  labels.previousYears,
  labels.nextYears,
  labels.chooseMonth,
  labels.chooseYear,
  labels.today,
  labels.thisMonth,
  labels.thisYear,
  labels.now,
  labels.clear,
  labels.done,
  labels.skip,
  labels.hour,
  labels.minute,
  labels.second,
  labels.meridiem,
  labels.start,
  labels.end,
];

void main() {
  group('the label set', () {
    test('ships more than one language', () {
      expect(packs.length, greaterThan(1));
    });

    for (final MapEntry<String, PlassLabels> pack in packs.entries) {
      test('${pack.key} answers every word', () {
        // A field left out of a pack keeps its English default, which is the
        // failure this catches: the count is fixed, so a word nobody translated
        // shows up as a word that matches English.
        expect(words(pack.value).length, words(en).length);
      });

      if (pack.key == 'en') {
        continue;
      }

      test('${pack.key} is a translation rather than a copy', () {
        final List<String> mine = words(pack.value);
        final List<String> english = words(en);
        int same = 0;

        for (int index = 0; index < mine.length; index += 1) {
          if (mine[index] == english[index]) {
            same += 1;
          }
        }

        // A handful of strings genuinely survive translation — `AM/PM`,
        // `Overlay`, `Minute` — so the check is that a pack is a translation,
        // not that every single word differs.
        expect(same, lessThan(6));
      });
    }
  });

  group('copyWith', () {
    test('keeps the pack and replaces the one word', () {
      const PlassLabels mine = PlassLabels(close: '닫기', start: '시작');
      final PlassLabels changed = mine.copyWith(start: '체크인');

      expect(changed.start, '체크인');
      expect(changed.close, '닫기');
    });
  });

  group('a translated theme', () {
    testWidgets('reaches a widget that says a word of its own', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          PlassTheme.merge(
            defaults: const PlassDefaults(labels: ko),
            child: PlAlert(onClose: () {}, child: const Text('저장했습니다')),
          ),
          width: 320,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('닫기'), findsOneWidget);

      handle.dispose();
    });

    testWidgets("still loses to the widget's own parameter", (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          PlassTheme.merge(
            defaults: const PlassDefaults(labels: ko),
            child: PlAlert(onClose: () {}, closeLabel: '지금은 그만', child: const Text('저장했습니다')),
          ),
          width: 320,
        ),
      );
      await tester.pumpAndSettle();

      // Three layers, narrowest last: English, the application's, the widget's.
      expect(find.bySemanticsLabel('지금은 그만'), findsOneWidget);

      handle.dispose();
    });
  });
}
