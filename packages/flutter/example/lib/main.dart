import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui_example/canvas.dart';
import 'package:plass_ui_example/demos/registry.dart';
import 'package:plass_ui_example/host_bridge.dart';

/// The Plass component gallery.
///
/// It has two jobs, and they are the same code seen from two sides:
///
/// - Run it (`flutter run`) and it is a gallery — every demo, stacked, with a
///   theme switch. This is how the components are looked at while they are
///   being built.
/// - Build it for the web and the documentation site embeds it, one demo per
///   `<iframe>`, named by `?demo=button/variants`. That is what makes the
///   Flutter previews on the site the *real* Flutter build rather than a
///   screenshot or a stand-in.
///
/// Nothing here imports Material or Cupertino, for the same reason the library
/// does not: a gallery that needed a `MaterialApp` around it would not be
/// showing what a consumer of this package actually gets.
/// See `assets/fonts/README.md`.
const String _fontFamily = 'Inter';

void main() {
  runApp(const GalleryApp());
}

/// The app, in whichever of its two modes the URL asks for.
class GalleryApp extends StatefulWidget {
  /// Creates the gallery.
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  static const HostBridge _host = HostBridge();

  late Brightness _brightness = _requestedBrightness;

  Brightness get _requestedBrightness {
    return _host.query['theme'] == 'dark' ? Brightness.dark : Brightness.light;
  }

  @override
  void initState() {
    super.initState();

    // The page flips a preview's theme without reloading it: rebuilding a whole
    // Flutter engine to change two colours would be absurd.
    _host.onTheme((Brightness brightness) {
      if (mounted && brightness != _brightness) {
        setState(() => _brightness = brightness);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      debugShowCheckedModeBanner: false,
      title: 'Plass',
      color: const Color(0xFF3F63F2),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          // The family every demo inherits, and the reason it is set at all is
          // in `assets/fonts/README.md`: Flutter's engine carries one face,
          // and a label at weight 600 with nothing else available comes out
          // synthesised. A real app supplies its font here too — the library
          // does not, and should not.
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontFamily: _fontFamily),
            child: PlassTheme(
              brightness: _brightness,
              // Somewhere for a modal or an overlay to go. A real app gets one
              // from its navigator; this gallery has no routes, so it says so
              // itself — sized to the demo, which is what an embedded preview
              // wants a full-screen sheet measured against.
              child: Overlay.wrap(
                child: _host.embedded
                    ? _Embedded(demo: _host.query['demo']!, align: _host.query['align'])
                    : _Gallery(
                        brightness: _brightness,
                        onFlip: () => setState(() {
                          _brightness = _brightness == Brightness.dark
                              ? Brightness.light
                              : Brightness.dark;
                        }),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// One demo, sized to its content and reported back to the page.
class _Embedded extends StatefulWidget {
  const _Embedded({required this.demo, required this.align});

  final String demo;
  final String? align;

  @override
  State<_Embedded> createState() => _EmbeddedState();
}

class _EmbeddedState extends State<_Embedded> {
  static const HostBridge _host = HostBridge();

  final GlobalKey _content = GlobalKey();
  double? _reported;

  /// Measures after every frame and reports a height that has changed.
  ///
  /// After layout rather than during it, because the height is a *result* of
  /// laying the demo out — and reporting the same number twice would put the
  /// page into a resize loop with the frame it is resizing.
  void _measure(Duration _) {
    final box = _content.currentContext?.findRenderObject() as RenderBox?;

    if (box == null || !box.hasSize) {
      return;
    }

    final height = box.size.height;

    // The canvas's own padding is drawn inside the frame, so the page has to
    // reserve room for it too.
    final total = height + PlassCanvas.padding.vertical;

    if (_reported == null || (total - _reported!).abs() > 0.5) {
      _reported = total;
      _host.reportHeight(total);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_measure);

    final build = demos[widget.demo];

    return PlassCanvas(
      align: widget.align == 'center' ? Alignment.topCenter : Alignment.topLeft,
      child: KeyedSubtree(
        key: _content,
        child: build == null ? _Missing(demo: widget.demo) : build(context),
      ),
    );
  }
}

/// What a demo the Flutter package has not reached yet says for itself.
class _Missing extends StatelessWidget {
  const _Missing({required this.demo});

  final String demo;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return Text(
      'No Flutter version of “$demo” yet.',
      style: TextStyle(color: tokens.mutedFg, fontSize: 14),
    );
  }
}

/// Every demo, stacked — the mode `flutter run` gives you.
class _Gallery extends StatelessWidget {
  const _Gallery({required this.brightness, required this.onFlip});

  final Brightness brightness;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final padding = MediaQuery.paddingOf(context);

    return PlassCanvas(
      child: Padding(
        padding: EdgeInsets.only(top: padding.top, bottom: padding.bottom + 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Plass',
                      style: TextStyle(color: tokens.fg, fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                  ),
                  PlButton(
                    variant: PlassVariant.glass,
                    size: PlassSize.sm,
                    color: PlassColor.secondary,
                    onPressed: onFlip,
                    child: Text(brightness == Brightness.dark ? 'Light' : 'Dark'),
                  ),
                ],
              ),
            ),
            for (final entry in demos.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          color: tokens.mutedFg,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    entry.value(context),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
