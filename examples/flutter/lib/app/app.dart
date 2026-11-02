import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:plass_showcase/app/page.dart';
import 'package:plass_showcase/app/settings.dart';
import 'package:plass_showcase/app/shell.dart';
import 'package:plass_ui/plass_ui.dart';

/// The app, without a `MaterialApp`: the library needs neither Material nor
/// Cupertino, so this shows what a consumer gets with `WidgetsApp` alone.
class ShowcaseApp extends StatefulWidget {
  /// Creates the app.
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  final ShowcaseSettings _settings = ShowcaseSettings();

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (BuildContext context, Widget? _) {
        return WidgetsApp(
          debugShowCheckedModeBanner: false,
          title: 'Plass Showcase',
          color: const Color(0xFF3F63F2),
          pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
            return ShowcaseRoute<T>(builder: builder, settings: settings);
          },
          home: const Shell(),
          builder: (BuildContext context, Widget? child) {
            final media = MediaQuery.of(context);
            final tokens = PlassTokens.of(_settings.brightness ?? media.platformBrightness);

            return SettingsScope(
              settings: _settings,
              child: MediaQuery(
                data: _settings.textScale == null
                    ? media
                    : media.copyWith(textScaler: TextScaler.linear(_settings.textScale!)),
                child: Directionality(
                  textDirection: _settings.direction,
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: tokens.fg,
                      fontFamily: 'Inter',
                      package: 'plass_ui_example',
                      fontSize: 15,
                      height: 1.45,
                    ),
                    child: PlassTheme.tokens(
                      tokens: tokens,
                      defaults: PlassDefaults(labels: _settings.labels, density: _settings.density),
                      // The system's bars read the theme here, not the device's.
                      child: AnnotatedRegion<SystemUiOverlayStyle>(
                        value: tokens.brightness == Brightness.dark
                            ? SystemUiOverlayStyle.light
                            : SystemUiOverlayStyle.dark,
                        child: PlToastProvider(child: PlConfirmProvider(child: child!)),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
