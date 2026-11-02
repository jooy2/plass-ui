import 'package:flutter/widgets.dart';
import 'package:plass_ui/locales.dart';
import 'package:plass_ui/plass_ui.dart';

/// What the Settings screen changes for the whole app.
class ShowcaseSettings extends ChangeNotifier {
  Brightness? _brightness;
  TextDirection _direction = TextDirection.ltr;
  String _language = 'en';
  PlassDensity _density = PlassDensity.standard;
  double? _textScale;

  /// The packs a reader can pick from.
  static const Map<String, (String, PlassLabels)> languages = <String, (String, PlassLabels)>{
    'en': ('English', en),
    'de': ('Deutsch', de),
    'es': ('Español', es),
    'fr': ('Français', fr),
    'ja': ('日本語', ja),
    'ko': ('한국어', ko),
    'zh-Hans': ('简体中文', zhHans),
  };

  /// The chosen theme, or `null` to follow the device.
  Brightness? get brightness => _brightness;
  set brightness(Brightness? next) {
    _brightness = next;
    notifyListeners();
  }

  /// The direction every screen is laid out in.
  TextDirection get direction => _direction;
  set direction(TextDirection next) {
    _direction = next;
    notifyListeners();
  }

  /// The key of the chosen label pack.
  String get language => _language;
  set language(String next) {
    _language = next;
    notifyListeners();
  }

  /// The labels the library's own words are read from.
  PlassLabels get labels => languages[_language]!.$2;

  /// How tightly the components are padded.
  PlassDensity get density => _density;
  set density(PlassDensity next) {
    _density = next;
    notifyListeners();
  }

  /// A text scale, or `null` to follow the device.
  double? get textScale => _textScale;
  set textScale(double? next) {
    _textScale = next;
    notifyListeners();
  }
}

/// Hands the [ShowcaseSettings] to the screens under it.
class SettingsScope extends InheritedNotifier<ShowcaseSettings> {
  /// Creates the scope.
  const SettingsScope({required ShowcaseSettings settings, required super.child, super.key})
    : super(notifier: settings);

  /// The settings in scope.
  static ShowcaseSettings of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
  }
}
