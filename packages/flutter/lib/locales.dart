/// The package's own vocabulary, translated.
///
/// A library of its own rather than part of `plass_ui.dart`, so that an
/// application imports the packs only if it wants one:
///
/// ```dart
/// import 'package:plass_ui/plass_ui.dart';
/// import 'package:plass_ui/locales.dart';
///
/// PlassTheme.merge(
///   defaults: const PlassDefaults(labels: ko),
///   child: child,
/// );
/// ```
///
/// Every pack is a whole [PlassLabels], so a field nobody translated is a word
/// that stayed English on purpose rather than by accident.
///
/// **The set is short on purpose.** A pack is only worth shipping when somebody
/// who reads the language has read it, so this is the list that has been read
/// rather than the list a machine could produce. Adding one is a file of the
/// same shape and a pull request.
library;

export 'src/locales/de.dart';
export 'src/locales/en.dart';
export 'src/locales/es.dart';
export 'src/locales/fr.dart';
export 'src/locales/ja.dart';
export 'src/locales/ko.dart';
export 'src/locales/zh_hans.dart';
