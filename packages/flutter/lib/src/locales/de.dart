/// German.
library;

import 'package:plass_ui/src/internal/date.dart';

/// The library's own vocabulary in German.
const PlassLabels de = PlassLabels(
  close: 'Schließen',
  cancel: 'Abbrechen',
  confirm: 'Bestätigen',
  acknowledge: 'OK',
  search: 'Suchen',
  selectAll: 'Alle auswählen',
  selectRow: 'Zeile auswählen',
  sortedAscending: 'Sortiert, kleinste zuerst',
  sortedDescending: 'Sortiert, größte zuerst',
  remove: 'Entfernen',
  dismiss: 'Ausblenden',
  open: 'Öffnen',
  previous: 'Zurück',
  next: 'Weiter',
  reveal: 'Anzeigen',
  hide: 'Verbergen',
  increase: 'Erhöhen',
  decrease: 'Verringern',
  preview: 'Vorschau',
  empty: 'Nichts vorhanden',
  optional: 'Optional',
  loading: 'Wird geladen',
  breadcrumb: 'Navigationspfad',
  breadcrumbExpand: 'Ausgeblendete Schritte anzeigen',
  carousel: 'Karussell',
  carouselPrevious: 'Vorheriges Bild',
  carouselNext: 'Nächstes Bild',
  commandPalette: 'Befehlspalette',
  commandPalettePlaceholder: 'Befehle durchsuchen',
  gallery: 'Galerie',
  chart: 'Diagramm',
  chartOther: 'Sonstige',
  chartMore: _chartMore,
  chartFewer: 'Weniger anzeigen',
  minimize: 'Minimieren',
  maximize: 'Maximieren',
  restore: 'Wiederherstellen',
  resizeWindow: 'Fenstergröße ändern',
  overlay: 'Overlay',
  pagination: 'Seitennavigation',
  paginationPrevious: 'Vorherige Seite',
  paginationNext: 'Nächste Seite',
  paginationFirst: 'Erste Seite',
  paginationLast: 'Letzte Seite',
  rating: 'Bewertung',
  sidebar: 'Seitenleiste',
  sidebarOpen: 'Seitenleiste öffnen',
  sidebarClose: 'Seitenleiste schließen',
  sidebarResize: 'Breite der Seitenleiste ändern',
  skipToContent: 'Zum Inhalt springen',
  backToTop: 'Nach oben',
  onThisPage: 'Auf dieser Seite',
  typing: 'Schreibt …',
  messageSending: 'Wird gesendet',
  messageSent: 'Gesendet',
  messageDelivered: 'Zugestellt',
  messageRead: 'Gelesen',
  messageFailed: 'Nicht zugestellt',
  spoilerWarning: 'Kann Spoiler enthalten',
  filePickerTitle: 'Dateien auswählen',
  newTab: '(wird woanders geöffnet)',
  transferAvailable: 'Verfügbar',
  transferSelected: 'Ausgewählt',
  transferToSelected: 'Zu den ausgewählten verschieben',
  transferToAvailable: 'Zu den verfügbaren verschieben',
  copy: 'Kopieren',
  copied: 'Kopiert',
  copyFailed: 'Kopieren nicht möglich',
  raw: 'Unformatiert',
  code: 'Code',
  previousMonth: 'Vorheriger Monat',
  nextMonth: 'Nächster Monat',
  previousYear: 'Vorheriges Jahr',
  nextYear: 'Nächstes Jahr',
  previousYears: 'Vorherige Jahre',
  nextYears: 'Nächste Jahre',
  chooseMonth: 'Monat wählen',
  chooseYear: 'Jahr wählen',
  today: 'Heute',
  thisMonth: 'Dieser Monat',
  thisYear: 'Dieses Jahr',
  now: 'Jetzt',
  clear: 'Leeren',
  done: 'Fertig',
  skip: 'Überspringen',
  hour: 'Stunde',
  minute: 'Minute',
  second: 'Sekunde',
  meridiem: 'AM/PM',
  start: 'Beginn',
  end: 'Ende',
  paginationPage: _paginationPage,
  ratingValue: _ratingValue,
  ratingNone: 'Keine Bewertung',
  carouselSlide: _carouselSlide,
  galleryItem: _galleryItem,
  removeItem: _removeItem,
  addCustom: _addCustom,
  howToStep: _howToStep,
  transferMoved: _transferMoved,
  filesRejectedType: _filesRejectedType,
  filesRejectedSize: _filesRejectedSize,
  filesRejectedCount: _filesRejectedCount,
);

String _paginationPage(int page) => 'Seite $page';

String _ratingValue(num value, int count) => '${plassDecimal(value, ',')} von $count';

String _carouselSlide(int index, int count) => 'Bild $index von $count';

String _galleryItem(int index, int total) => '$index von $total';

String _removeItem(String name) => '$name entfernen';

String _addCustom(String query) => '„$query“ hinzufügen';

String _howToStep(int step, int total) => 'Schritt $step von $total';

String _transferMoved(int count, String list) {
  return '$count ${count == 1 ? 'Eintrag' : 'Einträge'} nach „$list“ verschoben';
}

String _filesRejectedType(int count) {
  return '$count ${count == 1 ? 'Datei hat' : 'Dateien haben'} keinen zulässigen Typ';
}

String _filesRejectedSize(int count) {
  return '$count ${count == 1 ? 'Datei ist' : 'Dateien sind'} zu groß';
}

String _filesRejectedCount(int count) {
  return 'Für $count ${count == 1 ? 'Datei' : 'Dateien'} war kein Platz mehr';
}

String _chartMore(int count) => '$count weitere';
