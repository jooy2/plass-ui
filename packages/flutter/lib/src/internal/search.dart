/// What "this matches what I typed" means, once.
///
/// The Dart half of the React package's `internal/search.ts`, and it is here
/// for the same reason: two widgets let a reader type at a list of their own —
/// [PlTransfer] and [PlCommandPalette] — and a `matches` in each of them would
/// be two answers to one question that eventually disagree.
///
/// **One thing is said differently, and it is a real difference.** The React
/// fold strips combining marks as well as case, so `cafe` finds `Café`. Dart's
/// core has no `String.normalize`, and this package has no dependencies —
/// pulling one in so that a search box folds accents would be a dependency in
/// every consumer's binary for the sake of one comparison. So the fold here is
/// case only, and the pages say so.
///
/// It is not exported from `plass_ui.dart`.
library;

/// A value as something a query can be matched against.
///
/// Case-folded, so `SEOUL` finds `Seoul`. `toLowerCase` is locale-independent
/// in Dart, which is the right behaviour for a filter: a Turkish locale that
/// folded `I` to a dotless `ı` would stop finding `Istanbul` for `istanbul`.
String searchText(String? value) {
  return value == null ? '' : value.toLowerCase();
}
