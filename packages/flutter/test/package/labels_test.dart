/// That the package's own vocabulary is one set, and that a translation of it
/// reaches every widget.
///
/// A test of the *package* rather than of a widget, like the two beside it: the
/// failure it guards is a word that quietly stays English in one place while the
/// rest of the interface is translated, and no widget test would see that.
library;

import 'dart:io';

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

/// Every word a pack says, by the name of the field it came from.
///
/// Keyed rather than listed, because what a comparison has to be able to say is
/// *which* word a pack left in English, and a pair of indexes cannot say it.
Map<String, String> words(PlassLabels labels) => <String, String>{
  'close': labels.close,
  'cancel': labels.cancel,
  'confirm': labels.confirm,
  'acknowledge': labels.acknowledge,
  'search': labels.search,
  'selectAll': labels.selectAll,
  'selectRow': labels.selectRow,
  'sortedAscending': labels.sortedAscending,
  'sortedDescending': labels.sortedDescending,
  'remove': labels.remove,
  'dismiss': labels.dismiss,
  'open': labels.open,
  'previous': labels.previous,
  'next': labels.next,
  'reveal': labels.reveal,
  'hide': labels.hide,
  'increase': labels.increase,
  'decrease': labels.decrease,
  'preview': labels.preview,
  'empty': labels.empty,
  'optional': labels.optional,
  'breadcrumb': labels.breadcrumb,
  'breadcrumbExpand': labels.breadcrumbExpand,
  'carousel': labels.carousel,
  'carouselPrevious': labels.carouselPrevious,
  'carouselNext': labels.carouselNext,
  'commandPalette': labels.commandPalette,
  'commandPalettePlaceholder': labels.commandPalettePlaceholder,
  'gallery': labels.gallery,
  'chart': labels.chart,
  'minimize': labels.minimize,
  'maximize': labels.maximize,
  'restore': labels.restore,
  'resizeWindow': labels.resizeWindow,
  'overlay': labels.overlay,
  'pagination': labels.pagination,
  'paginationPrevious': labels.paginationPrevious,
  'paginationNext': labels.paginationNext,
  'paginationFirst': labels.paginationFirst,
  'paginationLast': labels.paginationLast,
  'rating': labels.rating,
  'sidebar': labels.sidebar,
  'sidebarOpen': labels.sidebarOpen,
  'sidebarClose': labels.sidebarClose,
  'sidebarResize': labels.sidebarResize,
  'skipToContent': labels.skipToContent,
  'backToTop': labels.backToTop,
  'onThisPage': labels.onThisPage,
  'typing': labels.typing,
  'messageSending': labels.messageSending,
  'messageSent': labels.messageSent,
  'messageDelivered': labels.messageDelivered,
  'messageRead': labels.messageRead,
  'messageFailed': labels.messageFailed,
  'spoilerWarning': labels.spoilerWarning,
  'filePickerTitle': labels.filePickerTitle,
  'newTab': labels.newTab,
  'transferAvailable': labels.transferAvailable,
  'transferSelected': labels.transferSelected,
  'transferToSelected': labels.transferToSelected,
  'transferToAvailable': labels.transferToAvailable,
  'copy': labels.copy,
  'copied': labels.copied,
  'copyFailed': labels.copyFailed,
  'raw': labels.raw,
  'code': labels.code,
  'previousMonth': labels.previousMonth,
  'nextMonth': labels.nextMonth,
  'previousYear': labels.previousYear,
  'nextYear': labels.nextYear,
  'previousYears': labels.previousYears,
  'nextYears': labels.nextYears,
  'chooseMonth': labels.chooseMonth,
  'chooseYear': labels.chooseYear,
  'today': labels.today,
  'thisMonth': labels.thisMonth,
  'thisYear': labels.thisYear,
  'now': labels.now,
  'clear': labels.clear,
  'done': labels.done,
  'skip': labels.skip,
  'hour': labels.hour,
  'minute': labels.minute,
  'second': labels.second,
  'meridiem': labels.meridiem,
  'start': labels.start,
  'end': labels.end,
  // The sentences with a value in them, read with one set of values each so
  // they can be compared like the words above.
  'paginationPage': labels.paginationPage(3),
  'ratingValue': labels.ratingValue(3, 5),
  'ratingNone': labels.ratingNone,
  'carouselSlide': labels.carouselSlide(1, 3),
  'galleryItem': labels.galleryItem(2, 4),
  'removeItem': labels.removeItem('notes.txt'),
  'addCustom': labels.addCustom('Seoul'),
  'howToStep': labels.howToStep(2, 5),
  'transferMoved': labels.transferMoved(3, 'Selected'),
};

