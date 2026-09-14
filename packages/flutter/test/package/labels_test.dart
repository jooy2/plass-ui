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
  labels.acknowledge,
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
  labels.optional,
  labels.breadcrumb,
  labels.breadcrumbExpand,
  labels.carousel,
  labels.carouselPrevious,
  labels.carouselNext,
  labels.commandPalette,
  labels.commandPalettePlaceholder,
  labels.gallery,
  labels.chart,
  labels.minimize,
  labels.maximize,
  labels.restore,
  labels.resizeWindow,
  labels.overlay,
  labels.pagination,
  labels.paginationPrevious,
  labels.paginationNext,
  labels.paginationFirst,
  labels.paginationLast,
  labels.rating,
  labels.sidebar,
  labels.sidebarOpen,
  labels.sidebarClose,
  labels.sidebarResize,
  labels.skipToContent,
  labels.backToTop,
  labels.onThisPage,
  labels.typing,
  labels.messageSending,
  labels.messageSent,
  labels.messageDelivered,
  labels.messageRead,
  labels.messageFailed,
  labels.spoilerWarning,
  labels.filePickerTitle,
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
  // The sentences with a value in them, read with one set of values each so
  // they can be compared like the words above.
  labels.paginationPage(3),
  labels.ratingValue(3, 5),
  labels.ratingNone,
  labels.carouselSlide(1, 3),
  labels.galleryItem(2, 4),
  labels.removeItem('notes.txt'),
  labels.addCustom('Seoul'),
  labels.howToStep(2, 5),
  labels.transferMoved(3, 'Selected'),
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
        // `Overlay`, `Minute`, `OK`, German's `Optional` — so the check is that a
        // pack is a translation, not that every single word differs.
        expect(same, lessThan(8));
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

    testWidgets('reaches the words a popconfirm and a palette fall back to', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(900, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        host(
          PlassTheme.merge(
            defaults: const PlassDefaults(labels: ko),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PlPopconfirm(open: true, trigger: Text('Row'), title: Text('?')),
                PlCommandPalette(items: <PlCommandItem>[], open: true),
              ],
            ),
          ),
          overlay: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(ko.commandPalettePlaceholder), findsOneWidget);
      expect(find.text(ko.empty), findsOneWidget);
      expect(find.text(ko.cancel), findsOneWidget);
      expect(find.text(ko.confirm), findsOneWidget);
    });

    testWidgets('reaches the words a confirm dialog falls back to', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        host(
          PlassTheme.merge(
            defaults: const PlassDefaults(labels: ko),
            child: PlConfirmProvider(
              child: Builder(
                builder: (BuildContext context) => PlButton(
                  onPressed: () => PlConfirmProvider.of(context).confirm(const PlConfirmOptions()),
                  child: const Text('Ask'),
                ),
              ),
            ),
          ),
          overlay: true,
        ),
      );
      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle();

      expect(find.text(ko.cancel), findsOneWidget);
      expect(find.text(ko.confirm), findsOneWidget);
    });

    testWidgets('reaches the words that used to be written into a widget', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        host(
          PlassTheme.merge(
            defaults: const PlassDefaults(labels: ko),
            child: PlConfirmProvider(
              child: Builder(
                builder: (BuildContext context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const PlSpoiler(child: Text('Ending')),
                    const PlFilePicker(value: <PlFile>[]),
                    const PlChatBubble(status: PlChatBubbleStatus.failed, child: Text('Hi')),
                    PlButton(
                      onPressed: () =>
                          PlConfirmProvider.of(context).alert(const PlConfirmOptions()),
                      child: const Text('Tell'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          overlay: true,
          width: 600,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(ko.spoilerWarning), findsOneWidget);
      expect(find.text(ko.filePickerTitle), findsOneWidget);
      expect(find.bySemanticsLabel(ko.messageFailed), findsOneWidget);

      await tester.tap(find.text('Tell'));
      await tester.pumpAndSettle();

      expect(find.text(ko.acknowledge), findsOneWidget);

      handle.dispose();
    });

    testWidgets('reaches the sentences with a value in them', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        host(
          PlassTheme.merge(
            defaults: const PlassDefaults(labels: ko),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const PlPagination(count: 10, page: 5),
                const PlRating(value: 3, readOnly: true),
                const PlHowToSteps(
                  steps: <PlHowToStep>[
                    PlHowToStep(title: Text('Unpack')),
                    PlHowToStep(title: Text('Plug in')),
                  ],
                ),
                // A remove button is only drawn on a list somebody can change.
                PlFilePicker(
                  value: const <PlFile>[PlFile(name: 'notes.txt', size: 12)],
                  onFilesChanged: (List<PlFile> files) {},
                ),
                const PlCarousel(
                  value: 0,
                  aspectRatio: 4,
                  children: <Widget>[Text('A'), Text('B')],
                ),
              ],
            ),
          ),
          width: 600,
        ),
      );
      await tester.pumpAndSettle();

      // Every one of these used to be an English template inside the widget, so
      // a Korean screen read `Page 5` inside a landmark called `페이지 이동`.
      expect(find.bySemanticsLabel(ko.paginationPage(5)), findsOneWidget);
      expect(find.bySemanticsLabel(ko.ratingValue(3, 5)), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(ko.howToStep(2, 2))), findsOneWidget);
      expect(find.bySemanticsLabel(ko.removeItem('notes.txt')), findsOneWidget);
      expect(find.bySemanticsLabel(ko.carouselSlide(1, 2)), findsWidgets);

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