/// The words each pack is allowed to share with English, and no others.
///
/// A handful genuinely survive translation, and they are named here one at a
/// time rather than counted. Counting is what let the old version of this test
/// pass with a word left behind: two packs were already at six of an allowance
/// of eight, so the next component's untranslated key had two places to hide.
const Map<String, Set<String>> sharedWithEnglish = <String, Set<String>>{
  // `OK`, `Optional`, `Overlay`, `Code`, `Minute` and `AM/PM` are written the
  // same way in German.
  'de': <String>{'acknowledge', 'optional', 'overlay', 'code', 'minute', 'meridiem'},
  'es': <String>{},
  // `OK`, `Pagination`, `Code`, `Minute`, `AM/PM`, and `Page 3`, which French
  // writes in English's order.
  'fr': <String>{'acknowledge', 'pagination', 'code', 'minute', 'meridiem', 'paginationPage'},
  // `OK`, which is what a Japanese dialog's one button says.
  'ja': <String>{'acknowledge'},
  'ko': <String>{},
  'zhHans': <String>{},
};

void main() {
  group('the label set', () {
    test('ships more than one language', () {
      expect(packs.length, greaterThan(1));
    });

    test('[words] reads every field of PlassLabels', () {
      // The half that catches the *next* word rather than this week's. A key
      // added to the class and left out of [words] is a key no pack is ever
      // checked for, and no comparison between two packs can notice that.
      final String source = File('lib/src/internal/date.dart').readAsStringSync();
      final int opens = source.indexOf('class PlassLabels {');
      final String declared = source.substring(opens, source.indexOf('\n}\n', opens));

      expect(
        RegExp(
          r'^  final .+ (\w+);$',
          multiLine: true,
        ).allMatches(declared).map((Match match) => match[1]).toSet(),
        equals(words(en).keys.toSet()),
      );
    });

    for (final MapEntry<String, PlassLabels> pack in packs.entries) {
      if (pack.key == 'en') {
        continue;
      }

      test('${pack.key} translates every word it does not share on purpose', () {
        final Map<String, String> mine = words(pack.value);
        final Map<String, String> english = words(en);

        expect(
          <String>{
            for (final MapEntry<String, String> word in mine.entries)
              if (word.value == english[word.key]) word.key,
          },
          equals(sharedWithEnglish[pack.key]),
          reason:
              'A key here that is not in sharedWithEnglish is a word left in English — most '
              'often a field a new component added to PlassLabels and only the English pack '
              'answered. A key in sharedWithEnglish that is not here has since been translated '
              'and should leave the list.',
        );
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

  group('a score', () {
    test('is written the way the language of the pack writes a number', () {
      expect(en.ratingValue(2.5, 5), '2.5 out of 5');
      expect(de.ratingValue(2.5, 5), '2,5 von 5');
      expect(es.ratingValue(2.5, 5), '2,5 de 5');
      expect(fr.ratingValue(2.5, 5), '2,5 sur 5');
      expect(ja.ratingValue(2.5, 5), '5点中2.5点');
      expect(ko.ratingValue(2.5, 5), '5점 만점에 2.5점');
      expect(zhHans.ratingValue(2.5, 5), '2.5分，满分5分');
    });

    test('keeps a whole score whole, even when it is a double', () {
      expect(de.ratingValue(3, 5), '3 von 5');
      expect(de.ratingValue(3.0, 5), '3 von 5');
      expect(en.ratingValue(3.0, 5), '3 out of 5');
    });

    test('keeps no more than three decimals', () {
      expect(de.ratingValue(7 / 3, 5), '2,333 von 5');
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

    testWidgets('reads a fraction of a star the way the language of the pack writes it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          PlassTheme.merge(
            defaults: const PlassDefaults(labels: de),
            child: const PlRating(value: 2.5, readOnly: true),
          ),
          width: 320,
        ),
      );
      await tester.pumpAndSettle();

      // The packs used to write the raw number, so German read "2.5 von 5".
      expect(find.bySemanticsLabel('2,5 von 5'), findsOneWidget);

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
